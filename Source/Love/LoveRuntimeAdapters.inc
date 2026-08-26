::love::Type DoraLoveGraphics::type("Graphics", &::love::Module::type);

struct ThreadChannel;
struct ThreadContext;

class DoraLoveSystem final : public ::love::system::System
{
public:
	explicit DoraLoveSystem(LoveRuntime *runtime) : _runtime(runtime) { }
	std::string getOS() const override;
	int getProcessorCount() const override;
	void setClipboardText(const std::string &text) const override;
	std::string getClipboardText() const override;
	PowerState getPowerInfo(int &seconds, int &percent) const override;
	bool openURL(const std::string &url) const override;
	void vibrate(double seconds) const override;
	bool hasBackgroundMusic() const override;
private:
	LoveRuntime *_runtime = nullptr;
};

class DoraLoveTimer final : public ::love::timer::Timer
{
	public:
	explicit DoraLoveTimer(LoveRuntime *runtime) : _runtime(runtime) { }
	double step() override;
	void sleep(double seconds) const override;
	double getDelta() const override;
	int getFPS() const override;
	double getAverageDelta() const override;
	double getTime() const override;
private:
	LoveRuntime *_runtime = nullptr;
};

class DoraLoveEvent final : public ::love::event::Event
{
public:
	explicit DoraLoveEvent(LoveRuntime *runtime, lua_State *state)
		: _runtime(runtime), _state(state) { }
	void push(::love::event::Message *message) override;
	bool poll(::love::event::Message *&message) override;
	void clear() override;
	void pump() override;
	::love::event::Message *wait() override;
private:
	LoveRuntime *_runtime = nullptr;
	lua_State *_state = nullptr;
};

class DoraLoveWindow final : public ::love::window::Window
{
public:
	explicit DoraLoveWindow(LoveRuntime *runtime) : _runtime(runtime) { }
	const char *getName() const override { return "love.window"; }
	void setGraphics(::love::graphics::Graphics *) override { }
	bool setWindow(int width, int height, ::love::window::WindowSettings *settings) override;
	void getWindow(int &width, int &height, ::love::window::WindowSettings &settings) override;
	void close() override { _open = false; }
	bool setFullscreen(bool fullscreen, FullscreenType type) override;
	bool setFullscreen(bool fullscreen) override { return setFullscreen(fullscreen, _settings.fstype); }
	bool onSizeChanged(int width, int height) override { return setWindow(width, height, nullptr); }
	int getDisplayCount() const override { return 1; }
	const char *getDisplayName(int displayIndex) const override;
	DisplayOrientation getDisplayOrientation(int displayIndex) const override;
	std::vector<WindowSize> getFullscreenSizes(int displayIndex) const override;
	void getDesktopDimensions(int displayIndex, int &width, int &height) const override;
	void setPosition(int x, int y, int displayIndex) override;
	void getPosition(int &x, int &y, int &displayIndex) override;
	::love::Rect getSafeArea() const override;
	bool isOpen() const override;
	void setWindowTitle(const std::string &title) override;
	const std::string &getWindowTitle() const override;
	bool setIcon(::love::image::ImageData *image) override;
	::love::image::ImageData *getIcon() override { return _icon.get(); }
	void setVSync(int vsync) override;
	int getVSync() const override;
	void setDisplaySleepEnabled(bool enable) override;
	bool isDisplaySleepEnabled() const override;
	void minimize() override { _minimized = true; _maximized = false; }
	void maximize() override { _maximized = true; _minimized = false; }
	void restore() override { _maximized = _minimized = false; }
	bool isMaximized() const override { return _maximized; }
	bool isMinimized() const override { return _minimized; }
	bool hasFocus() const override;
	bool hasMouseFocus() const override;
	bool isVisible() const override;
	void setMouseGrab(bool grab) override;
	bool isMouseGrabbed() const override;
	int getWidth() const override;
	int getHeight() const override;
	int getPixelWidth() const override { return getWidth(); }
	int getPixelHeight() const override { return getHeight(); }
	void clampPositionInWindow(double *x, double *y) const override;
	void windowToPixelCoords(double *, double *) const override { }
	void pixelToWindowCoords(double *, double *) const override { }
	void windowToDPICoords(double *, double *) const override { }
	void DPIToWindowCoords(double *, double *) const override { }
	double getDPIScale() const override { return 1.0; }
	double getNativeDPIScale() const override { return 1.0; }
	double toPixels(double value) const override { return value; }
	void toPixels(double x, double y, double &px, double &py) const override { px = x; py = y; }
	double fromPixels(double value) const override { return value; }
	void fromPixels(double x, double y, double &wx, double &wy) const override { wx = x; wy = y; }
	const void *getHandle() const override { return nullptr; }
	bool showMessageBox(const std::string &, const std::string &, MessageBoxType, bool) override { return false; }
	int showMessageBox(const MessageBoxData &data) override { return data.escapeButtonIndex; }
	void requestAttention(bool) override { }
private:
	void checkDisplay(int displayIndex) const;
	LoveRuntime *_runtime = nullptr;
	::love::window::WindowSettings _settings;
	::love::StrongRef<::love::image::ImageData> _icon;
	bool _open = true;
	bool _maximized = false;
	bool _minimized = false;
};

class DoraLoveKeyboard final : public ::love::keyboard::Keyboard
{
public:
	explicit DoraLoveKeyboard(LoveRuntime *runtime) : _runtime(runtime) { }
	const char *getName() const override { return "love.keyboard"; }
	void setKeyRepeat(bool enable) override;
	bool hasKeyRepeat() const override;
	bool isDown(const std::vector<Key> &keys) const override;
	bool isScancodeDown(const std::vector<Scancode> &scancodes) const override;
	Key getKeyFromScancode(Scancode scancode) const override;
	Scancode getScancodeFromKey(Key key) const override;
	void setTextInput(bool enable) override;
	void setTextInput(bool enable, double x, double y, double w, double h) override;
	bool hasTextInput() const override;
	bool hasScreenKeyboard() const override;
private:
	LoveRuntime *_runtime = nullptr;
};

class DoraLoveMouse final : public ::love::mouse::Mouse
{
public:
	explicit DoraLoveMouse(LoveRuntime *runtime) : _runtime(runtime) { }
	const char *getName() const override { return "love.mouse"; }
	::love::mouse::Cursor *newCursor(::love::image::ImageData *data, int hotx, int hoty) override;
	::love::mouse::Cursor *getSystemCursor(::love::mouse::Cursor::SystemCursor type) override;
	void setCursor(::love::mouse::Cursor *cursor) override;
	void setCursor() override;
	::love::mouse::Cursor *getCursor() const override { return _cursor.get(); }
	bool isCursorSupported() const override;
	double getX() const override;
	double getY() const override;
	void getPosition(double &x, double &y) const override;
	void setX(double x) override;
	void setY(double y) override;
	void setPosition(double x, double y) override;
	void setVisible(bool visible) override;
	bool isDown(const std::vector<int> &buttons) const override;
	bool isVisible() const override;
	void setGrabbed(bool grabbed) override;
	bool isGrabbed() const override;
	bool setRelativeMode(bool relative) override;
	bool getRelativeMode() const override;
private:
	LoveRuntime *_runtime = nullptr;
	::love::StrongRef<::love::mouse::Cursor> _cursor;
	std::unordered_map<int, ::love::StrongRef<::love::mouse::Cursor>> _systemCursors;
};

class DoraLoveTouch final : public ::love::touch::Touch
{
public:
	explicit DoraLoveTouch(LoveRuntime *runtime) : _runtime(runtime) { }
	const char *getName() const override { return "love.touch"; }
	const std::vector<TouchInfo> &getTouches() const override;
	const TouchInfo &getTouch(::love::int64 id) const override;
private:
	LoveRuntime *_runtime = nullptr;
	mutable std::vector<TouchInfo> _activeTouches;
	mutable TouchInfo _selectedTouch{};
};

class DoraLoveJoystick final : public ::love::joystick::Joystick
{
public:
	DoraLoveJoystick(LoveRuntime *valueRuntime, int valueId) : runtime(valueRuntime), id(valueId) { }
	bool open(int deviceindex) override;
	void close() override;
	bool isConnected() const override;
	const char *getName() const override;
	int getAxisCount() const override;
	int getButtonCount() const override;
	int getHatCount() const override;
	float getAxis(int axisindex) const override;
	std::vector<float> getAxes() const override;
	Hat getHat(int hatindex) const override;
	bool isDown(const std::vector<int> &buttonlist) const override;
	bool openGamepad(int deviceindex) override { return open(deviceindex); }
	bool isGamepad() const override { return true; }
	float getGamepadAxis(GamepadAxis axis) const override;
	bool isGamepadDown(const std::vector<GamepadButton> &buttons) const override;
	JoystickInput getGamepadMapping(const GamepadInput &input) const override;
	std::string getGamepadMappingString() const override;
	void *getHandle() const override { return nullptr; }
	std::string getGUID() const override;
	int getInstanceID() const override;
	int getID() const override { return id; }
	void getDeviceInfo(int &vendorID, int &productID, int &productVersion) const override;
	bool isVibrationSupported() override;
	bool setVibration(float left, float right, float duration) override;
	bool setVibration() override { return setVibration(0.0f, 0.0f, 0.0f); }
	void getVibration(float &left, float &right) override;
	LoveRuntime *runtime = nullptr;
	int id = -1;
};

class DoraLoveJoystickModule final : public ::love::joystick::JoystickModule
{
public:
	explicit DoraLoveJoystickModule(LoveRuntime *runtime) : _runtime(runtime) { }
	const char *getName() const override { return "love.joystick"; }
	::love::joystick::Joystick *addJoystick(int deviceindex) override;
	void removeJoystick(::love::joystick::Joystick *joystick) override;
	::love::joystick::Joystick *getJoystickFromID(int instanceid) override;
	::love::joystick::Joystick *getJoystick(int joyindex) override;
	int getIndex(const ::love::joystick::Joystick *joystick) override;
	int getJoystickCount() const override;
	bool setGamepadMapping(const std::string &guid, ::love::joystick::Joystick::GamepadInput gpinput,
		::love::joystick::Joystick::JoystickInput joyinput) override;
	void loadGamepadMappings(const std::string &mappings) override;
	std::string saveGamepadMappings() override;
	std::string getGamepadMappingString(const std::string &guid) const override;
private:
	LoveRuntime *_runtime = nullptr;
};

struct ThreadFilesystemRequest
{
	std::mutex mutex;
	std::condition_variable changed;
	std::function<void()> work;
	bool done = false;
	bool cancelled = false;
};

struct ThreadValue
{
	enum class Type { Nil, Boolean, Number, String, Data, ImageData, Table, Channel };
	Type type = Type::Nil;
	bool boolean = false;
	double number = 0.0;
	std::string string;
	std::vector<std::uint8_t> data;
	int width = 0;
	int height = 0;
	std::string format;
	std::vector<std::pair<ThreadValue, ThreadValue>> table;
	std::shared_ptr<ThreadChannel> channel;
};

class DoraLoveFilesystem final : public ::love::filesystem::Filesystem
{
public:
	explicit DoraLoveFilesystem(LoveRuntime *runtime) : _runtime(runtime) { }
	const char *getName() const override { return "love.filesystem"; }
	void init(const char *) override { }
	void setFused(bool) override { }
	bool isFused() const override { return false; }
	bool setupWriteDirectory() override;
	bool setIdentity(const char *identity, bool appendToPath) override;
	const char *getIdentity() const override;
	bool setSource(const char *source) override;
	const char *getSource() const override;
	bool mount(const char *archive, const char *mountpoint, bool appendToPath) override;
	bool mount(::love::Data *data, const char *archiveName, const char *mountpoint, bool appendToPath) override;
	bool unmount(const char *archive) override;
	bool unmount(::love::Data *data) override;
	::love::filesystem::File *newFile(const char *filename) const override;
	const char *getWorkingDirectory() override;
	std::string getUserDirectory() override;
	std::string getAppdataDirectory() override;
	const char *getSaveDirectory() override;
	std::string getSourceBaseDirectory() const override;
	std::string getRealDirectory(const char *filename) const override;
	bool getInfo(const char *filepath, Info &info) const override;
	bool createDirectory(const char *directory) override;
	bool remove(const char *file) override;
	::love::filesystem::FileData *read(const char *filename,
		::love::int64 size = ::love::filesystem::File::ALL) const override;
	void write(const char *filename, const void *data, ::love::int64 size) const override;
	void append(const char *filename, const void *data, ::love::int64 size) const override;
	void getDirectoryItems(const char *directory, std::vector<std::string> &items) override;
	void setSymlinksEnabled(bool) override { }
	bool areSymlinksEnabled() const override { return false; }
	std::vector<std::string> &getRequirePath() override;
	std::vector<std::string> &getCRequirePath() override { return _cRequirePath; }
	void allowMountingForPath(const std::string &) override { }
	std::string getExecutablePath() const override;

private:
	LoveRuntime *_runtime = nullptr;
	std::vector<std::string> _cRequirePath;
};

class DoraLoveSound final : public ::love::sound::Sound
{
public:
	explicit DoraLoveSound(LoveRuntime *runtime) : _runtime(runtime) { }
	const char *getName() const override { return "love.sound"; }
	::love::sound::Decoder *newDecoder(::love::filesystem::FileData *file,
		int bufferSize) override;

private:
	LoveRuntime *_runtime = nullptr;
};

class DoraLoveImage final : public ::love::image::Image
{
public:
	explicit DoraLoveImage(LoveRuntime *runtime) : _runtime(runtime) { }
	const char *getName() const override { return "love.image.dora"; }
	::love::image::ImageData *newImageData(::love::Data *data) override;
	::love::image::ImageData *newImageData(int width, int height,
		::love::PixelFormat format) override;
	::love::image::ImageData *newImageData(int width, int height,
		::love::PixelFormat format, void *data, bool own) override;
	::love::image::CompressedImageData *newCompressedData(::love::Data *data) override;
	bool isCompressed(::love::Data *data) override;

private:
	LoveRuntime *_runtime = nullptr;
};

class DoraLoveFont final : public ::love::font::Font
{
public:
	explicit DoraLoveFont(LoveRuntime *runtime) : _runtime(runtime) { }
	const char *getName() const override { return "love.font"; }
	::love::font::Rasterizer *newRasterizer(::love::filesystem::FileData *data) override;
	::love::font::Rasterizer *newTrueTypeRasterizer(int size,
		::love::font::TrueTypeRasterizer::Hinting hinting) override;
	::love::font::Rasterizer *newTrueTypeRasterizer(int size, float dpiScale,
		::love::font::TrueTypeRasterizer::Hinting hinting) override;
	::love::font::Rasterizer *newTrueTypeRasterizer(::love::Data *data, int size,
		::love::font::TrueTypeRasterizer::Hinting hinting) override;
	::love::font::Rasterizer *newTrueTypeRasterizer(::love::Data *data, int size,
		float dpiScale, ::love::font::TrueTypeRasterizer::Hinting hinting) override;
	::love::font::Rasterizer *newBMFontRasterizer(::love::filesystem::FileData *fontDefinition,
		const std::vector<::love::image::ImageData *> &images, float dpiScale) override;
	::love::font::Rasterizer *newImageRasterizer(::love::image::ImageData *data,
		const std::string &glyphs, int extraSpacing, float dpiScale) override;
	::love::font::Rasterizer *newImageRasterizer(::love::image::ImageData *data,
		::love::uint32 *glyphs, int length, int extraSpacing, float dpiScale) override;
	::love::font::GlyphData *newGlyphData(::love::font::Rasterizer *rasterizer,
		const std::string &glyph) override;
	::love::font::GlyphData *newGlyphData(::love::font::Rasterizer *rasterizer,
		::love::uint32 glyph) override;

private:
	LoveRuntime *_runtime = nullptr;
};

struct ThreadChannel
{
	struct Entry { std::uint64_t id = 0; ThreadValue value; };
	std::recursive_mutex mutex;
	std::condition_variable_any changed;
	std::deque<Entry> values;
	std::uint64_t nextId = 1;
	std::uint64_t lastReadId = 0;
	std::weak_ptr<ThreadContext> context;
};

struct ThreadContext
{
	std::mutex mutex;
	std::unordered_map<std::string, std::shared_ptr<ThreadChannel>> namedChannels;
	std::vector<std::weak_ptr<ThreadChannel>> channels;
	std::vector<std::shared_ptr<ThreadWorker>> workers;
	std::mutex errorMutex;
	std::vector<std::pair<std::weak_ptr<ThreadWorker>, std::string>> pendingErrors;
	std::mutex filesystemMutex;
	std::deque<std::shared_ptr<ThreadFilesystemRequest>> filesystemRequests;
	std::atomic<bool> stopping = false;
};

class ThreadFilesystemBackend final : public FilesystemBackend
{
public:
	ThreadFilesystemBackend(std::shared_ptr<ThreadContext> context, FilesystemBackend *backend)
		: _context(std::move(context)), _backend(backend) { }

	bool exist(const std::string &path) const override
	{
		return invoke(false, [&]() { return _backend->exist(path); });
	}
	bool isFolder(const std::string &path) const override
	{
		return invoke(false, [&]() { return _backend->isFolder(path); });
	}
	bool load(const std::string &path, std::string &data, std::string &error) const override
	{
		return invoke(false, [&]() { return _backend->load(path, data, error); });
	}
	bool save(const std::string &path, std::string_view data, std::string &error) override
	{
		const std::string copy(data);
		return invoke(false, [&]() { return _backend->save(path, copy, error); });
	}
	bool createFolder(const std::string &path, std::string &error) override
	{
		return invoke(false, [&]() { return _backend->createFolder(path, error); });
	}
	bool remove(const std::string &path, std::string &error) override
	{
		return invoke(false, [&]() { return _backend->remove(path, error); });
	}
	std::optional<std::uint64_t> getFileSize(const std::string &path) const override
	{
		return invoke(std::optional<std::uint64_t>{}, [&]() { return _backend->getFileSize(path); });
	}
	std::vector<std::string> getDirectoryItems(const std::string &path) const override
	{
		return invoke(std::vector<std::string>{}, [&]() { return _backend->getDirectoryItems(path); });
	}
	std::string getExecutablePath() const override
	{
		return invoke(std::string{}, [&]() { return _backend->getExecutablePath(); });
	}
	bool mountArchive(std::string_view archiveName, std::string_view data,
		std::string &mountedRoot, std::string &error) override
	{
		const std::string nameCopy(archiveName);
		const std::string dataCopy(data);
		return invoke(false, [&]() {
			return _backend->mountArchive(nameCopy, dataCopy, mountedRoot, error);
		});
	}
	void unmountArchive(const std::string &mountedRoot) override
	{
		invoke(false, [&]() { _backend->unmountArchive(mountedRoot); return true; });
	}

private:
	template <class Result, class Callback>
	Result invoke(Result fallback, Callback callback) const
	{
		if (!_backend || !_context || _context->stopping.load(std::memory_order_acquire))
			return fallback;
		Result result = fallback;
		auto request = std::make_shared<ThreadFilesystemRequest>();
		request->work = [&]() { result = callback(); };
		{
			std::lock_guard lock(_context->filesystemMutex);
			_context->filesystemRequests.push_back(request);
		}
		std::unique_lock lock(request->mutex);
		request->changed.wait(lock, [&]() {
			return request->done || _context->stopping.load(std::memory_order_acquire);
		});
		if (!request->done)
		{
			request->cancelled = true;
			request->work = {};
			return fallback;
		}
		return result;
	}

	std::shared_ptr<ThreadContext> _context;
	FilesystemBackend *_backend = nullptr;
};

class ThreadImageBackend final : public ImageBackend
{
public:
	ThreadImageBackend(std::shared_ptr<ThreadContext> context, ImageBackend *backend)
		: _context(std::move(context)), _backend(backend) { }

	bool decodeImage(std::string_view encoded, int &width, int &height,
		std::vector<std::uint8_t> &rgba8, std::string &error) override
	{
		const std::string copy(encoded);
		return invoke([&]() { return _backend->decodeImage(copy, width, height, rgba8, error); });
	}
	bool decodeCompressedImage(std::string_view encoded, CompressedImage &image,
		std::string &error) override
	{
		const std::string copy(encoded);
		return invoke([&]() { return _backend->decodeCompressedImage(copy, image, error); });
	}
	bool encodeImage(std::string_view format, int width, int height,
		std::span<const std::uint8_t> rgba8, std::vector<std::uint8_t> &encoded,
		std::string &error) override
	{
		const std::string formatCopy(format);
		const std::vector<std::uint8_t> pixels(rgba8.begin(), rgba8.end());
		return invoke([&]() {
			return _backend->encodeImage(formatCopy, width, height, pixels, encoded, error);
		});
	}

private:
	template <class Callback>
	bool invoke(Callback callback) const
	{
		if (!_backend || !_context || _context->stopping.load(std::memory_order_acquire))
			return false;
		bool result = false;
		auto request = std::make_shared<ThreadFilesystemRequest>();
		request->work = [&]() { result = callback(); };
		{
			std::lock_guard lock(_context->filesystemMutex);
			_context->filesystemRequests.push_back(request);
		}
		std::unique_lock lock(request->mutex);
		request->changed.wait(lock, [&]() {
			return request->done || _context->stopping.load(std::memory_order_acquire);
		});
		if (!request->done)
		{
			request->cancelled = true;
			request->work = {};
			return false;
		}
		return result;
	}

	std::shared_ptr<ThreadContext> _context;
	ImageBackend *_backend = nullptr;
};

struct ThreadWorker
{
	~ThreadWorker()
	{
		if (worker.joinable()) worker.join();
	}
	std::mutex mutex;
	std::thread worker;
	std::string code;
	std::string chunkName;
	std::vector<ThreadValue> arguments;
	std::shared_ptr<ThreadContext> context;
	FilesystemBackend *filesystem = nullptr;
	ImageBackend *image = nullptr;
	std::string sourceRoot;
	std::string saveBaseRoot;
	std::string identity;
	std::unordered_map<std::string, std::string> preloadModules;
	bool running = false;
	bool started = false;
	std::string error;
};

class DoraLoveChannel;

bool threadValueFromVariant(const ::love::Variant &variant, ThreadValue &value,
	std::string &error, int depth = 0);
::love::Variant threadValueToVariant(LoveRuntime *runtime, const ThreadValue &value);

class DoraLoveLuaThread final : public ::love::thread::LuaThread
{
public:
	DoraLoveLuaThread(LoveRuntime *runtime, std::shared_ptr<ThreadWorker> worker)
		: _runtime(runtime), _worker(std::move(worker)) { }
	bool start(const std::vector<::love::Variant> &args) override;
	void wait() override;
	bool isRunning() const override;
	const std::string &getError() const override;
	bool hasError() const override;
	const std::shared_ptr<ThreadWorker> &worker() const noexcept { return _worker; }

private:
	LoveRuntime *_runtime = nullptr;
	std::shared_ptr<ThreadWorker> _worker;
};

class DoraLoveChannel final : public ::love::thread::Channel
{
public:
	DoraLoveChannel(LoveRuntime *runtime, std::shared_ptr<ThreadChannel> channel)
		: _runtime(runtime), _channel(std::move(channel)) { }
	::love::uint64 push(const ::love::Variant &variant) override;
	bool supply(const ::love::Variant &variant) override;
	bool supply(const ::love::Variant &variant, double timeout) override;
	bool pop(::love::Variant *variant) override;
	bool demand(::love::Variant *variant) override;
	bool demand(::love::Variant *variant, double timeout) override;
	bool peek(::love::Variant *variant) override;
	int getCount() const override;
	bool hasRead(::love::uint64 id) const override;
	void clear() override;
	const std::shared_ptr<ThreadChannel> &channel() const noexcept { return _channel; }
	LoveRuntime *runtime() const noexcept { return _runtime; }

private:
	void lockMutex() override { _channel->mutex.lock(); }
	void unlockMutex() override { _channel->mutex.unlock(); }
	bool waitForRead(::love::uint64 id, std::optional<double> timeout);
	bool waitForValue(::love::Variant *variant, std::optional<double> timeout);
	LoveRuntime *_runtime = nullptr;
	std::shared_ptr<ThreadChannel> _channel;
};

class DoraLoveThreadModule final : public ::love::thread::ThreadModule
{
public:
	explicit DoraLoveThreadModule(LoveRuntime *runtime) : _runtime(runtime) { }
	::love::thread::LuaThread *newThread(const std::string &name,
		::love::Data *data) override;
	::love::thread::Channel *newChannel() override;
	::love::thread::Channel *getChannel(const std::string &name) override;
	DoraLoveChannel *newChannel(std::shared_ptr<ThreadChannel> channel);
	DoraLoveLuaThread *threadForWorker(const std::shared_ptr<ThreadWorker> &worker);

private:
	LoveRuntime *_runtime = nullptr;
	std::unordered_map<std::string, ::love::StrongRef<DoraLoveChannel>> _namedChannels;
	std::unordered_map<ThreadWorker *, ::love::StrongRef<DoraLoveLuaThread>> _threads;
};

namespace
{
constexpr const char *AudioSourceRegistry = "Dora.Love.AudioSource.Registry";
constexpr const char *RecordingDeviceRegistry = "Dora.Love.RecordingDevice.Registry";
constexpr const char *ThreadContextRegistry = "Dora.Love.Thread.Context";
constexpr const char *LoveRuntimeRegistry = "Dora.Love.Runtime";

struct DataSpan
{
	const std::uint8_t *bytes = nullptr;
	std::size_t size = 0;
};

void pushThreadData(lua_State *state, const std::vector<std::uint8_t> &bytes);
void pushThreadImageData(lua_State *state, const ThreadValue &value);

void pushThreadValue(lua_State *state, const ThreadValue &value)
{
	switch (value.type)
	{
		case ThreadValue::Type::Nil: lua_pushnil(state); break;
		case ThreadValue::Type::Boolean: lua_pushboolean(state, value.boolean); break;
		case ThreadValue::Type::Number: lua_pushnumber(state, value.number); break;
		case ThreadValue::Type::String:
			lua_pushlstring(state, value.string.data(), value.string.size()); break;
		case ThreadValue::Type::Data:
			pushThreadData(state, value.data); break;
		case ThreadValue::Type::ImageData:
			pushThreadImageData(state, value); break;
		case ThreadValue::Type::Channel:
		{
			auto *module = ::love::luax_getmodule<::love::thread::ThreadModule>(
				state, ::love::Module::M_THREAD);
			auto *doraModule = dynamic_cast<DoraLoveThreadModule *>(module);
			if (!doraModule)
				throw ::love::Exception("Love thread Channel is not attached to the current Dora Lua State");
			auto *channel = doraModule->newChannel(value.channel);
			::love::luax_pushtype(state, channel);
			channel->release();
			break;
		}
		case ThreadValue::Type::Table:
			lua_createtable(state, 0, static_cast<int>(value.table.size()));
			for (const auto &[key, item] : value.table)
			{
				pushThreadValue(state, key);
				pushThreadValue(state, item);
				lua_rawset(state, -3);
			}
			break;
	}
}

bool threadContextStopping(const std::shared_ptr<ThreadChannel> &channel)
{
	const auto context = channel ? channel->context.lock() : nullptr;
	return context && context->stopping.load(std::memory_order_acquire);
}

void threadCancellationHook(lua_State *state, lua_Debug *)
{
	lua_getfield(state, LUA_REGISTRYINDEX, ThreadContextRegistry);
	auto *context = static_cast<ThreadContext *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	if (context && context->stopping.load(std::memory_order_acquire))
		luaL_error(state, "Love thread stopped because its runtime is closing");
}

std::string incompatibleBytecodeError(std::string_view code)
{
	if (code.size() >= 3 && static_cast<unsigned char>(code[0]) == 0x1b
		&& code[1] == 'L' && code[2] == 'J')
		return "Dora Love runtime uses Lua 5.5 and cannot load LuaJIT bytecode; provide Lua source or recompile it with Lua 5.5";
	if (code.size() >= 5 && static_cast<unsigned char>(code[0]) == 0x1b
		&& code.substr(1, 3) == "Lua")
	{
		const auto version = static_cast<unsigned char>(code[4]);
		constexpr unsigned char CurrentVersion =
			static_cast<unsigned char>(((LUA_VERSION_NUM / 100) << 4) | (LUA_VERSION_NUM % 100));
		if (version != CurrentVersion)
		{
			const int major = version >> 4;
			const int minor = version & 0x0f;
			return "Dora Love runtime uses Lua 5.5 and cannot load Lua "
				+ std::to_string(major) + "." + std::to_string(minor)
				+ " bytecode; provide Lua source or recompile it with Lua 5.5";
		}
	}
	else if (!code.empty() && static_cast<unsigned char>(code[0]) == 0x1b)
		return "Dora Love runtime uses Lua 5.5 and cannot load this precompiled bytecode; provide Lua source or recompile it with Lua 5.5";
	return {};
}

int loadLoveChunk(lua_State *state, std::string_view code, const char *chunkName)
{
	if (code.size() >= 3
		&& static_cast<unsigned char>(code[0]) == 0xef
		&& static_cast<unsigned char>(code[1]) == 0xbb
		&& static_cast<unsigned char>(code[2]) == 0xbf)
		code.remove_prefix(3);
	const std::string compatibilityError = incompatibleBytecodeError(code);
	if (!compatibilityError.empty())
	{
		lua_pushlstring(state, compatibilityError.data(), compatibilityError.size());
		return LUA_ERRSYNTAX;
	}
	return luaL_loadbufferx(state, code.data(), code.size(), chunkName, "bt");
}
constexpr int DefaultWindowWidth = 800;
constexpr int DefaultWindowHeight = 600;
constexpr int MaximumWindowDimension = 16384;
constexpr std::size_t MaximumSoundDataBytes = 256 * 1024 * 1024;
constexpr std::size_t MaximumLoveDataBytes = 256 * 1024 * 1024;

void initializeLoveFloatTypes()
{
	static std::once_flag initialized;
	std::call_once(initialized, [] { ::love::float16Init(); });
}

int totalImageMipmapCount(int width, int height, int depth = 1)
{
	int dimension = std::max({width, height, depth});
	int count = 1;
	while (dimension > 1)
	{
		dimension >>= 1;
		++count;
	}
	return count;
}

GraphicsBackend::ImageLevel downsampleImageLevel(
	const GraphicsBackend::ImageLevel &source, GraphicsBackend::TextureType type)
{
	GraphicsBackend::ImageLevel result;
	result.width = std::max(1, source.width / 2);
	result.height = std::max(1, source.height / 2);
	result.slices = type == GraphicsBackend::TextureType::Volume
		? std::max(1, source.slices / 2) : source.slices;
	result.rgba8.resize(static_cast<std::size_t>(result.width) * result.height
		* result.slices * 4);
	const int zSamples = type == GraphicsBackend::TextureType::Volume && source.slices > 1 ? 2 : 1;
	for (int z = 0; z < result.slices; ++z)
		for (int y = 0; y < result.height; ++y)
			for (int x = 0; x < result.width; ++x)
				for (int channel = 0; channel < 4; ++channel)
				{
					unsigned int sum = 0;
					int samples = 0;
					for (int dz = 0; dz < zSamples; ++dz)
						for (int dy = 0; dy < (source.height > 1 ? 2 : 1); ++dy)
							for (int dx = 0; dx < (source.width > 1 ? 2 : 1); ++dx)
							{
								const int sourceX = std::min(source.width - 1, x * 2 + dx);
								const int sourceY = std::min(source.height - 1, y * 2 + dy);
								const int sourceZ = std::min(source.slices - 1, z * 2 + dz);
								const auto offset = ((static_cast<std::size_t>(sourceZ) * source.height
									+ sourceY) * source.width + sourceX) * 4 + channel;
								sum += source.rgba8[offset];
								++samples;
							}
					const auto destination = ((static_cast<std::size_t>(z) * result.height
						+ y) * result.width + x) * 4 + channel;
					result.rgba8[destination] = static_cast<std::uint8_t>((sum + samples / 2) / samples);
				}
	return result;
}

void generateImageMipmaps(std::vector<GraphicsBackend::ImageLevel> &levels,
	GraphicsBackend::TextureType type)
{
	if (levels.size() != 1) return;
	const int count = totalImageMipmapCount(levels.front().width, levels.front().height,
		type == GraphicsBackend::TextureType::Volume ? levels.front().slices : 1);
	levels.reserve(static_cast<std::size_t>(count));
	while (static_cast<int>(levels.size()) < count)
		levels.push_back(downsampleImageLevel(levels.back(), type));
}

bool decodeUtf8(std::string_view text, std::vector<std::uint32_t> &codepoints,
	std::string &error)
{
	codepoints.clear();
	for (std::size_t offset = 0; offset < text.size();)
	{
		const auto first = static_cast<std::uint8_t>(text[offset]);
		std::size_t length = 0;
		std::uint32_t codepoint = 0;
		if (first < 0x80) { length = 1; codepoint = first; }
		else if ((first & 0xe0) == 0xc0) { length = 2; codepoint = first & 0x1f; }
		else if ((first & 0xf0) == 0xe0) { length = 3; codepoint = first & 0x0f; }
		else if ((first & 0xf8) == 0xf0) { length = 4; codepoint = first & 0x07; }
		else { error = "invalid UTF-8 leading byte"; return false; }
		if (offset + length > text.size()) { error = "truncated UTF-8 sequence"; return false; }
		for (std::size_t index = 1; index < length; ++index)
		{
			const auto byte = static_cast<std::uint8_t>(text[offset + index]);
			if ((byte & 0xc0) != 0x80) { error = "invalid UTF-8 continuation byte"; return false; }
			codepoint = (codepoint << 6) | (byte & 0x3f);
		}
		const std::uint32_t minimum = length == 1 ? 0 : length == 2 ? 0x80 : length == 3 ? 0x800 : 0x10000;
		if (codepoint < minimum || codepoint > 0x10ffff
			|| (codepoint >= 0xd800 && codepoint <= 0xdfff))
		{
			error = "invalid or overlong UTF-8 codepoint";
			return false;
		}
		codepoints.push_back(codepoint);
		offset += length;
	}
	error.clear();
	return true;
}

std::string encodeUtf8(std::uint32_t codepoint)
{
	std::string result;
	if (codepoint <= 0x7f)
		result.push_back(static_cast<char>(codepoint));
	else if (codepoint <= 0x7ff)
	{
		result.push_back(static_cast<char>(0xc0 | (codepoint >> 6)));
		result.push_back(static_cast<char>(0x80 | (codepoint & 0x3f)));
	}
	else if (codepoint <= 0xffff)
	{
		result.push_back(static_cast<char>(0xe0 | (codepoint >> 12)));
		result.push_back(static_cast<char>(0x80 | ((codepoint >> 6) & 0x3f)));
		result.push_back(static_cast<char>(0x80 | (codepoint & 0x3f)));
	}
	else
	{
		result.push_back(static_cast<char>(0xf0 | (codepoint >> 18)));
		result.push_back(static_cast<char>(0x80 | ((codepoint >> 12) & 0x3f)));
		result.push_back(static_cast<char>(0x80 | ((codepoint >> 6) & 0x3f)));
		result.push_back(static_cast<char>(0x80 | (codepoint & 0x3f)));
	}
	return result;
}

double steadySeconds()
{
	return std::chrono::duration<double>(std::chrono::steady_clock::now().time_since_epoch()).count();
}

enum class ImagePixelFormat
{
	R8, RG8, RGBA8, R16, RG16, RGBA16, R16F, RG16F, RGBA16F,
	R32F, RG32F, RGBA32F, RGBA4, RGB5A1, RGB565, RGB10A2, RG11B10F,
};

struct ImagePixelFormatInfo
{
	ImagePixelFormat value;
	const char *name;
	std::size_t bytes;
};

const ImagePixelFormatInfo *imagePixelFormatInfo(std::string_view format)
{
	static constexpr ImagePixelFormatInfo formats[] = {
		{ImagePixelFormat::R8, "r8", 1}, {ImagePixelFormat::RG8, "rg8", 2},
		{ImagePixelFormat::RGBA8, "rgba8", 4}, {ImagePixelFormat::R16, "r16", 2},
		{ImagePixelFormat::RG16, "rg16", 4}, {ImagePixelFormat::RGBA16, "rgba16", 8},
		{ImagePixelFormat::R16F, "r16f", 2}, {ImagePixelFormat::RG16F, "rg16f", 4},
		{ImagePixelFormat::RGBA16F, "rgba16f", 8}, {ImagePixelFormat::R32F, "r32f", 4},
		{ImagePixelFormat::RG32F, "rg32f", 8}, {ImagePixelFormat::RGBA32F, "rgba32f", 16},
		{ImagePixelFormat::RGBA4, "rgba4", 2}, {ImagePixelFormat::RGB5A1, "rgb5a1", 2},
		{ImagePixelFormat::RGB565, "rgb565", 2}, {ImagePixelFormat::RGB10A2, "rgb10a2", 4},
		{ImagePixelFormat::RG11B10F, "rg11b10f", 4},
	};
	const auto found = std::find_if(std::begin(formats), std::end(formats),
		[format](const auto &entry) { return format == entry.name; });
	return found == std::end(formats) ? nullptr : found;
}

struct ImagePixelColor
{
	float red = 0.0f;
	float green = 0.0f;
	float blue = 0.0f;
	float alpha = 1.0f;
};

template <class T> T loadPixelValue(const std::uint8_t *bytes)
{
	T value{};
	std::memcpy(&value, bytes, sizeof(value));
	return value;
}

template <class T> void storePixelValue(std::uint8_t *bytes, T value)
{
	std::memcpy(bytes, &value, sizeof(value));
}

float clampPixel(float value)
{
	return std::clamp(value, 0.0f, 1.0f);
}

void initializeLoveFloatFormats()
{
	static const bool initialized = []() {
		::love::float16Init();
		return true;
	}();
	(void)initialized;
}

bool readImagePixel(const ImagePixelFormatInfo &format, const std::uint8_t *bytes,
	ImagePixelColor &color)
{
	initializeLoveFloatFormats();
	color = {};
	switch (format.value)
	{
		case ImagePixelFormat::R8:
			color.red = bytes[0] / 255.0f; break;
		case ImagePixelFormat::RG8:
			color.red = bytes[0] / 255.0f; color.green = bytes[1] / 255.0f; break;
		case ImagePixelFormat::RGBA8:
			color.red = bytes[0] / 255.0f; color.green = bytes[1] / 255.0f;
			color.blue = bytes[2] / 255.0f; color.alpha = bytes[3] / 255.0f; break;
		case ImagePixelFormat::R16:
			color.red = loadPixelValue<std::uint16_t>(bytes) / 65535.0f; break;
		case ImagePixelFormat::RG16:
			color.red = loadPixelValue<std::uint16_t>(bytes) / 65535.0f;
			color.green = loadPixelValue<std::uint16_t>(bytes + 2) / 65535.0f; break;
		case ImagePixelFormat::RGBA16:
			color.red = loadPixelValue<std::uint16_t>(bytes) / 65535.0f;
			color.green = loadPixelValue<std::uint16_t>(bytes + 2) / 65535.0f;
			color.blue = loadPixelValue<std::uint16_t>(bytes + 4) / 65535.0f;
			color.alpha = loadPixelValue<std::uint16_t>(bytes + 6) / 65535.0f; break;
		case ImagePixelFormat::R16F:
			color.red = ::love::float16to32(loadPixelValue<::love::float16>(bytes)); break;
		case ImagePixelFormat::RG16F:
			color.red = ::love::float16to32(loadPixelValue<::love::float16>(bytes));
			color.green = ::love::float16to32(loadPixelValue<::love::float16>(bytes + 2)); break;
		case ImagePixelFormat::RGBA16F:
			color.red = ::love::float16to32(loadPixelValue<::love::float16>(bytes));
			color.green = ::love::float16to32(loadPixelValue<::love::float16>(bytes + 2));
			color.blue = ::love::float16to32(loadPixelValue<::love::float16>(bytes + 4));
			color.alpha = ::love::float16to32(loadPixelValue<::love::float16>(bytes + 6)); break;
		case ImagePixelFormat::R32F:
			color.red = loadPixelValue<float>(bytes); break;
		case ImagePixelFormat::RG32F:
			color.red = loadPixelValue<float>(bytes); color.green = loadPixelValue<float>(bytes + 4); break;
		case ImagePixelFormat::RGBA32F:
			color.red = loadPixelValue<float>(bytes); color.green = loadPixelValue<float>(bytes + 4);
			color.blue = loadPixelValue<float>(bytes + 8); color.alpha = loadPixelValue<float>(bytes + 12); break;
		case ImagePixelFormat::RGBA4:
		{
			const auto value = loadPixelValue<std::uint16_t>(bytes);
			color.red = ((value >> 12) & 0xf) / 15.0f; color.green = ((value >> 8) & 0xf) / 15.0f;
			color.blue = ((value >> 4) & 0xf) / 15.0f; color.alpha = (value & 0xf) / 15.0f; break;
		}
		case ImagePixelFormat::RGB5A1:
		{
			const auto value = loadPixelValue<std::uint16_t>(bytes);
			color.red = ((value >> 11) & 0x1f) / 31.0f; color.green = ((value >> 6) & 0x1f) / 31.0f;
			color.blue = ((value >> 1) & 0x1f) / 31.0f; color.alpha = value & 1; break;
		}
		case ImagePixelFormat::RGB565:
		{
			const auto value = loadPixelValue<std::uint16_t>(bytes);
			color.red = ((value >> 11) & 0x1f) / 31.0f; color.green = ((value >> 5) & 0x3f) / 63.0f;
			color.blue = (value & 0x1f) / 31.0f; break;
		}
		case ImagePixelFormat::RGB10A2:
		{
			const auto value = loadPixelValue<std::uint32_t>(bytes);
			color.red = (value & 0x3ff) / 1023.0f; color.green = ((value >> 10) & 0x3ff) / 1023.0f;
			color.blue = ((value >> 20) & 0x3ff) / 1023.0f; color.alpha = ((value >> 30) & 3) / 3.0f; break;
		}
		case ImagePixelFormat::RG11B10F:
		{
			const auto value = loadPixelValue<std::uint32_t>(bytes);
			color.red = ::love::float11to32(static_cast<::love::float11>(value & 0x7ff));
			color.green = ::love::float11to32(static_cast<::love::float11>((value >> 11) & 0x7ff));
			color.blue = ::love::float10to32(static_cast<::love::float10>((value >> 22) & 0x3ff)); break;
		}
	}
	return true;
}

bool writeImagePixel(const ImagePixelFormatInfo &format, std::uint8_t *bytes,
	const ImagePixelColor &color)
{
	initializeLoveFloatFormats();
	auto normalized = [](float value, float maximum) {
		return static_cast<std::uint32_t>(clampPixel(value) * maximum + 0.5f);
	};
	switch (format.value)
	{
		case ImagePixelFormat::R8: bytes[0] = static_cast<std::uint8_t>(normalized(color.red, 255)); break;
		case ImagePixelFormat::RG8:
			bytes[0] = static_cast<std::uint8_t>(normalized(color.red, 255));
			bytes[1] = static_cast<std::uint8_t>(normalized(color.green, 255)); break;
		case ImagePixelFormat::RGBA8:
			bytes[0] = static_cast<std::uint8_t>(normalized(color.red, 255));
			bytes[1] = static_cast<std::uint8_t>(normalized(color.green, 255));
			bytes[2] = static_cast<std::uint8_t>(normalized(color.blue, 255));
			bytes[3] = static_cast<std::uint8_t>(normalized(color.alpha, 255)); break;
		case ImagePixelFormat::R16:
			storePixelValue(bytes, static_cast<std::uint16_t>(normalized(color.red, 65535))); break;
		case ImagePixelFormat::RG16:
			storePixelValue(bytes, static_cast<std::uint16_t>(normalized(color.red, 65535)));
			storePixelValue(bytes + 2, static_cast<std::uint16_t>(normalized(color.green, 65535))); break;
		case ImagePixelFormat::RGBA16:
			storePixelValue(bytes, static_cast<std::uint16_t>(normalized(color.red, 65535)));
			storePixelValue(bytes + 2, static_cast<std::uint16_t>(normalized(color.blue, 65535)));
			storePixelValue(bytes + 4, static_cast<std::uint16_t>(normalized(color.green, 65535)));
			storePixelValue(bytes + 6, static_cast<std::uint16_t>(normalized(color.alpha, 65535))); break;
		case ImagePixelFormat::R16F:
			storePixelValue(bytes, ::love::float32to16(color.red)); break;
		case ImagePixelFormat::RG16F:
			storePixelValue(bytes, ::love::float32to16(color.red));
			storePixelValue(bytes + 2, ::love::float32to16(color.green)); break;
		case ImagePixelFormat::RGBA16F:
			storePixelValue(bytes, ::love::float32to16(color.red));
			storePixelValue(bytes + 2, ::love::float32to16(color.green));
			storePixelValue(bytes + 4, ::love::float32to16(color.blue));
			storePixelValue(bytes + 6, ::love::float32to16(color.alpha)); break;
		case ImagePixelFormat::R32F: storePixelValue(bytes, color.red); break;
		case ImagePixelFormat::RG32F:
			storePixelValue(bytes, color.red); storePixelValue(bytes + 4, color.green); break;
		case ImagePixelFormat::RGBA32F:
			storePixelValue(bytes, color.red); storePixelValue(bytes + 4, color.green);
			storePixelValue(bytes + 8, color.blue); storePixelValue(bytes + 12, color.alpha); break;
		case ImagePixelFormat::RGBA4:
			storePixelValue(bytes, static_cast<std::uint16_t>((normalized(color.red, 15) << 12)
				| (normalized(color.green, 15) << 8) | (normalized(color.blue, 15) << 4)
				| normalized(color.alpha, 15))); break;
		case ImagePixelFormat::RGB5A1:
			storePixelValue(bytes, static_cast<std::uint16_t>((normalized(color.red, 31) << 11)
				| (normalized(color.green, 31) << 6) | (normalized(color.blue, 31) << 1)
				| normalized(color.alpha, 1))); break;
		case ImagePixelFormat::RGB565:
			storePixelValue(bytes, static_cast<std::uint16_t>((normalized(color.red, 31) << 11)
				| (normalized(color.green, 63) << 5) | normalized(color.blue, 31))); break;
		case ImagePixelFormat::RGB10A2:
			storePixelValue(bytes, normalized(color.red, 1023) | (normalized(color.green, 1023) << 10)
				| (normalized(color.blue, 1023) << 20) | (normalized(color.alpha, 3) << 30)); break;
		case ImagePixelFormat::RG11B10F:
			storePixelValue(bytes, static_cast<std::uint32_t>(::love::float32to11(color.red))
				| (static_cast<std::uint32_t>(::love::float32to11(color.green)) << 11)
				| (static_cast<std::uint32_t>(::love::float32to10(color.blue)) << 22)); break;
	}
	return true;
}

template <class Handle, void (LoveRuntime::*Retain)(Handle) noexcept,
	void (LoveRuntime::*Release)(Handle) noexcept,
	void (LoveRuntime::*Forget)(Handle) noexcept, class Base = ::love::Object>
struct DoraHandleObject : Base
{
	DoraHandleObject() = default;
	DoraHandleObject(LoveRuntime *valueRuntime, Handle valueHandle)
		: runtime(valueRuntime)
	{
		adoptDoraHandle(valueHandle);
	}
	template <class... Args>
	DoraHandleObject(LoveRuntime *valueRuntime, Handle valueHandle,
		std::in_place_t, Args &&...args)
		: Base(std::forward<Args>(args)...), runtime(valueRuntime)
	{
		adoptDoraHandle(valueHandle);
	}
	~DoraHandleObject() override { releaseDoraHandle(); }

	DoraHandleObject(const DoraHandleObject &) = delete;
	DoraHandleObject &operator=(const DoraHandleObject &) = delete;

	void releaseDoraHandle() noexcept
	{
		if (runtime && handle != Handle{})
		{
			const auto value = handle;
			handle = Handle{};
			(runtime->*Release)(value);
		}
	}

	void invalidateDoraHandle() noexcept
	{
		if (runtime && handle != Handle{})
			(runtime->*Forget)(handle);
		handle = Handle{};
	}

	void adoptDoraHandle(Handle valueHandle) noexcept
	{
		handle = valueHandle;
		if (runtime && handle != Handle{})
			(runtime->*Retain)(handle);
	}

	void replaceDoraHandle(Handle valueHandle) noexcept
	{
		releaseDoraHandle();
		adoptDoraHandle(valueHandle);
	}

	LoveRuntime *runtime = nullptr;
	Handle handle{};
};

template <class Object>
void pushNewDoraHandleObject(lua_State *state, ::love::Type &type, Object *object)
{
	static_assert(std::is_base_of_v<::love::Object, Object>);
	::love::luax_pushtype(state, type, object);
	// A freshly constructed Love Object owns one native reference and the Proxy
	// retained another one above. Hand the constructor reference to the Proxy so
	// release()/__gc can actually destroy the wrapper and its Dora handle.
	object->release();
}

::love::graphics::TextureType toLoveTextureType(GraphicsBackend::TextureType type)
{
	switch (type)
	{
		case GraphicsBackend::TextureType::Array: return ::love::graphics::TEXTURE_2D_ARRAY;
		case GraphicsBackend::TextureType::Cube: return ::love::graphics::TEXTURE_CUBE;
		case GraphicsBackend::TextureType::Volume: return ::love::graphics::TEXTURE_VOLUME;
		case GraphicsBackend::TextureType::Texture2D: return ::love::graphics::TEXTURE_2D;
	}
	return ::love::graphics::TEXTURE_2D;
}

::love::graphics::Canvas::Settings toLoveCanvasSettings(int pixelWidth,
	int pixelHeight, const GraphicsBackend::CanvasSettings &value)
{
	::love::graphics::Canvas::Settings settings;
	settings.width = std::max(1, static_cast<int>(pixelWidth / value.dpiScale + 0.5f));
	settings.height = std::max(1, static_cast<int>(pixelHeight / value.dpiScale + 0.5f));
	settings.layers = value.slices;
	settings.type = toLoveTextureType(value.type);
	settings.dpiScale = value.dpiScale;
	settings.msaa = value.msaa;
	settings.readable = ::love::OptionalBool(value.readable);
	if (!::love::getConstant(value.format.data(), settings.format))
		settings.format = ::love::PIXELFORMAT_RGBA8;
	if (value.mipmapMode == "manual")
		settings.mipmaps = ::love::graphics::Canvas::MIPMAPS_MANUAL;
	else if (value.mipmapMode == "auto")
		settings.mipmaps = ::love::graphics::Canvas::MIPMAPS_AUTO;
	return settings;
}

::love::graphics::Image::Settings defaultLoveImageSettings()
{
	return {};
}

struct ImageUserdata final
	: DoraHandleObject<GraphicsBackend::ImageHandle, &LoveRuntime::retainLoveImageHandle,
		&LoveRuntime::releaseLoveImage, &LoveRuntime::forgetLoveImageHandle,
		::love::graphics::Image>
{
	using DoraHandle = DoraHandleObject<GraphicsBackend::ImageHandle,
		&LoveRuntime::retainLoveImageHandle, &LoveRuntime::releaseLoveImage,
		&LoveRuntime::forgetLoveImageHandle, ::love::graphics::Image>;
	static ::love::Type &type;
	ImageUserdata(LoveRuntime *valueRuntime, GraphicsBackend::ImageHandle valueHandle,
		GraphicsBackend::TextureType valueType, int valueSlices)
		: DoraHandle(valueRuntime, valueHandle, std::in_place,
			toLoveTextureType(valueType), ::love::PIXELFORMAT_RGBA8,
			valueRuntime && valueRuntime->getGraphicsBackend()
				? valueRuntime->getGraphicsBackend()->getImageWidth(valueHandle) : 1,
			valueRuntime && valueRuntime->getGraphicsBackend()
				? valueRuntime->getGraphicsBackend()->getImageHeight(valueHandle) : 1,
			valueSlices, defaultLoveImageSettings()),
		  textureType(valueType), slices(valueSlices) { }
	ptrdiff_t getHandle() const override { return static_cast<ptrdiff_t>(handle); }
	bool validateDimensions(bool) const override { return runtime && handle != 0; }
	void setFilter(const ::love::graphics::Texture::Filter &value) override;
	bool setWrap(const ::love::graphics::Texture::Wrap &value) override;
	bool setMipmapSharpness(float value) override;
	void setDepthSampleMode(::love::Optional<::love::graphics::CompareMode> mode) override;
	void replacePixels(::love::image::ImageDataBase *data, int slice, int mipmap,
		int x, int y, bool reloadMipmaps) override;
	void replacePixels(const void *data, size_t size, int slice, int mipmap,
		const ::love::Rect &rect, bool reloadMipmaps) override;
	void uploadByteData(::love::PixelFormat format, const void *data, size_t size,
		int level, int slice, const ::love::Rect &rect) override;
	void generateMipmaps() override { }
	void syncUpstreamMetadata();
	GraphicsBackend::TextureType textureType = GraphicsBackend::TextureType::Texture2D;
	int slices = 1;
	GraphicsBackend::TextureFilter filter = GraphicsBackend::TextureFilter::Linear;
	GraphicsBackend::TextureFilter magFilter = GraphicsBackend::TextureFilter::Linear;
	GraphicsBackend::TextureWrap wrapU = GraphicsBackend::TextureWrap::Clamp;
	GraphicsBackend::TextureWrap wrapV = GraphicsBackend::TextureWrap::Clamp;
	GraphicsBackend::TextureWrap wrapW = GraphicsBackend::TextureWrap::Clamp;
	float anisotropy = 1.0f;
	int mipmapCount = 1;
	float dpiScale = 1.0f;
	std::string format = "rgba8";
	bool readable = true;
	bool compressed = false;
	bool linear = true;
	std::optional<GraphicsBackend::TextureFilter> mipmapFilter;
	float mipmapSharpness = 0.0f;
	std::optional<std::string> depthSampleMode;
};

::love::Type &ImageUserdata::type = ::love::graphics::Image::type;

ImageUserdata *testImage(lua_State *state, int index)
{
	if (luaL_testudata(state, index, ImageUserdata::type.getName()) == nullptr) return nullptr;
	return ::love::luax_checktype<ImageUserdata>(state, index);
}

struct CanvasUserdata final
	: DoraHandleObject<GraphicsBackend::CanvasHandle, &LoveRuntime::retainLoveCanvasHandle,
		&LoveRuntime::releaseLoveCanvas, &LoveRuntime::forgetLoveCanvasHandle,
		::love::graphics::Canvas>
{
	using DoraHandle = DoraHandleObject<GraphicsBackend::CanvasHandle,
		&LoveRuntime::retainLoveCanvasHandle, &LoveRuntime::releaseLoveCanvas,
		&LoveRuntime::forgetLoveCanvasHandle, ::love::graphics::Canvas>;
	static ::love::Type &type;
	CanvasUserdata(LoveRuntime *valueRuntime, GraphicsBackend::CanvasHandle valueHandle,
		int pixelWidth, int pixelHeight, const GraphicsBackend::CanvasSettings &valueSettings)
		: DoraHandle(valueRuntime, valueHandle, std::in_place,
			toLoveCanvasSettings(pixelWidth, pixelHeight, valueSettings)),
		  format(valueSettings.format.data()), msaa(valueSettings.msaa),
		  readable(valueSettings.readable) { }
	ptrdiff_t getHandle() const override { return static_cast<ptrdiff_t>(handle); }
	bool validateDimensions(bool) const override { return runtime && handle != 0; }
	void setFilter(const ::love::graphics::Texture::Filter &value) override;
	bool setWrap(const ::love::graphics::Texture::Wrap &value) override;
	bool setMipmapSharpness(float value) override;
	void setDepthSampleMode(::love::Optional<::love::graphics::CompareMode> mode) override;
	::love::image::ImageData *newImageData(::love::image::Image *module,
		int slice, int mipmap, const ::love::Rect &rect) override;
	void generateMipmaps() override;
	int getMSAA() const override { return msaa; }
	ptrdiff_t getRenderTargetHandle() const override { return static_cast<ptrdiff_t>(handle); }
	void syncUpstreamMetadata();
	const char *format = "rgba8";
	int msaa = 0;
	bool readable = true;
	GraphicsBackend::TextureFilter filter = GraphicsBackend::TextureFilter::Linear;
	GraphicsBackend::TextureWrap wrapU = GraphicsBackend::TextureWrap::Clamp;
	GraphicsBackend::TextureWrap wrapV = GraphicsBackend::TextureWrap::Clamp;
	GraphicsBackend::TextureWrap wrapW = GraphicsBackend::TextureWrap::Clamp;
	float anisotropy = 1.0f;
	GraphicsBackend::TextureType textureType = GraphicsBackend::TextureType::Texture2D;
	int slices = 1;
	int mipmapCount = 1;
	float dpiScale = 1.0f;
	std::string mipmapMode = "none";
	std::optional<GraphicsBackend::TextureFilter> mipmapFilter;
	float mipmapSharpness = 0.0f;
	std::optional<std::string> depthSampleMode;
};

::love::Type &CanvasUserdata::type = ::love::graphics::Canvas::type;

CanvasUserdata *testCanvas(lua_State *state, int index)
{
	if (luaL_testudata(state, index, CanvasUserdata::type.getName()) == nullptr) return nullptr;
	return ::love::luax_checktype<CanvasUserdata>(state, index);
}

bool isDepthStencilCanvasFormat(std::string_view format)
{
	return format == "stencil8" || format == "depth16" || format == "depth24"
		|| format == "depth32f" || format == "depth24stencil8"
		|| format == "depth32fstencil8";
}

bool canvasFormatHasDepth(std::string_view format)
{
	return format != "stencil8" && isDepthStencilCanvasFormat(format);
}

bool canvasFormatHasStencil(std::string_view format)
{
	return format == "stencil8" || format == "depth24stencil8"
		|| format == "depth32fstencil8";
}

struct LoveDataObject : ::love::Data
{
	virtual DataSpan dataSpan() const noexcept = 0;
	::love::Data *clone() const override
	{
		throw ::love::Exception("This Data subtype must be cloned through its owning Love module.");
	}
	void *getData() const override
	{
		return const_cast<std::uint8_t *>(dataSpan().bytes);
	}
	std::size_t getSize() const override { return dataSpan().size; }
};

class DoraImageData final : public ::love::image::ImageData
{
public:
	DoraImageData(LoveRuntime *runtime, int width, int height,
		::love::PixelFormat format)
		: ImageData(width, height, format), _runtime(runtime) { }
	DoraImageData(LoveRuntime *runtime, int width, int height,
		::love::PixelFormat format, const void *pixels)
		: ImageData(width, height, format, const_cast<void *>(pixels), false)
		, _runtime(runtime) { }
	DoraImageData(const DoraImageData &other)
		: ImageData(other), _runtime(other._runtime) { }
	DoraImageData *clone() const override { return new DoraImageData(*this); }
	::love::filesystem::FileData *encode(::love::image::FormatHandler::EncodedFormat format,
		const char *filename, bool writeFile) const override;
	LoveRuntime *getRuntime() const noexcept { return _runtime; }

private:
	LoveRuntime *_runtime = nullptr;
};

using ImageDataUserdata = DoraImageData;

::love::image::ImageData *CanvasUserdata::newImageData(
	::love::image::Image *, int slice, int mipmap, const ::love::Rect &rect)
{
	if (!runtime || !runtime->getGraphicsBackend() || handle == 0)
		throw ::love::Exception("closed Canvas");
	if (!isReadable())
		throw ::love::Exception(
			"Canvas:newImageData cannot be called on non-readable Canvases.");
	if (::love::isPixelFormatDepthStencil(getPixelFormat()))
		throw ::love::Exception(
			"Canvas:newImageData cannot be called on Canvases with depth/stencil pixel formats.");
	if (mipmap < 0 || mipmap >= getMipmapCount())
		throw ::love::Exception("Invalid mipmap index.");
	if (rect.x < 0 || rect.y < 0 || rect.w <= 0 || rect.h <= 0
		|| rect.x + rect.w > getPixelWidth(mipmap)
		|| rect.y + rect.h > getPixelHeight(mipmap))
		throw ::love::Exception("Invalid rectangle dimensions.");
	if (slice < 0 || (getTextureType() == ::love::graphics::TEXTURE_VOLUME
			&& slice >= getDepth(mipmap))
		|| (getTextureType() == ::love::graphics::TEXTURE_2D_ARRAY
			&& slice >= getLayerCount())
		|| (getTextureType() == ::love::graphics::TEXTURE_CUBE && slice >= 6))
		throw ::love::Exception("Invalid slice index.");
	auto dataformat = getPixelFormat() == ::love::PIXELFORMAT_sRGBA8
		? ::love::PIXELFORMAT_RGBA8 : getPixelFormat();
	return runtime->readCanvasImageData(handle, dataformat, slice, mipmap, rect);
}

struct CursorUserdata final
	: DoraHandleObject<MouseBackend::CursorHandle, &LoveRuntime::retainLoveCursorHandle,
		&LoveRuntime::releaseLoveCursor, &LoveRuntime::forgetLoveCursorHandle,
		::love::mouse::Cursor>
{
	using DoraHandle = DoraHandleObject<MouseBackend::CursorHandle,
		&LoveRuntime::retainLoveCursorHandle, &LoveRuntime::releaseLoveCursor,
		&LoveRuntime::forgetLoveCursorHandle, ::love::mouse::Cursor>;
	CursorUserdata(LoveRuntime *valueRuntime, MouseBackend::CursorHandle valueHandle,
		::love::mouse::Cursor::CursorType valueType,
		::love::mouse::Cursor::SystemCursor valueSystemType = ::love::mouse::Cursor::CURSOR_ARROW)
		: DoraHandle(valueRuntime, valueHandle), cursorType(valueType), systemType(valueSystemType) { }
	void *getHandle() const override { return reinterpret_cast<void *>(static_cast<std::uintptr_t>(handle)); }
	CursorType getType() const override { return cursorType; }
	SystemCursor getSystemType() const override { return systemType; }
	CursorType cursorType;
	SystemCursor systemType;
};

class DoraCompressedImageData final : public ::love::image::CompressedImageData
{
	public:
	explicit DoraCompressedImageData(ImageBackend::CompressedImage valueImage)
		: image(std::move(valueImage))
	{
		if (!::love::getConstant(image.format.c_str(), format)
			|| !::love::isPixelFormatCompressed(format))
			throw ::love::Exception("Unsupported compressed image format: %s", image.format.c_str());
		std::size_t byteCount = 0;
		for (const auto &level : image.levels)
		{
			if (level.bytes.size() > std::numeric_limits<std::size_t>::max() - byteCount)
				throw ::love::Exception("Compressed image data is too large.");
			byteCount += level.bytes.size();
		}
		memory.set(new ::love::image::CompressedMemory(byteCount), ::love::Acquire::NORETAIN);
		std::size_t offset = 0;
		for (const auto &level : image.levels)
		{
			if (!level.bytes.empty())
				std::memcpy(memory->data + offset, level.bytes.data(), level.bytes.size());
			auto *slice = new ::love::image::CompressedSlice(format, level.width,
				level.height, memory, offset, level.bytes.size());
			dataImages.emplace_back(slice, ::love::Acquire::NORETAIN);
			offset += level.bytes.size();
		}
	}
	DoraCompressedImageData(const DoraCompressedImageData &other)
		: CompressedImageData(other), image(other.image) { }
	DoraCompressedImageData *clone() const override
	{
		return new DoraCompressedImageData(*this);
	}
	ImageBackend::CompressedImage image;
};

using CompressedImageDataUserdata = DoraCompressedImageData;

struct ImageRasterizerGlyph
{
	std::uint32_t codepoint = 0;
	int x = 0;
	int width = 0;
};

struct BMFontGlyph
{
	std::uint32_t codepoint = 0;
	int x = 0;
	int y = 0;
	int page = 0;
	int width = 0;
	int height = 0;
	int advance = 0;
	int bearingX = 0;
	int bearingY = 0;
};

struct RasterizerUserdata final : ::love::font::Rasterizer
{
	RasterizerUserdata() { setDPIScale(1.0f); }
	RasterizerUserdata(RasterizerUserdata &&other) noexcept
		: kind(other.kind), runtime(other.runtime), height(other.height), advance(other.advance),
		  ascent(other.ascent), descent(other.descent), lineHeight(other.lineHeight),
		  requestedSize(other.requestedSize), extraSpacing(other.extraSpacing),
		  fontScale(other.fontScale), monochrome(other.monochrome),
		  spacer(other.spacer), sourceObjects(std::move(other.sourceObjects)),
		  glyphs(std::move(other.glyphs)), imageGlyphs(std::move(other.imageGlyphs)),
		  fontBytes(std::move(other.fontBytes)), fontInfo(other.fontInfo),
		  bmGlyphs(std::move(other.bmGlyphs)) { setDPIScale(other.getDPIScale()); }
	~RasterizerUserdata() override = default;
	enum class Kind { Image, TrueType, BMFont } kind = Kind::Image;
	int getHeight() const override { return height; }
	int getAdvance() const override { return advance; }
	int getAscent() const override { return ascent; }
	int getDescent() const override { return descent; }
	int getLineHeight() const override { return lineHeight; }
	::love::font::GlyphData *getGlyphData(std::uint32_t glyph) const override;
	int getGlyphCount() const override;
	bool hasGlyph(std::uint32_t glyph) const override;
	DataType getDataType() const override
	{
		return kind == Kind::Image || kind == Kind::BMFont ? DATA_IMAGE : DATA_TRUETYPE;
	}
	void setDPIScale(float value) { dpiScale = value; }
	LoveRuntime *runtime = nullptr;
	int height = 0;
	int advance = 0;
	int ascent = 0;
	int descent = 0;
	int lineHeight = 0;
	int requestedSize = 12;
	int extraSpacing = 0;
	float fontScale = 1.0f;
	bool monochrome = false;
	std::array<std::uint8_t, 4> spacer{};
	std::vector<::love::StrongRef<ImageDataUserdata>> sourceObjects;
	std::vector<std::uint32_t> glyphs;
	std::vector<ImageRasterizerGlyph> imageGlyphs;
	std::vector<std::uint8_t> fontBytes;
	stbtt_fontinfo fontInfo{};
	std::unordered_map<std::uint32_t, BMFontGlyph> bmGlyphs;
};

struct GlyphDataBuilder
{
	std::uint32_t glyph = 0;
	int width = 0;
	int height = 0;
	int advance = 0;
	int bearingX = 0;
	int bearingY = 0;
	int pixelSize = 4;
	const char *format = "rgba8";
	std::vector<std::uint8_t> pixels;
};

using GlyphDataUserdata = ::love::font::GlyphData;

using SoundDataUserdata = ::love::sound::SoundData;

SoundDataUserdata *testSoundData(lua_State *state, int index)
{
	if (luaL_testudata(state, index, ::love::sound::SoundData::type.getName()) == nullptr) return nullptr;
	return ::love::luax_checktype<SoundDataUserdata>(state, index);
}

struct DecoderUserdata final : ::love::sound::Decoder
{
	DecoderUserdata(::love::Data *encoded, int requestedBufferSize, int decodedSampleRate,
		int decodedChannels, std::vector<std::uint8_t> decodedSamples)
		: Decoder(encoded, requestedBufferSize)
		, channels(decodedChannels)
		, sampleCount(static_cast<int>(decodedSamples.size()
			/ (static_cast<std::size_t>(decodedChannels) * 2)))
		, samples(std::move(decodedSamples))
	{
		sampleRate = decodedSampleRate;
	}
	~DecoderUserdata() override = default;
	::love::sound::Decoder *clone() override
	{
		return new DecoderUserdata(data.get(), bufferSize, sampleRate, channels, samples);
	}
	int decode() override
	{
		if (bytePosition >= samples.size())
		{
			eof = true;
			return 0;
		}
		const std::size_t frameBytes = static_cast<std::size_t>(channels) * 2;
		const std::size_t framesPerChunk = static_cast<std::size_t>(bufferSize) / frameBytes;
		if (framesPerChunk == 0)
		{
			eof = true;
			return 0;
		}
		const std::size_t byteCount = std::min(framesPerChunk * frameBytes,
			samples.size() - bytePosition);
		std::memcpy(buffer, samples.data() + bytePosition, byteCount);
		bytePosition += byteCount;
		eof = bytePosition >= samples.size();
		return static_cast<int>(byteCount);
	}
	bool seek(double seconds) override
	{
		if (!std::isfinite(seconds) || seconds < 0.0) return false;
		const double frame = seconds * static_cast<double>(sampleRate);
		if (frame > static_cast<double>(sampleCount)) return false;
		const auto frameIndex = static_cast<std::size_t>(frame);
		bytePosition = frameIndex * static_cast<std::size_t>(channels) * 2;
		eof = bytePosition >= samples.size();
		return true;
	}
	bool rewind() override
	{
		bytePosition = 0;
		eof = samples.empty();
		return true;
	}
	bool isSeekable() override { return true; }
	int getChannelCount() const override { return channels; }
	int getBitDepth() const override { return 16; }
	double getDuration() override
	{
		return sampleRate > 0 ? static_cast<double>(sampleCount) / sampleRate : 0.0;
	}

	int channels = 0;
	int sampleCount = 0;
	std::size_t bytePosition = 0;
	std::vector<std::uint8_t> samples;
};

struct TransformMatrix
{
	TransformMatrix() = default;
	TransformMatrix(const TransformMatrix &other)
	{
		std::copy(std::begin(other.elements), std::end(other.elements), std::begin(elements));
	}
	TransformMatrix &operator=(const TransformMatrix &other)
	{
		if (this != &other)
			std::copy(std::begin(other.elements), std::end(other.elements), std::begin(elements));
		return *this;
	}
	float elements[16]{};
};

struct FontUserdata final
	: DoraHandleObject<GraphicsBackend::FontHandle, &LoveRuntime::retainLoveFontHandle,
		&LoveRuntime::releaseLoveFont, &LoveRuntime::forgetLoveFontHandle,
		::love::graphics::Font>
{
	using DoraHandle = DoraHandleObject<GraphicsBackend::FontHandle,
		&LoveRuntime::retainLoveFontHandle, &LoveRuntime::releaseLoveFont,
		&LoveRuntime::forgetLoveFontHandle, ::love::graphics::Font>;
	FontUserdata(LoveRuntime *valueRuntime, GraphicsBackend::FontHandle valueHandle)
		: DoraHandle(valueRuntime, valueHandle) { }
	float getHeight() const override;
	int getWidth(const std::string &text) override;
	int getWidth(::love::uint32 glyph) override;
	void getWrap(const std::vector<ColoredString> &text, float wrapLimit,
		std::vector<std::string> &lines, std::vector<int> *lineWidths) override;
	void setLineHeight(float height) override;
	float getLineHeight() const override;
	void setFilter(const ::love::graphics::Texture::Filter &value) override;
	const ::love::graphics::Texture::Filter &getFilter() const override { return filter; }
	float getAscent() const override;
	float getDescent() const override;
	float getBaseline() const override;
	bool hasGlyph(::love::uint32 glyph) const override;
	bool hasGlyphs(const std::string &text) const override;
	float getKerning(::love::uint32 leftGlyph, ::love::uint32 rightGlyph) override;
	float getKerning(const std::string &leftCharacter,
		const std::string &rightCharacter) override;
	void setFallbacks(const std::vector<::love::graphics::Font *> &fallbacks) override;
	float getDPIScale() const override { return dpiScale; }
	::love::graphics::Texture::Filter filter;
	float dpiScale = 1.0f;
	std::vector<::love::StrongRef<::love::graphics::Font>> fallbackObjects;
};

namespace
{
GraphicsBackend &checkedFontBackend(const FontUserdata &font)
{
	if (!font.runtime || !font.runtime->getGraphicsBackend() || font.handle == 0)
		throw ::love::Exception("closed Font");
	return *font.runtime->getGraphicsBackend();
}

std::uint32_t singleFontCodepoint(const std::string &text)
{
	std::vector<std::uint32_t> codepoints;
	std::string error;
	if (!decodeUtf8(text, codepoints, error) || codepoints.size() != 1)
		throw ::love::Exception("Expected exactly one Unicode character.");
	return codepoints.front();
}
}

float FontUserdata::getHeight() const
{
	return checkedFontBackend(*this).getFontHeight(handle);
}

int FontUserdata::getWidth(const std::string &text)
{
	return static_cast<int>(checkedFontBackend(*this).getFontWidth(handle, text));
}

int FontUserdata::getWidth(::love::uint32 glyph)
{
	return static_cast<int>(checkedFontBackend(*this).getFontGlyphSpacing(handle, glyph));
}

void FontUserdata::getWrap(const std::vector<ColoredString> &text, float wrapLimit,
	std::vector<std::string> &lines, std::vector<int> *lineWidths)
{
	if (!std::isfinite(wrapLimit))
		throw ::love::Exception("Font wrap limit must be finite.");
	std::string flattened;
	for (const auto &part : text) flattened += part.str;
	auto &backend = checkedFontBackend(*this);
	backend.getFontWrap(handle, flattened, wrapLimit, lines);
	if (lineWidths)
	{
		lineWidths->clear();
		lineWidths->reserve(lines.size());
		for (const auto &line : lines)
			lineWidths->push_back(static_cast<int>(backend.getFontWidth(handle, line)));
	}
}

void FontUserdata::setLineHeight(float height)
{
	if (!std::isfinite(height) || height <= 0.0f)
		throw ::love::Exception("Font line height must be finite and positive.");
	checkedFontBackend(*this).setFontLineHeight(handle, height);
}

float FontUserdata::getLineHeight() const
{
	return checkedFontBackend(*this).getFontLineHeight(handle);
}

void FontUserdata::setFilter(const ::love::graphics::Texture::Filter &value)
{
	using Texture = ::love::graphics::Texture;
	if ((value.min != Texture::FILTER_LINEAR && value.min != Texture::FILTER_NEAREST)
		|| (value.mag != Texture::FILTER_LINEAR && value.mag != Texture::FILTER_NEAREST))
		throw ::love::Exception("Invalid Font filter mode.");
	if (value.min != value.mag)
		throw ::love::Exception(
			"embedded Dora Fonts require matching minification and magnification filters");
	if (!std::isfinite(value.anisotropy) || value.anisotropy < 0.0f)
		throw ::love::Exception("Font anisotropy must be finite and non-negative.");
	filter = value;
	filter.mipmap = Texture::FILTER_NONE;
	filter.anisotropy = std::max(1.0f, value.anisotropy);
}

float FontUserdata::getAscent() const
{
	return checkedFontBackend(*this).getFontAscent(handle);
}

float FontUserdata::getDescent() const
{
	return checkedFontBackend(*this).getFontDescent(handle);
}

float FontUserdata::getBaseline() const
{
	return checkedFontBackend(*this).getFontBaseline(handle);
}

bool FontUserdata::hasGlyph(::love::uint32 glyph) const
{
	return checkedFontBackend(*this).hasFontGlyph(handle, glyph);
}

bool FontUserdata::hasGlyphs(const std::string &text) const
{
	std::vector<std::uint32_t> codepoints;
	std::string error;
	if (!decodeUtf8(text, codepoints, error))
		throw ::love::Exception("%s", error.c_str());
	if (codepoints.empty()) return false;
	auto &backend = checkedFontBackend(*this);
	return std::all_of(codepoints.begin(), codepoints.end(), [&](std::uint32_t value) {
		return backend.hasFontGlyph(handle, value);
	});
}

float FontUserdata::getKerning(::love::uint32 leftGlyph, ::love::uint32 rightGlyph)
{
	return checkedFontBackend(*this).getFontKerning(handle, leftGlyph, rightGlyph);
}

float FontUserdata::getKerning(const std::string &leftCharacter,
	const std::string &rightCharacter)
{
	return getKerning(singleFontCodepoint(leftCharacter), singleFontCodepoint(rightCharacter));
}

void FontUserdata::setFallbacks(const std::vector<::love::graphics::Font *> &fallbacks)
{
	auto &backend = checkedFontBackend(*this);
	std::vector<GraphicsBackend::FontHandle> handles;
	std::vector<::love::StrongRef<::love::graphics::Font>> objects;
	handles.reserve(fallbacks.size());
	objects.reserve(fallbacks.size());
	for (auto *base : fallbacks)
	{
		auto *fallback = dynamic_cast<FontUserdata *>(base);
		if (!fallback || fallback->runtime != runtime || fallback->handle == 0)
			throw ::love::Exception("Fallback Font belongs to another or closed LoveRuntime.");
		handles.push_back(fallback->handle);
		objects.emplace_back(fallback);
	}
	std::string error;
	if (!backend.setFontFallbacks(handle, handles, error))
		throw ::love::Exception("Love Font setFallbacks failed: %s",
			error.empty() ? "Dora font backend rejected fallback fonts" : error.c_str());
	fallbackObjects = std::move(objects);
}

using QuadUserdata = ::love::graphics::Quad;

struct MeshAttribute
{
	std::string name;
	std::string type;
	int components = 0;
	std::size_t offset = 0;
	std::size_t byteOffset = 0;
	std::size_t byteSize = 0;
	bool enabled = true;
};

struct MeshUserdata;

struct MeshAttachment
{
	MeshUserdata *mesh = nullptr;
	std::size_t attributeIndex = 0;
	std::string step = "pervertex";
	bool enabled = true;
};

struct MeshUserdata final : ::love::graphics::Mesh
{
	~MeshUserdata() override = default;
	void draw(::love::graphics::Graphics *, const ::love::Matrix4 &) override
	{
		throw ::love::Exception(
			"Dora embedded Mesh must be submitted through its state-local graphics adapter.");
	}
	void setVertex(size_t vertindex, const void *data, size_t datasize) override;
	size_t getVertex(size_t vertindex, void *data, size_t datasize) override;
	void *getVertexScratchBuffer() override;
	void setVertexAttribute(size_t vertindex, int attribindex,
		const void *data, size_t datasize) override;
	size_t getVertexAttribute(size_t vertindex, int attribindex,
		void *data, size_t datasize) override;
	size_t getVertexCount() const override { return vertexCount; }
	size_t getVertexStride() const override { return vertexStride; }
	const std::vector<AttribFormat> &getVertexFormat() const override { return upstreamFormat; }
	::love::graphics::vertex::DataType getAttributeInfo(
		int attribindex, int &components) const override;
	int getAttributeIndex(const std::string &name) const override;
	void setAttributeEnabled(const std::string &name, bool enable) override;
	bool isAttributeEnabled(const std::string &name) const override;
	void attachAttribute(const std::string &name, ::love::graphics::Mesh *mesh,
		const std::string &attachname, ::love::graphics::AttributeStep step) override;
	bool detachAttribute(const std::string &name) override;
	void *mapVertexData() override { return bytes.data(); }
	void unmapVertexData(size_t modifiedoffset, size_t modifiedsize) override;
	void flush() override { }
	void setVertexMap(const std::vector<::love::uint32> &map) override;
	void setVertexMap(::love::graphics::IndexDataType datatype,
		const void *data, size_t datasize) override;
	void setVertexMap() override;
	bool getVertexMap(std::vector<::love::uint32> &map) const override;
	size_t getVertexMapCount() const override { return vertexMap.size(); }
	void setTexture(::love::graphics::Texture *texture) override;
	void setTexture() override;
	::love::graphics::Texture *getTexture() const override;
	void setDrawMode(::love::graphics::PrimitiveType mode) override;
	::love::graphics::PrimitiveType getDrawMode() const override;
	void setDrawRange(int start, int count) override;
	void setDrawRange() override;
	bool getDrawRange(int &start, int &count) const override;
	LoveRuntime *runtime = nullptr;
	std::vector<MeshAttribute> format;
	std::vector<AttribFormat> upstreamFormat;
	std::vector<std::uint8_t> vertexScratch;
	std::vector<float> values;
	std::vector<std::uint8_t> bytes;
	std::vector<std::uint32_t> vertexMap;
	bool useVertexMap = false;
	std::unordered_map<std::string, MeshAttachment> attachments;
	std::unordered_map<std::string, ::love::StrongRef<::love::Object>> attachmentObjects;
	std::size_t vertexCount = 0;
	std::size_t componentCount = 0;
	std::size_t vertexStride = 0;
	std::string drawMode = "fan";
	std::string usage = "dynamic";
	int drawStart = -1;
	int drawCount = 0;
	GraphicsBackend::ImageHandle image = 0;
	GraphicsBackend::CanvasHandle canvas = 0;
	::love::StrongRef<::love::Object> textureObject;
	std::shared_ptr<GraphicsBackend::MeshBuffer> renderBuffer
		= std::make_shared<GraphicsBackend::MeshBuffer>();
	std::uint64_t geometryRevision = 1;
	std::uint64_t preparedRevision = 0;
	int preparedInstanceCount = 0;
	std::string preparedDrawMode;
};

struct SpriteBatchSprite
{
	GraphicsBackend::MeshVertex vertices[4];
};

struct SpriteBatchAttachment
{
	MeshUserdata *mesh = nullptr;
	std::size_t attributeIndex = 0;
};

struct SpriteBatchUserdata final : ::love::graphics::SpriteBatch
{
	~SpriteBatchUserdata() override = default;
	void draw(::love::graphics::Graphics *, const ::love::Matrix4 &) override
	{
		throw ::love::Exception(
			"Dora embedded SpriteBatch must be submitted through its state-local graphics adapter.");
	}
	int add(const ::love::Matrix4 &matrix, int index) override;
	int add(::love::graphics::Quad *quad, const ::love::Matrix4 &matrix, int index) override;
	int addLayer(int layer, const ::love::Matrix4 &matrix, int index) override;
	int addLayer(int layer, ::love::graphics::Quad *quad,
		const ::love::Matrix4 &matrix, int index) override;
	void clear() override;
	void flush() override { }
	void setTexture(::love::graphics::Texture *texture) override;
	::love::graphics::Texture *getTexture() const override;
	void setColor(const ::love::Colorf &value) override;
	void setColor() override { colorEnabled = false; }
	::love::Colorf getColor(bool &active) const override;
	int getCount() const override { return static_cast<int>(count); }
	int getBufferSize() const override { return static_cast<int>(bufferSize); }
	void attachAttribute(const std::string &name, ::love::graphics::Mesh *mesh) override;
	void setDrawRange(int start, int count) override;
	void setDrawRange() override;
	bool getDrawRange(int &start, int &count) const override;
	LoveRuntime *runtime = nullptr;
	GraphicsBackend::ImageHandle image = 0;
	GraphicsBackend::CanvasHandle canvas = 0;
	::love::StrongRef<::love::Object> textureObject;
	GraphicsBackend::TextureType textureType = GraphicsBackend::TextureType::Texture2D;
	int layerCount = 1;
	std::vector<SpriteBatchSprite> sprites;
	std::size_t count = 0;
	std::size_t bufferSize = 0;
	bool colorEnabled = false;
	float color[4]{1.0f, 1.0f, 1.0f, 1.0f};
	int drawStart = -1;
	int drawCount = 0;
	std::string usage = "dynamic";
	std::unordered_map<std::string, SpriteBatchAttachment> attachments;
	std::unordered_map<std::string, ::love::StrongRef<::love::Object>> attachmentObjects;
	std::shared_ptr<GraphicsBackend::MeshBuffer> renderBuffer
		= std::make_shared<GraphicsBackend::MeshBuffer>();
	bool geometryDirty = true;
};

struct ParticleColor
{
	float red = 1.0f;
	float green = 1.0f;
	float blue = 1.0f;
	float alpha = 1.0f;
};

struct ParticleQuad
{
	float x = 0.0f;
	float y = 0.0f;
	float width = 0.0f;
	float height = 0.0f;
	float textureWidth = 0.0f;
	float textureHeight = 0.0f;
};

struct ParticleState
{
	float lifetime = 0.0f;
	float life = 0.0f;
	float x = 0.0f;
	float y = 0.0f;
	float originX = 0.0f;
	float originY = 0.0f;
	float velocityX = 0.0f;
	float velocityY = 0.0f;
	float accelerationX = 0.0f;
	float accelerationY = 0.0f;
	float radialAcceleration = 0.0f;
	float tangentialAcceleration = 0.0f;
	float linearDamping = 0.0f;
	float size = 1.0f;
	float sizeOffset = 0.0f;
	float sizeInterval = 1.0f;
	float rotation = 0.0f;
	float angle = 0.0f;
	float spinStart = 0.0f;
	float spinEnd = 0.0f;
	ParticleColor color;
	std::size_t quadIndex = 0;
};

struct ParticleSystemUserdata final : ::love::graphics::ParticleSystem
{
	~ParticleSystemUserdata() override = default;
	ParticleSystemUserdata() = default;
	ParticleSystemUserdata(const ParticleSystemUserdata &) = default;
	::love::graphics::ParticleSystem *clone() override;
	void draw(::love::graphics::Graphics *, const ::love::Matrix4 &) override
	{
		throw ::love::Exception("ParticleSystem drawing must use the state-local Dora Graphics adapter");
	}
	void setTexture(::love::graphics::Texture *texture) override;
	::love::graphics::Texture *getTexture() const override { return textureObject.get(); }
	void setBufferSize(::love::uint32 size) override
	{
		if (size == 0 || size > MAX_PARTICLES) throw ::love::Exception("Invalid buffer size");
		particles.clear();
		particles.shrink_to_fit();
		bufferSize = size;
		particles.reserve(bufferSize);
		emitterLife = emitterLifetime;
		emitCounter = 0.0f;
		geometryDirty = true;
	}
	::love::uint32 getBufferSize() const override { return static_cast<::love::uint32>(bufferSize); }
	void setInsertMode(InsertMode mode) override
	{
		static constexpr const char *names[] = {"top", "bottom", "random"};
		insertMode = names[static_cast<std::size_t>(mode)];
	}
	InsertMode getInsertMode() const override
	{
		return insertMode == "bottom" ? INSERT_MODE_BOTTOM
			: insertMode == "random" ? INSERT_MODE_RANDOM : INSERT_MODE_TOP;
	}
	void setEmissionRate(float rate) override
	{
		if (!std::isfinite(rate) || rate < 0.0f) throw ::love::Exception("Invalid emission rate");
		emissionRate = rate;
		if (rate > 0.0f) emitCounter = std::min(emitCounter, 1.0f / rate);
	}
	float getEmissionRate() const override { return emissionRate; }
	void setEmitterLifetime(float value) override { emitterLife = emitterLifetime = value; }
	float getEmitterLifetime() const override { return emitterLifetime; }
	void setParticleLifetime(float minimum, float maximum) override
	{
		particleLifetimeMin = minimum;
		particleLifetimeMax = maximum == 0.0f ? minimum : maximum;
	}
	void getParticleLifetime(float &minimum, float &maximum) const override
	{ minimum = particleLifetimeMin; maximum = particleLifetimeMax; }
	void setPosition(float x, float y) override
	{ positionX = previousX = x; positionY = previousY = y; }
	const ::love::Vector2 &getPosition() const override
	{
		positionCache = {positionX, positionY};
		return positionCache;
	}
	void moveTo(float x, float y) override { positionX = x; positionY = y; }
	void setEmissionArea(AreaSpreadDistribution distribution, float x, float y,
		float angle, bool relative) override
	{
		const char *name = nullptr;
		getConstant(distribution, name);
		emissionDistribution = name ? name : "none";
		emissionX = x; emissionY = y; emissionAngle = angle;
		directionRelativeToCenter = relative;
	}
	AreaSpreadDistribution getEmissionArea(::love::Vector2 &params, float &angle,
		bool &relative) const override
	{
		params = {emissionX, emissionY}; angle = emissionAngle;
		relative = directionRelativeToCenter;
		AreaSpreadDistribution distribution = DISTRIBUTION_NONE;
		getConstant(emissionDistribution.c_str(), distribution);
		return distribution;
	}
	void setDirection(float value) override { direction = value; }
	float getDirection() const override { return direction; }
	void setSpread(float value) override { spread = value; }
	float getSpread() const override { return spread; }
	void setSpeed(float value) override { setSpeed(value, value); }
	void setSpeed(float minimum, float maximum) override { speedMin = minimum; speedMax = maximum; }
	void getSpeed(float &minimum, float &maximum) const override { minimum = speedMin; maximum = speedMax; }
	void setLinearAcceleration(float x, float y) override { setLinearAcceleration(x, y, x, y); }
	void setLinearAcceleration(float xmin, float ymin, float xmax, float ymax) override
	{ accelerationMinX = xmin; accelerationMinY = ymin; accelerationMaxX = xmax; accelerationMaxY = ymax; }
	void getLinearAcceleration(::love::Vector2 &minimum, ::love::Vector2 &maximum) const override
	{ minimum = {accelerationMinX, accelerationMinY}; maximum = {accelerationMaxX, accelerationMaxY}; }
	void setRadialAcceleration(float value) override { setRadialAcceleration(value, value); }
	void setRadialAcceleration(float minimum, float maximum) override { radialMin = minimum; radialMax = maximum; }
	void getRadialAcceleration(float &minimum, float &maximum) const override { minimum = radialMin; maximum = radialMax; }
	void setTangentialAcceleration(float value) override { setTangentialAcceleration(value, value); }
	void setTangentialAcceleration(float minimum, float maximum) override { tangentialMin = minimum; tangentialMax = maximum; }
	void getTangentialAcceleration(float &minimum, float &maximum) const override { minimum = tangentialMin; maximum = tangentialMax; }
	void setLinearDamping(float minimum, float maximum) override { dampingMin = minimum; dampingMax = maximum; }
	void getLinearDamping(float &minimum, float &maximum) const override { minimum = dampingMin; maximum = dampingMax; }
	void setSize(float value) override { sizes.assign(1, value); }
	void setSizes(const std::vector<float> &values) override { sizes = values; }
	const std::vector<float> &getSizes() const override { return sizes; }
	void setSizeVariation(float value) override { sizeVariation = value; }
	float getSizeVariation() const override { return sizeVariation; }
	void setRotation(float value) override { setRotation(value, value); }
	void setRotation(float minimum, float maximum) override { rotationMin = minimum; rotationMax = maximum; }
	void getRotation(float &minimum, float &maximum) const override { minimum = rotationMin; maximum = rotationMax; }
	void setSpin(float value) override { setSpin(value, value); }
	void setSpin(float start, float end) override { spinStart = start; spinEnd = end; }
	void getSpin(float &start, float &end) const override { start = spinStart; end = spinEnd; }
	void setSpinVariation(float value) override { spinVariation = value; }
	float getSpinVariation() const override { return spinVariation; }
	void setOffset(float x, float y) override
	{ offsetX = x; offsetY = y; defaultOffset = false; geometryDirty = true; }
	::love::Vector2 getOffset() const override { return {offsetX, offsetY}; }
	void setColor(const std::vector<::love::Colorf> &values) override
	{
		colors.clear(); colors.reserve(values.size());
		for (const auto &color : values) colors.push_back({color.r, color.g, color.b, color.a});
	}
	std::vector<::love::Colorf> getColor() const override
	{
		std::vector<::love::Colorf> values; values.reserve(colors.size());
		for (const auto &color : colors) values.emplace_back(color.red, color.green, color.blue, color.alpha);
		return values;
	}
	void setQuads(const std::vector<::love::graphics::Quad *> &values) override;
	void setQuads() override;
	std::vector<::love::graphics::Quad *> getQuads() const override
	{
		std::vector<::love::graphics::Quad *> values; values.reserve(quadObjects.size());
		for (const auto &quad : quadObjects) values.push_back(quad.get());
		return values;
	}
	void setRelativeRotation(bool enable) override { relativeRotation = enable; }
	bool hasRelativeRotation() const override { return relativeRotation; }
	::love::uint32 getCount() const override { return static_cast<::love::uint32>(particles.size()); }
	void start() override { active = true; }
	void stop() override { active = false; emitterLife = emitterLifetime; emitCounter = 0.0f; }
	void pause() override { active = false; }
	void reset() override { particles.clear(); geometryDirty = true; emitterLife = emitterLifetime; emitCounter = 0.0f; }
	void emit(::love::uint32 count) override;
	bool isActive() const override { return active; }
	bool isPaused() const override { return !active && emitterLife < emitterLifetime; }
	bool isStopped() const override { return !active && emitterLife >= emitterLifetime; }
	bool isEmpty() const override { return particles.empty(); }
	bool isFull() const override { return particles.size() >= bufferSize; }
	void update(float dt) override;
	LoveRuntime *runtime = nullptr;
	GraphicsBackend::ImageHandle image = 0;
	GraphicsBackend::CanvasHandle canvas = 0;
	::love::StrongRef<::love::graphics::Texture> textureObject;
	std::vector<ParticleState> particles;
	std::vector<float> sizes{1.0f};
	std::vector<ParticleColor> colors{{}};
	std::vector<ParticleQuad> quads;
	std::vector<::love::StrongRef<::love::graphics::Quad>> quadObjects;
	std::size_t bufferSize = 1000;
	bool active = true;
	std::string insertMode = "top";
	float emissionRate = 0.0f;
	float emitCounter = 0.0f;
	float positionX = 0.0f;
	float positionY = 0.0f;
	float previousX = 0.0f;
	float previousY = 0.0f;
	std::string emissionDistribution = "none";
	float emissionX = 0.0f;
	float emissionY = 0.0f;
	float emissionAngle = 0.0f;
	bool directionRelativeToCenter = false;
	float emitterLifetime = -1.0f;
	float emitterLife = 0.0f;
	float particleLifetimeMin = 0.0f;
	float particleLifetimeMax = 0.0f;
	float direction = 0.0f;
	float spread = 0.0f;
	float speedMin = 0.0f;
	float speedMax = 0.0f;
	float accelerationMinX = 0.0f;
	float accelerationMinY = 0.0f;
	float accelerationMaxX = 0.0f;
	float accelerationMaxY = 0.0f;
	float radialMin = 0.0f;
	float radialMax = 0.0f;
	float tangentialMin = 0.0f;
	float tangentialMax = 0.0f;
	float dampingMin = 0.0f;
	float dampingMax = 0.0f;
	float sizeVariation = 0.0f;
	float rotationMin = 0.0f;
	float rotationMax = 0.0f;
	float spinStart = 0.0f;
	float spinEnd = 0.0f;
	float spinVariation = 0.0f;
	float offsetX = 0.0f;
	float offsetY = 0.0f;
	bool defaultOffset = true;
	bool relativeRotation = false;
	std::uint64_t randomState = 0x853c49e6748fea9bULL;
	std::shared_ptr<GraphicsBackend::MeshBuffer> renderBuffer
		= std::make_shared<GraphicsBackend::MeshBuffer>();
	bool geometryDirty = true;
	std::size_t preparedParticleCount = 0;
	mutable ::love::Vector2 positionCache;
};

struct TextFragment
{
	std::string text;
	float color[4]{1.0f, 1.0f, 1.0f, 1.0f};
};

struct TextLayoutRun
{
	std::string text;
	float x = 0.0f;
	float y = 0.0f;
	float color[4]{1.0f, 1.0f, 1.0f, 1.0f};
};

struct TextEntry
{
	std::vector<TextFragment> fragments;
	std::vector<TextLayoutRun> runs;
	TransformMatrix transform;
	float wrap = -1.0f;
	bool formatted = false;
	std::string align = "left";
	float width = 0.0f;
	float height = 0.0f;
};

struct TextUserdata final : ::love::graphics::Text
{
	~TextUserdata() override = default;
	TextUserdata(LoveRuntime *valueRuntime, FontUserdata *valueFont,
		const std::vector<::love::graphics::Font::ColoredString> &text);
	void set(const std::vector<::love::graphics::Font::ColoredString> &text) override;
	void set(const std::vector<::love::graphics::Font::ColoredString> &text,
		float wrap, ::love::graphics::Font::AlignMode align) override;
	int add(const std::vector<::love::graphics::Font::ColoredString> &text,
		const ::love::Matrix4 &transform) override;
	int addf(const std::vector<::love::graphics::Font::ColoredString> &text,
		float wrap, ::love::graphics::Font::AlignMode align,
		const ::love::Matrix4 &transform) override;
	void clear() override { entries.clear(); }
	void setFont(::love::graphics::Font *font) override;
	::love::graphics::Font *getFont() const override { return fontObject.get(); }
	int getWidth(int index = 0) const override;
	int getHeight(int index = 0) const override;
	void draw(::love::graphics::Graphics *, const ::love::Matrix4 &) override
	{
		throw ::love::Exception(
			"Dora embedded Text must be submitted through its state-local graphics adapter.");
	}
	LoveRuntime *runtime = nullptr;
	GraphicsBackend::FontHandle font = 0;
	::love::StrongRef<::love::graphics::Font> fontObject;
	std::vector<TextEntry> entries;
};

struct ShaderUserdata final
	: DoraHandleObject<GraphicsBackend::ShaderHandle, &LoveRuntime::retainLoveShaderHandle,
		&LoveRuntime::releaseLoveShader, &LoveRuntime::forgetLoveShaderHandle,
		::love::graphics::Shader>
{
	using DoraHandle = DoraHandleObject<GraphicsBackend::ShaderHandle,
		&LoveRuntime::retainLoveShaderHandle, &LoveRuntime::releaseLoveShader,
		&LoveRuntime::forgetLoveShaderHandle, ::love::graphics::Shader>;
	ShaderUserdata(LoveRuntime *valueRuntime, GraphicsBackend::ShaderHandle valueHandle,
		std::string valueWarnings)
		: DoraHandle(valueRuntime, valueHandle), warnings(std::move(valueWarnings)) { }
	std::string getWarnings() const override { return warnings; }
	const UniformInfo *getUniformInfo(const std::string &name) const override;
	void updateUniform(const UniformInfo *info, int count, bool colors) override;
	void sendTextures(const UniformInfo *info, ::love::graphics::Texture **textures,
		int count) override;
	bool hasUniform(const std::string &name) const override;
	struct UniformStorage
	{
		UniformInfo info;
		std::vector<std::uint32_t> words;
	};
	std::string warnings;
	mutable std::unordered_map<std::string, std::unique_ptr<UniformStorage>> uniforms;
	std::unordered_map<std::string, std::vector<::love::StrongRef<::love::Object>>> samplerObjects;
};

const ::love::graphics::Shader::UniformInfo *ShaderUserdata::getUniformInfo(
	const std::string &name) const
{
	if (!runtime || handle == 0 || !runtime->getGraphicsBackend()) return nullptr;
	GraphicsBackend::ShaderUniformInfo backendInfo;
	if (!runtime->getGraphicsBackend()->getShaderUniformInfo(handle, name, backendInfo))
		return nullptr;
	auto storage = std::make_unique<UniformStorage>();
	auto &info = storage->info;
	info.name = name;
	info.count = backendInfo.count;
	info.textureType = toLoveTextureType(backendInfo.textureType);
	switch (backendInfo.type)
	{
		case GraphicsBackend::ShaderUniformType::Float: info.baseType = UNIFORM_FLOAT; break;
		case GraphicsBackend::ShaderUniformType::Matrix:
		{
			info.baseType = UNIFORM_MATRIX;
			const int dimension = static_cast<int>(std::lround(std::sqrt(backendInfo.components)));
			if (dimension * dimension != backendInfo.components) return nullptr;
			info.matrix = {static_cast<short>(dimension), static_cast<short>(dimension)};
			break;
		}
		case GraphicsBackend::ShaderUniformType::Int: info.baseType = UNIFORM_INT; break;
		case GraphicsBackend::ShaderUniformType::UInt: info.baseType = UNIFORM_UINT; break;
		case GraphicsBackend::ShaderUniformType::Bool: info.baseType = UNIFORM_BOOL; break;
		case GraphicsBackend::ShaderUniformType::Sampler: info.baseType = UNIFORM_SAMPLER; break;
	}
	if (info.baseType != UNIFORM_MATRIX)
		info.components = backendInfo.components;
	const std::size_t wordCount = info.baseType == UNIFORM_SAMPLER ? 0
		: static_cast<std::size_t>(backendInfo.components)
			* static_cast<std::size_t>(std::max(backendInfo.count, 0));
	storage->words.resize(wordCount);
	info.data = storage->words.empty() ? nullptr : storage->words.data();
	info.dataSize = storage->words.size() * sizeof(std::uint32_t);
	auto *result = storage.get();
	uniforms[name] = std::move(storage);
	return &result->info;
}

bool ShaderUserdata::hasUniform(const std::string &name) const
{
	return runtime && handle != 0 && runtime->getGraphicsBackend()
		&& runtime->getGraphicsBackend()->hasShaderUniform(handle, name);
}

void ShaderUserdata::updateUniform(const UniformInfo *info, int count, bool colors)
{
	if (!runtime || handle == 0 || !runtime->getGraphicsBackend() || !info)
		throw ::love::Exception("closed Shader");
	const int components = info->baseType == UNIFORM_MATRIX
		? info->matrix.columns * info->matrix.rows : info->components;
	const std::size_t valueCount = static_cast<std::size_t>(std::max(count, 0))
		* static_cast<std::size_t>(std::max(components, 0));
	std::vector<float> values;
	values.reserve(valueCount);
	for (std::size_t index = 0; index < valueCount; ++index)
	{
		switch (info->baseType)
		{
			case UNIFORM_INT:
				values.push_back(std::bit_cast<float>(
					static_cast<std::int32_t>(info->ints[index]))); break;
			case UNIFORM_UINT:
				values.push_back(std::bit_cast<float>(info->uints[index])); break;
			case UNIFORM_BOOL:
				values.push_back(info->ints[index] != 0 ? 1.0f : 0.0f); break;
			case UNIFORM_FLOAT:
			case UNIFORM_MATRIX: values.push_back(info->floats[index]); break;
			default: throw ::love::Exception("Shader uniform is not numeric");
		}
	}
	std::string error;
	if (!runtime->getGraphicsBackend()->sendShaderFloats(handle, info->name,
		values, colors, error))
		throw ::love::Exception("%s", error.c_str());
}

void ShaderUserdata::sendTextures(const UniformInfo *info,
	::love::graphics::Texture **textures, int count)
{
	if (!runtime || handle == 0 || !runtime->getGraphicsBackend() || !info)
		throw ::love::Exception("closed Shader");
	std::vector<GraphicsBackend::ShaderTexture> backendTextures;
	std::vector<::love::StrongRef<::love::Object>> objects;
	backendTextures.reserve(static_cast<std::size_t>(count));
	objects.reserve(static_cast<std::size_t>(count));
	for (int index = 0; index < count; ++index)
	{
		GraphicsBackend::ShaderTexture texture;
		if (auto *image = dynamic_cast<ImageUserdata *>(textures[index]))
		{
			if (image->runtime != runtime || image->handle == 0)
				throw ::love::Exception("Image belongs to another or closed LoveRuntime");
			texture.image = image->handle;
			texture.filter = image->filter;
			texture.wrapU = image->wrapU;
			texture.wrapV = image->wrapV;
			texture.wrapW = image->wrapW;
			objects.emplace_back(image);
		}
		else if (auto *canvas = dynamic_cast<CanvasUserdata *>(textures[index]))
		{
			if (canvas->runtime != runtime || canvas->handle == 0)
				throw ::love::Exception("Canvas belongs to another or closed LoveRuntime");
			if (!canvas->readable)
				throw ::love::Exception("Shader Canvas must be readable");
			texture.canvas = canvas->handle;
			texture.filter = canvas->filter;
			texture.wrapU = canvas->wrapU;
			texture.wrapV = canvas->wrapV;
			objects.emplace_back(canvas);
		}
		else throw ::love::Exception("unsupported Texture backend");
		backendTextures.push_back(texture);
	}
	std::string error;
	if (!runtime->getGraphicsBackend()->sendShaderTextures(handle, info->name,
		backendTextures, error))
		throw ::love::Exception("%s", error.c_str());
	samplerObjects[info->name] = std::move(objects);
}

struct AudioSourceUserdata final
	: DoraHandleObject<AudioBackend::SourceHandle, &LoveRuntime::retainLoveAudioSourceHandle,
		&LoveRuntime::releaseLoveAudioSource, &LoveRuntime::forgetLoveAudioSourceHandle,
		::love::audio::Source>
{
	using DoraHandle = DoraHandleObject<AudioBackend::SourceHandle,
		&LoveRuntime::retainLoveAudioSourceHandle, &LoveRuntime::releaseLoveAudioSource,
		&LoveRuntime::forgetLoveAudioSourceHandle, ::love::audio::Source>;
	static ::love::Type &type;
	AudioSourceUserdata(LoveRuntime *valueRuntime, AudioBackend::SourceHandle valueHandle,
		bool valueStream, bool valueQueue)
		: DoraHandle(valueRuntime, valueHandle, std::in_place,
			valueQueue ? TYPE_QUEUE : valueStream ? TYPE_STREAM : TYPE_STATIC),
		  stream(valueStream), queueable(valueQueue) { }
	AudioBackend *backend() const;
	void requireSpatial() const;
	Source *clone() override;
	bool play() override;
	void stop() override;
	void pause() override;
	bool isPlaying() const override;
	bool isFinished() const override;
	bool update() override { return true; }
	void setPitch(float value) override;
	float getPitch() const override;
	void setVolume(float value) override;
	float getVolume() const override;
	void seek(double offset, Unit unit) override;
	double tell(Unit unit) override;
	double getDuration(Unit unit) override;
	void setPosition(float *value) override;
	void getPosition(float *value) const override;
	void setVelocity(float *value) override;
	void getVelocity(float *value) const override;
	void setDirection(float *value) override;
	void getDirection(float *value) const override;
	void setCone(float innerAngle, float outerAngle, float outerVolume,
		float outerHighGain) override;
	void getCone(float &innerAngle, float &outerAngle, float &outerVolume,
		float &outerHighGain) const override;
	void setRelative(bool enable) override;
	bool isRelative() const override;
	void setLooping(bool looping) override;
	bool isLooping() const override;
	void setMinVolume(float volume) override;
	float getMinVolume() const override;
	void setMaxVolume(float volume) override;
	float getMaxVolume() const override;
	void setReferenceDistance(float distance) override;
	float getReferenceDistance() const override;
	void setRolloffFactor(float factor) override;
	float getRolloffFactor() const override;
	void setMaxDistance(float distance) override;
	float getMaxDistance() const override;
	void setAirAbsorptionFactor(float factor) override;
	float getAirAbsorptionFactor() const override;
	int getChannelCount() const override;
	bool setFilter(const std::map<::love::audio::Filter::Parameter, float> &params) override;
	bool setFilter() override;
	bool getFilter(std::map<::love::audio::Filter::Parameter, float> &params) override;
	bool setEffect(const char *effect) override;
	bool setEffect(const char *effect,
		const std::map<::love::audio::Filter::Parameter, float> &params) override;
	bool unsetEffect(const char *effect) override;
	bool getEffect(const char *effect,
		std::map<::love::audio::Filter::Parameter, float> &params) override;
	bool getActiveEffects(std::vector<std::string> &list) const override;
	int getFreeBufferCount() const override;
	bool queue(void *data, size_t length, int dataSampleRate,
		int dataBitDepth, int dataChannels) override;
	void onProxyCreated(lua_State *state, int index) override;
	bool stream = false;
	bool queueable = false;
};

::love::Type &AudioSourceUserdata::type = ::love::audio::Source::type;

AudioBackend *AudioSourceUserdata::backend() const
{
	if (!runtime || !runtime->getAudioBackend() || handle == 0)
		throw ::love::Exception("closed Source");
	return runtime->getAudioBackend();
}

void AudioSourceUserdata::requireSpatial() const
{
	if (backend()->getSourceChannelCount(handle) != 1)
		throw ::love::Exception(
			"spatial audio functionality is only available for mono Sources");
}

::love::audio::Source *AudioSourceUserdata::clone()
{
	std::string error;
	const auto cloned = backend()->cloneSource(handle, error);
	if (cloned == 0)
		throw ::love::Exception("%s", error.empty() ? "Could not clone Source." : error.c_str());
	runtime->copyAudioSourceSettings(handle, cloned);
	return new AudioSourceUserdata(runtime, cloned, stream, queueable);
}

bool AudioSourceUserdata::play() { return backend()->playSource(handle); }
void AudioSourceUserdata::stop() { backend()->stopSource(handle); }
void AudioSourceUserdata::pause() { backend()->pauseSource(handle, true); }
bool AudioSourceUserdata::isPlaying() const { return backend()->isSourcePlaying(handle); }
bool AudioSourceUserdata::isFinished() const
{
	auto *audio = backend();
	return !audio->isSourcePlaying(handle) && !audio->isSourcePaused(handle);
}

void AudioSourceUserdata::setPitch(float value)
{
	if (!std::isfinite(value) || value <= 0.0f)
		throw ::love::Exception("pitch must be positive and finite");
	backend()->setSourcePitch(handle, value);
}

float AudioSourceUserdata::getPitch() const { return backend()->getSourcePitch(handle); }

void AudioSourceUserdata::setVolume(float value)
{
	if (!std::isfinite(value) || value < 0.0f || value > 1.0f)
		throw ::love::Exception("volume must be between 0 and 1");
	backend()->setSourceVolume(handle, value);
}

float AudioSourceUserdata::getVolume() const { return backend()->getSourceVolume(handle); }

void AudioSourceUserdata::seek(double offset, Unit unit)
{
	if (!std::isfinite(offset) || offset < 0.0)
		throw ::love::Exception("seek offset must be non-negative and finite");
	if (unit == UNIT_SAMPLES)
	{
		const double rate = backend()->getSourceSampleRate(handle);
		if (rate <= 0.0) throw ::love::Exception("Source sample rate is unavailable.");
		offset /= rate;
	}
	backend()->seekSource(handle, offset);
}

double AudioSourceUserdata::tell(Unit unit)
{
	double result = backend()->tellSource(handle);
	if (unit == UNIT_SAMPLES) result *= backend()->getSourceSampleRate(handle);
	return result;
}

double AudioSourceUserdata::getDuration(Unit unit)
{
	return unit == UNIT_SAMPLES ? backend()->getSourceSampleCount(handle)
		: backend()->getSourceDuration(handle);
}

namespace
{
void requireFiniteAudioVector(const float *value, const char *label)
{
	if (!std::isfinite(value[0]) || !std::isfinite(value[1]) || !std::isfinite(value[2]))
		throw ::love::Exception("%s must be finite", label);
}

bool toBackendFilter(const std::map<::love::audio::Filter::Parameter, float> &params,
	AudioBackend::FilterSettings &settings)
{
	const auto typeValue = params.find(::love::audio::Filter::FILTER_TYPE);
	if (typeValue == params.end()) return false;
	const char *type = nullptr;
	if (!::love::audio::Filter::getConstant(
		static_cast<::love::audio::Filter::Type>(static_cast<int>(typeValue->second)), type))
		return false;
	settings.type = type;
	settings.parameters.clear();
	for (const auto &[parameter, value] : params)
	{
		if (parameter == ::love::audio::Filter::FILTER_TYPE) continue;
		const char *name = nullptr;
		if (!::love::audio::Filter::getConstant(parameter, name,
			static_cast<::love::audio::Filter::Type>(static_cast<int>(typeValue->second)))
			&& !::love::audio::Filter::getConstant(parameter, name,
				::love::audio::Filter::TYPE_BASIC))
			return false;
		if (!std::isfinite(value)) return false;
		settings.parameters[name] = value;
	}
	return true;
}

bool fromBackendFilter(const AudioBackend::FilterSettings &settings,
	std::map<::love::audio::Filter::Parameter, float> &params)
{
	::love::audio::Filter::Type type;
	if (!::love::audio::Filter::getConstant(settings.type.c_str(), type)) return false;
	params.clear();
	params[::love::audio::Filter::FILTER_TYPE] = static_cast<float>(type);
	for (const auto &[name, value] : settings.parameters)
	{
		::love::audio::Filter::Parameter parameter;
		if (!::love::audio::Filter::getConstant(name.c_str(), parameter, type)
			&& !::love::audio::Filter::getConstant(name.c_str(), parameter,
				::love::audio::Filter::TYPE_BASIC))
			continue;
		params[parameter] = value;
	}
	return true;
}
}

void AudioSourceUserdata::setPosition(float *value)
{
	requireSpatial(); requireFiniteAudioVector(value, "source position");
	backend()->setSourcePosition(handle, value[0], value[1], value[2]);
}

void AudioSourceUserdata::getPosition(float *value) const
{
	requireSpatial(); backend()->getSourcePosition(handle, value[0], value[1], value[2]);
}

void AudioSourceUserdata::setVelocity(float *value)
{
	requireSpatial(); requireFiniteAudioVector(value, "source velocity");
	backend()->setSourceVelocity(handle, value[0], value[1], value[2]);
}

void AudioSourceUserdata::getVelocity(float *value) const
{
	requireSpatial(); backend()->getSourceVelocity(handle, value[0], value[1], value[2]);
}

void AudioSourceUserdata::setDirection(float *value)
{
	requireSpatial(); requireFiniteAudioVector(value, "source direction");
	backend()->setSourceDirection(handle, value[0], value[1], value[2]);
}

void AudioSourceUserdata::getDirection(float *value) const
{
	requireSpatial(); backend()->getSourceDirection(handle, value[0], value[1], value[2]);
}

void AudioSourceUserdata::setCone(float innerAngle, float outerAngle,
	float outerVolume, float outerHighGain)
{
	requireSpatial();
	constexpr float TwoPi = 6.28318530717958647692f;
	if (!std::isfinite(innerAngle) || innerAngle < 0.0f || innerAngle > TwoPi
		|| !std::isfinite(outerAngle) || outerAngle < 0.0f || outerAngle > TwoPi)
		throw ::love::Exception("cone angles must be between 0 and 2*pi");
	if (!std::isfinite(outerVolume) || outerVolume < 0.0f || outerVolume > 1.0f
		|| !std::isfinite(outerHighGain) || outerHighGain < 0.0f || outerHighGain > 1.0f)
		throw ::love::Exception("cone volume and high-frequency gain must be between 0 and 1");
	constexpr float RadToDeg = 57.2957795130823208768f;
	constexpr float DegToRad = 0.0174532925199432957692f;
	innerAngle = static_cast<float>(static_cast<int>(innerAngle * RadToDeg)) * DegToRad;
	outerAngle = static_cast<float>(static_cast<int>(outerAngle * RadToDeg)) * DegToRad;
	backend()->setSourceCone(handle, innerAngle, outerAngle, outerVolume, outerHighGain);
}

void AudioSourceUserdata::getCone(float &innerAngle, float &outerAngle,
	float &outerVolume, float &outerHighGain) const
{
	requireSpatial();
	backend()->getSourceCone(handle, innerAngle, outerAngle, outerVolume, outerHighGain);
}

void AudioSourceUserdata::setRelative(bool enable)
{ requireSpatial(); backend()->setSourceRelative(handle, enable); }
bool AudioSourceUserdata::isRelative() const
{ requireSpatial(); return backend()->isSourceRelative(handle); }

void AudioSourceUserdata::setLooping(bool looping)
{
	if (queueable && looping) throw ::love::Exception("Queueable Sources can not be looped.");
	backend()->setSourceLooping(handle, looping);
}
bool AudioSourceUserdata::isLooping() const { return backend()->isSourceLooping(handle); }

void AudioSourceUserdata::setMinVolume(float volume)
{
	float minimum = 0.0f, maximum = 1.0f;
	backend()->getSourceVolumeLimits(handle, minimum, maximum);
	backend()->setSourceVolumeLimits(handle, volume, maximum);
}
float AudioSourceUserdata::getMinVolume() const
{
	float minimum = 0.0f, maximum = 1.0f;
	backend()->getSourceVolumeLimits(handle, minimum, maximum); return minimum;
}
void AudioSourceUserdata::setMaxVolume(float volume)
{
	float minimum = 0.0f, maximum = 1.0f;
	backend()->getSourceVolumeLimits(handle, minimum, maximum);
	backend()->setSourceVolumeLimits(handle, minimum, volume);
}
float AudioSourceUserdata::getMaxVolume() const
{
	float minimum = 0.0f, maximum = 1.0f;
	backend()->getSourceVolumeLimits(handle, minimum, maximum); return maximum;
}

void AudioSourceUserdata::setReferenceDistance(float distance)
{
	requireSpatial(); float reference = 1.0f, maximum = 1000000.0f;
	backend()->getSourceAttenuationDistances(handle, reference, maximum);
	backend()->setSourceAttenuationDistances(handle, distance, maximum);
}
float AudioSourceUserdata::getReferenceDistance() const
{
	requireSpatial(); float reference = 1.0f, maximum = 1000000.0f;
	backend()->getSourceAttenuationDistances(handle, reference, maximum); return reference;
}
void AudioSourceUserdata::setMaxDistance(float distance)
{
	requireSpatial(); float reference = 1.0f, maximum = 1000000.0f;
	backend()->getSourceAttenuationDistances(handle, reference, maximum);
	backend()->setSourceAttenuationDistances(handle, reference, distance);
}
float AudioSourceUserdata::getMaxDistance() const
{
	requireSpatial(); float reference = 1.0f, maximum = 1000000.0f;
	backend()->getSourceAttenuationDistances(handle, reference, maximum); return maximum;
}
void AudioSourceUserdata::setRolloffFactor(float factor)
{ requireSpatial(); backend()->setSourceRolloff(handle, factor); }
float AudioSourceUserdata::getRolloffFactor() const
{ requireSpatial(); return backend()->getSourceRolloff(handle); }
void AudioSourceUserdata::setAirAbsorptionFactor(float factor)
{ requireSpatial(); backend()->setSourceAirAbsorption(handle, factor); }
float AudioSourceUserdata::getAirAbsorptionFactor() const
{ requireSpatial(); return backend()->getSourceAirAbsorption(handle); }

int AudioSourceUserdata::getChannelCount() const
{
	const int channels = backend()->getSourceChannelCount(handle);
	if (channels <= 0) throw ::love::Exception("Source channel count is unavailable.");
	return channels;
}

bool AudioSourceUserdata::setFilter(
	const std::map<::love::audio::Filter::Parameter, float> &params)
{
	AudioBackend::FilterSettings settings;
	if (!toBackendFilter(params, settings)) throw ::love::Exception("Invalid Source filter.");
	std::string error;
	const bool result = runtime->setAudioSourceFilter(handle, &settings, error);
	if (!result && !error.empty()) throw ::love::Exception("%s", error.c_str());
	return result;
}

bool AudioSourceUserdata::setFilter()
{
	std::string error;
	const bool result = runtime->setAudioSourceFilter(handle, nullptr, error);
	if (!result && !error.empty()) throw ::love::Exception("%s", error.c_str());
	return result;
}

bool AudioSourceUserdata::getFilter(
	std::map<::love::audio::Filter::Parameter, float> &params)
{
	AudioBackend::FilterSettings settings;
	return runtime->getAudioSourceFilter(handle, settings) && fromBackendFilter(settings, params);
}

bool AudioSourceUserdata::setEffect(const char *effect)
{
	std::string error;
	const bool result = runtime->setAudioSourceEffect(handle, effect, nullptr, true, error);
	if (!result && !error.empty()) throw ::love::Exception("%s", error.c_str());
	return result;
}

bool AudioSourceUserdata::setEffect(const char *effect,
	const std::map<::love::audio::Filter::Parameter, float> &params)
{
	AudioBackend::FilterSettings settings;
	if (!toBackendFilter(params, settings)) throw ::love::Exception("Invalid Source effect filter.");
	std::string error;
	const bool result = runtime->setAudioSourceEffect(handle, effect, &settings, true, error);
	if (!result && !error.empty()) throw ::love::Exception("%s", error.c_str());
	return result;
}

bool AudioSourceUserdata::unsetEffect(const char *effect)
{
	std::string error;
	const bool result = runtime->setAudioSourceEffect(handle, effect, nullptr, false, error);
	if (!result && !error.empty()) throw ::love::Exception("%s", error.c_str());
	return result;
}

bool AudioSourceUserdata::getEffect(const char *effect,
	std::map<::love::audio::Filter::Parameter, float> &params)
{
	std::optional<AudioBackend::FilterSettings> settings;
	if (!runtime->getAudioSourceEffect(handle, effect, settings)) return false;
	params.clear();
	return !settings || fromBackendFilter(*settings, params);
}

bool AudioSourceUserdata::getActiveEffects(std::vector<std::string> &list) const
{ runtime->getAudioSourceEffects(handle, list); return true; }
int AudioSourceUserdata::getFreeBufferCount() const
{ return backend()->getSourceFreeBufferCount(handle); }

bool AudioSourceUserdata::queue(void *data, size_t length, int dataSampleRate,
	int dataBitDepth, int dataChannels)
{
	if (!queueable) throw ::love::Exception("Only queueable Sources can be queued with sound data.");
	std::string error;
	const char *bytes = length == 0 ? "" : static_cast<const char *>(data);
	const bool result = backend()->queueSource(handle, {bytes, length}, dataSampleRate,
		dataBitDepth, dataChannels, error);
	if (!result && !error.empty()) throw ::love::Exception("%s", error.c_str());
	return result;
}

void AudioSourceUserdata::onProxyCreated(lua_State *state, int index)
{
	index = lua_absindex(state, index);
	lua_getfield(state, LUA_REGISTRYINDEX, AudioSourceRegistry);
	if (!lua_istable(state, -1))
	{
		lua_pop(state, 1);
		lua_newtable(state);
		lua_newtable(state);
		lua_pushliteral(state, "v");
		lua_setfield(state, -2, "__mode");
		lua_setmetatable(state, -2);
		lua_pushvalue(state, -1);
		lua_setfield(state, LUA_REGISTRYINDEX, AudioSourceRegistry);
	}
	lua_pushinteger(state, static_cast<lua_Integer>(handle));
	lua_pushvalue(state, index);
	lua_rawset(state, -3);
	lua_pop(state, 1);
}

class ContentVideoFile final : public ::love::filesystem::File
{
public:
	ContentVideoFile(std::string filename, std::string bytes)
		: _filename(std::move(filename)), _bytes(std::move(bytes)) { }

	bool open(Mode mode) override
	{
		if (mode != MODE_READ) return false;
		_mode = mode;
		_position = 0;
		return true;
	}
	bool close() override { _mode = MODE_CLOSED; return true; }
	bool isOpen() const override { return _mode != MODE_CLOSED; }
	::love::int64 getSize() override { return static_cast<::love::int64>(_bytes.size()); }
	::love::int64 read(void *destination, ::love::int64 size) override
	{
		if (size <= 0 || _position >= _bytes.size()) return 0;
		const auto count = std::min<std::size_t>(static_cast<std::size_t>(size),
			_bytes.size() - _position);
		std::memcpy(destination, _bytes.data() + _position, count);
		_position += count;
		return static_cast<::love::int64>(count);
	}
	bool write(const void *, ::love::int64) override { return false; }
	bool flush() override { return false; }
	bool isEOF() override { return _position >= _bytes.size(); }
	::love::int64 tell() override { return static_cast<::love::int64>(_position); }
	bool seek(::love::uint64 position) override
	{
		if (position > _bytes.size()) return false;
		_position = static_cast<std::size_t>(position);
		return true;
	}
	bool setBuffer(BufferMode mode, ::love::int64 size) override
	{
		_bufferMode = mode;
		_bufferSize = size;
		return true;
	}
	BufferMode getBuffer(::love::int64 &size) const override
	{
		size = _bufferSize;
		return _bufferMode;
	}
	Mode getMode() const override { return _mode; }
	const std::string &getFilename() const override { return _filename; }

private:
	std::string _filename;
	std::string _bytes;
	std::size_t _position = 0;
	Mode _mode = MODE_READ;
	BufferMode _bufferMode = BUFFER_NONE;
	::love::int64 _bufferSize = 0;
};

struct VideoStreamState
{
	~VideoStreamState()
	{
		stopping.store(true);
		if (worker.joinable()) worker.join();
	}
	void start()
	{
		worker = std::thread([this]() {
			auto previous = std::chrono::steady_clock::now();
			while (!stopping.load())
			{
				const auto now = std::chrono::steady_clock::now();
				const double delta = std::chrono::duration<double>(now - previous).count();
				previous = now;
				try { stream->threadedFillBackBuffer(delta); }
				catch (...) { stopping.store(true); }
				std::this_thread::sleep_for(std::chrono::milliseconds(2));
			}
		});
	}

	LoveRuntime *runtime = nullptr;
	::love::StrongRef<ContentVideoFile> file;
	::love::StrongRef<::love::video::theora::TheoraVideoStream> stream;
	std::thread worker;
	std::atomic<bool> stopping = false;
};

struct VideoStreamUserdata final : ::love::video::VideoStream
{
	~VideoStreamUserdata() override = default;
	void fillBackBuffer() override { state->stream->fillBackBuffer(); }
	const void *getFrontBuffer() const override { return state->stream->getFrontBuffer(); }
	size_t getSize() const override { return state->stream->getSize(); }
	bool swapBuffers() override { return state->stream->swapBuffers(); }
	int getWidth() const override { return state->stream->getWidth(); }
	int getHeight() const override { return state->stream->getHeight(); }
	const std::string &getFilename() const override { return state->stream->getFilename(); }
	void play() override { state->stream->play(); }
	void pause() override { state->stream->pause(); }
	void seek(double offset) override
	{
		if (!std::isfinite(offset) || offset < 0.0)
			throw ::love::Exception("seek offset must be a finite non-negative number");
		state->stream->seek(offset);
	}
	double tell() const override { return state->stream->tell(); }
	bool isPlaying() const override { return state->stream->isPlaying(); }
	void setSync(FrameSync *sync) override { state->stream->setSync(sync); }
	FrameSync *getSync() const override { return state->stream->getSync(); }
	std::shared_ptr<VideoStreamState> state;
};

struct VideoUserdata final
	: DoraHandleObject<GraphicsBackend::ImageHandle, &LoveRuntime::retainLoveImageHandle,
		&LoveRuntime::releaseLoveImage, &LoveRuntime::forgetLoveImageHandle,
		::love::graphics::Video>
{
	using DoraHandle = DoraHandleObject<GraphicsBackend::ImageHandle,
		&LoveRuntime::retainLoveImageHandle, &LoveRuntime::releaseLoveImage,
		&LoveRuntime::forgetLoveImageHandle, ::love::graphics::Video>;
	VideoUserdata(LoveRuntime *valueRuntime, VideoStreamUserdata *valueStream,
		GraphicsBackend::ImageHandle valueImage, float dpiScale)
		: DoraHandle(valueRuntime, valueImage, std::in_place), stream(valueStream),
		  width(static_cast<int>(valueStream->getWidth() / dpiScale)),
		  height(static_cast<int>(valueStream->getHeight() / dpiScale)) { }
	~VideoUserdata() override { if (source) source->stop(); }
	void draw(::love::graphics::Graphics *, const ::love::Matrix4 &) override
	{
		throw ::love::Exception(
			"Dora embedded Video must be submitted through its state-local graphics adapter.");
	}
	::love::video::VideoStream *getStream() override { return stream; }
	::love::audio::Source *getSource() override { return source; }
	void setSource(::love::audio::Source *value) override;
	int getWidth() const override { return width; }
	int getHeight() const override { return height; }
	int getPixelWidth() const override { return stream->getWidth(); }
	int getPixelHeight() const override { return stream->getHeight(); }
	void setFilter(const ::love::graphics::Texture::Filter &value) override;
	const ::love::graphics::Texture::Filter &getFilter() const override { return filter; }
	GraphicsBackend::TextureFilter backendFilter() const
	{
		return filter.min == ::love::graphics::Texture::FILTER_NEAREST
			? GraphicsBackend::TextureFilter::Nearest
			: filter.anisotropy > 1.0f ? GraphicsBackend::TextureFilter::Anisotropic
			: GraphicsBackend::TextureFilter::Linear;
	}
	::love::StrongRef<VideoStreamUserdata> stream;
	::love::StrongRef<::love::audio::Source> source;
	::love::graphics::Texture::Filter filter;
	int width = 0;
	int height = 0;
};

void VideoUserdata::setFilter(const ::love::graphics::Texture::Filter &value)
{
	using Texture = ::love::graphics::Texture;
	if ((value.min != Texture::FILTER_LINEAR && value.min != Texture::FILTER_NEAREST)
		|| value.mag != value.min)
		throw ::love::Exception(
			"embedded Dora Videos require matching 'linear' or 'nearest' filters");
	if (!std::isfinite(value.anisotropy) || value.anisotropy < 0.0f)
		throw ::love::Exception("anisotropy must be a finite non-negative number");
	filter = value;
	filter.mipmap = Texture::FILTER_NONE;
	filter.anisotropy = std::max(1.0f, value.anisotropy);
}

void VideoUserdata::setSource(::love::audio::Source *value)
{
	if (value)
	{
		auto *doraSource = dynamic_cast<AudioSourceUserdata *>(value);
		if (!doraSource || doraSource->runtime != runtime || doraSource->handle == 0)
			throw ::love::Exception("Source belongs to another or closed LoveRuntime");
	}
	source = value;
}

static_assert(std::is_base_of_v<::love::graphics::Drawable, ImageUserdata>);
static_assert(std::is_base_of_v<::love::graphics::Drawable, CanvasUserdata>);
static_assert(std::is_base_of_v<::love::graphics::Drawable, MeshUserdata>);
static_assert(std::is_base_of_v<::love::graphics::Drawable, SpriteBatchUserdata>);
static_assert(std::is_base_of_v<::love::graphics::Drawable, ParticleSystemUserdata>);
static_assert(std::is_base_of_v<::love::graphics::Drawable, TextUserdata>);
static_assert(std::is_base_of_v<::love::graphics::Drawable, VideoUserdata>);

std::vector<std::uint8_t> convertVideoFrame(const ::love::video::VideoStream::Frame &frame);

struct RecordingDeviceUserdata final
	: DoraHandleObject<AudioBackend::RecordingHandle, &LoveRuntime::retainLoveRecordingHandle,
		&LoveRuntime::stopLoveRecording, &LoveRuntime::forgetLoveRecordingHandle>
{
	using DoraHandle = DoraHandleObject<AudioBackend::RecordingHandle,
		&LoveRuntime::retainLoveRecordingHandle, &LoveRuntime::stopLoveRecording,
		&LoveRuntime::forgetLoveRecordingHandle>;
	static ::love::Type type;
	RecordingDeviceUserdata(LoveRuntime *valueRuntime, std::string valueName)
		: DoraHandle(valueRuntime, 0), name(std::move(valueName)) { }
	std::string name;
	int maxSamples = 8192;
	int sampleRate = 8000;
	int bitDepth = 16;
	int channels = 1;
};

::love::Type RecordingDeviceUserdata::type("RecordingDevice", &::love::Object::type);

using JoystickUserdata = DoraLoveJoystick;

using FileMode = ::love::filesystem::File::Mode;

struct FileUserdata final : ::love::filesystem::File
{
	~FileUserdata() override = default;
	bool open(Mode value) override;
	bool close() override;
	bool isOpen() const override;
	::love::int64 getSize() override;
	::love::int64 read(void *destination, ::love::int64 size) override;
	bool write(const void *source, ::love::int64 size) override;
	bool flush() override;
	bool isEOF() override;
	::love::int64 tell() override;
	bool seek(::love::uint64 value) override;
	bool setBuffer(BufferMode value, ::love::int64 size) override;
	BufferMode getBuffer(::love::int64 &size) const override;
	Mode getMode() const override;
	const std::string &getFilename() const override;

	LoveRuntime *runtime = nullptr;
	std::string filename;
	std::string data;
	std::size_t position = 0;
	Mode mode = MODE_CLOSED;
	BufferMode bufferMode = BUFFER_NONE;
	std::size_t bufferSize = 0;
};

struct PhysicsWorldUserdata final
	: DoraHandleObject<PhysicsBackend::WorldHandle, &LoveRuntime::retainLovePhysicsWorldHandle,
		&LoveRuntime::releaseLovePhysicsWorld, &LoveRuntime::forgetLovePhysicsWorldHandle,
		::love::physics::World>
{
	using DoraHandle = DoraHandleObject<PhysicsBackend::WorldHandle,
		&LoveRuntime::retainLovePhysicsWorldHandle, &LoveRuntime::releaseLovePhysicsWorld,
		&LoveRuntime::forgetLovePhysicsWorldHandle, ::love::physics::World>;
	PhysicsWorldUserdata(LoveRuntime *valueRuntime, PhysicsBackend::WorldHandle valueHandle)
		: DoraHandle(valueRuntime, valueHandle) { }
	bool isDestroyed() const override;
	void update(float dt) override;
	void update(float dt, int velocityIterations, int positionIterations) override;
	int setCallbacks(lua_State *L) override;
	int getCallbacks(lua_State *L) override;
	void setGravity(float x, float y) override;
	int getGravity(lua_State *L) override;
	void translateOrigin(float x, float y) override;
	void setSleepingAllowed(bool allow) override;
	bool isSleepingAllowed() const override;
	bool isLocked() const override { return updating; }
	int getBodyCount() const override;
	int getJointCount() const override;
	int getContactCount() const override;
	int getBodies(lua_State *L) const override;
	int getJoints(lua_State *L) const override;
	int getContacts(lua_State *L) override;
	int queryBoundingBox(lua_State *L) override;
	int rayCast(lua_State *L) override;
	void destroy() override;
	bool updating = false;
};

struct PhysicsBodyUserdata final
	: DoraHandleObject<PhysicsBackend::BodyHandle, &LoveRuntime::retainLovePhysicsBodyHandle,
		&LoveRuntime::releaseLovePhysicsBody, &LoveRuntime::forgetLovePhysicsBodyHandle,
		::love::physics::Body>
{
	using DoraHandle = DoraHandleObject<PhysicsBackend::BodyHandle,
		&LoveRuntime::retainLovePhysicsBodyHandle, &LoveRuntime::releaseLovePhysicsBody,
		&LoveRuntime::forgetLovePhysicsBodyHandle, ::love::physics::Body>;
	PhysicsBodyUserdata(LoveRuntime *valueRuntime, PhysicsBackend::BodyHandle valueHandle,
		PhysicsBackend::WorldHandle valueWorld, std::string valueType)
		: DoraHandle(valueRuntime, valueHandle), world(valueWorld), type(std::move(valueType)) { }
	bool isDestroyed() const override;
	float getX() override; float getY() override; float getAngle() override;
	void getPosition(float &x, float &y) override;
	void getLinearVelocity(float &x, float &y) override;
	void getWorldCenter(float &x, float &y) override;
	void getLocalCenter(float &x, float &y) override;
	float getAngularVelocity() const override;
	float getMass() const override; float getInertia() const override;
	int getMassData(lua_State *L) override;
	float getAngularDamping() const override; float getLinearDamping() const override;
	float getGravityScale() const override; Type getType() const override;
	void applyLinearImpulse(float x, float y, bool wake) override;
	void applyLinearImpulse(float x, float y, float px, float py, bool wake) override;
	void applyAngularImpulse(float impulse, bool wake) override;
	void applyTorque(float torque, bool wake) override;
	void applyForce(float x, float y, bool wake) override;
	void applyForce(float x, float y, float px, float py, bool wake) override;
	void setX(float x) override; void setY(float y) override;
	void setLinearVelocity(float x, float y) override; void setAngle(float angle) override;
	void setAngularVelocity(float velocity) override; void setPosition(float x, float y) override;
	void resetMassData() override;
	void setMassData(float x, float y, float mass, float inertia) override;
	void setMass(float mass) override; void setInertia(float inertia) override;
	void setAngularDamping(float damping) override; void setLinearDamping(float damping) override;
	void setGravityScale(float scale) override; void setType(Type type) override;
	void getWorldPoint(float x, float y, float &outX, float &outY) override;
	void getWorldVector(float x, float y, float &outX, float &outY) override;
	int getWorldPoints(lua_State *L) override;
	void getLocalPoint(float x, float y, float &outX, float &outY) override;
	void getLocalVector(float x, float y, float &outX, float &outY) override;
	int getLocalPoints(lua_State *L) override;
	void getLinearVelocityFromWorldPoint(float x, float y, float &outX, float &outY) override;
	void getLinearVelocityFromLocalPoint(float x, float y, float &outX, float &outY) override;
	bool isBullet() const override; void setBullet(bool bullet) override;
	bool isActive() const override; bool isAwake() const override;
	void setSleepingAllowed(bool allow) override; bool isSleepingAllowed() const override;
	void setActive(bool active) override; void setAwake(bool awake) override;
	void setFixedRotation(bool fixed) override; bool isFixedRotation() const override;
	bool isTouching(::love::physics::Body *other) const override;
	::love::physics::World *getWorld() const override;
	int getFixtures(lua_State *L) const override; int getJoints(lua_State *L) const override;
	int getContacts(lua_State *L) const override;
	void destroy() override; int setUserData(lua_State *L) override; int getUserData(lua_State *L) override;
	PhysicsBackend::WorldHandle world = 0;
	std::string type;
	::love::StrongRef<PhysicsWorldUserdata> worldObject;
	::love::Reference userData;
};

struct PhysicsShapeUserdata final
	: DoraHandleObject<PhysicsBackend::ShapeHandle, &LoveRuntime::retainLovePhysicsShapeHandle,
		&LoveRuntime::releaseLovePhysicsShape, &LoveRuntime::forgetLovePhysicsShapeHandle,
		::love::physics::Shape>
{
	using DoraHandle = DoraHandleObject<PhysicsBackend::ShapeHandle,
		&LoveRuntime::retainLovePhysicsShapeHandle, &LoveRuntime::releaseLovePhysicsShape,
		&LoveRuntime::forgetLovePhysicsShapeHandle, ::love::physics::Shape>;
	PhysicsShapeUserdata() = default;
	PhysicsShapeUserdata(LoveRuntime *valueRuntime, PhysicsBackend::ShapeHandle valueHandle,
		std::string valueType, float valueRadius, std::vector<float> valuePoints)
		: DoraHandle(valueRuntime, valueHandle), type(std::move(valueType)),
		  radius(valueRadius), points(std::move(valuePoints)) { }
	::love::physics::Shape::Type getType() const override;
	float getRadius() const override; void setRadius(float value) override;
	void getPoint(float &x, float &y) const override; void setPoint(float x, float y) override;
	int getPoints(lua_State *L) const override; bool validate() const override;
	int getChildCount() const override; int getVertexCount() const override;
	void getPoint(int index, float &x, float &y) const override;
	::love::physics::Shape *getChildEdge(int index) const override;
	void setNextVertex() override; void setNextVertex(float x, float y) override;
	void setPreviousVertex() override; void setPreviousVertex(float x, float y) override;
	bool getNextVertex(float &x, float &y) const override;
	bool getPreviousVertex(float &x, float &y) const override;
	bool testPoint(float x, float y, float angle, float px, float py) const override;
	int rayCast(lua_State *L) const override; int computeAABB(lua_State *L) const override;
	int computeMass(lua_State *L) const override;
	std::string type;
	float radius = 0.0f;
	std::vector<float> points;
	bool loop = false;
	bool hasPreviousVertex = false;
	float previousX = 0.0f;
	float previousY = 0.0f;
	bool hasNextVertex = false;
	float nextX = 0.0f;
	float nextY = 0.0f;
};

struct PhysicsFixtureUserdata final
	: DoraHandleObject<PhysicsBackend::FixtureHandle, &LoveRuntime::retainLovePhysicsFixtureHandle,
		&LoveRuntime::releaseLovePhysicsFixture, &LoveRuntime::forgetLovePhysicsFixtureHandle,
		::love::physics::Fixture>
{
	using DoraHandle = DoraHandleObject<PhysicsBackend::FixtureHandle,
		&LoveRuntime::retainLovePhysicsFixtureHandle, &LoveRuntime::releaseLovePhysicsFixture,
		&LoveRuntime::forgetLovePhysicsFixtureHandle, ::love::physics::Fixture>;
	PhysicsFixtureUserdata() = default;
	PhysicsFixtureUserdata(LoveRuntime *valueRuntime, PhysicsBackend::FixtureHandle valueHandle,
		float valueDensity) : DoraHandle(valueRuntime, valueHandle), density(valueDensity) { }
	::love::physics::Shape::Type getType() override;
	::love::physics::Shape *getShape() override;
	bool isValid() const override; bool isSensor() const override; void setSensor(bool value) override;
	::love::physics::Body *getBody() const override;
	void setFilterData(int *values) override; void getFilterData(int *values) override;
	int setUserData(lua_State *L) override; int getUserData(lua_State *L) override;
	void setFriction(float value) override; void setRestitution(float value) override;
	void setDensity(float value) override;
	float getFriction() const override; float getRestitution() const override;
	float getDensity() const override; bool testPoint(float x, float y) const override;
	int rayCast(lua_State *L) const override;
	void setGroupIndex(int index) override; int getGroupIndex() const override;
	int setCategory(lua_State *L) override; int setMask(lua_State *L) override;
	int getCategory(lua_State *L) override; int getMask(lua_State *L) override;
	int getBoundingBox(lua_State *L) const override; int getMassData(lua_State *L) const override;
	void destroy() override;
	float density = 1.0f;
	float friction = 0.2f;
	float restitution = 0.0f;
	bool sensor = false;
	::love::StrongRef<PhysicsBodyUserdata> bodyObject;
	::love::StrongRef<PhysicsShapeUserdata> shapeObject;
	::love::Reference userData;
};

struct PhysicsJointUserdata final
	: DoraHandleObject<PhysicsBackend::JointHandle, &LoveRuntime::retainLovePhysicsJointHandle,
		&LoveRuntime::releaseLovePhysicsJoint, &LoveRuntime::forgetLovePhysicsJointHandle,
		::love::physics::Joint>
{
	using DoraHandle = DoraHandleObject<PhysicsBackend::JointHandle,
		&LoveRuntime::retainLovePhysicsJointHandle, &LoveRuntime::releaseLovePhysicsJoint,
		&LoveRuntime::forgetLovePhysicsJointHandle, ::love::physics::Joint>;
	PhysicsJointUserdata(LoveRuntime *valueRuntime, PhysicsBackend::JointHandle valueHandle,
		std::string valueType) : DoraHandle(valueRuntime, valueHandle), type(std::move(valueType)) { }
	::love::physics::Joint::Type getType() const override;
	bool isValid() const override;
	::love::physics::Body *getBodyA() const override;
	::love::physics::Body *getBodyB() const override;
	int getAnchors(lua_State *L) const override;
	int getReactionForce(lua_State *L) const override;
	float getReactionTorque(float inverseDeltaTime) const override;
	bool getCollideConnected() const override;
	int setUserData(lua_State *L) override;
	int getUserData(lua_State *L) override;
	void destroyJoint() override;
	float getScalar(::love::physics::Joint::ScalarProperty property,
		float argument = 0.0f) const override;
	void setScalar(::love::physics::Joint::ScalarProperty property, float value) override;
	bool getBoolean(::love::physics::Joint::BooleanProperty property) const override;
	void setBoolean(::love::physics::Joint::BooleanProperty property, bool value) override;
	void getVector(::love::physics::Joint::VectorProperty property,
		float &x, float &y) const override;
	void setVector(::love::physics::Joint::VectorProperty property, float x, float y) override;
	void getLimits(float &lower, float &upper) const override;
	void setLimits(float lower, float upper) override;
	int getGroundAnchors(lua_State *L) const override;
	void getJoints(::love::physics::Joint *&jointA,
		::love::physics::Joint *&jointB) const override;
	std::string type;
	::love::StrongRef<PhysicsBodyUserdata> bodyAObject;
	::love::StrongRef<PhysicsBodyUserdata> bodyBObject;
	::love::StrongRef<PhysicsJointUserdata> jointAObject;
	::love::StrongRef<PhysicsJointUserdata> jointBObject;
	::love::Reference userData;
};

struct PhysicsContactUserdata final : ::love::physics::Contact
{
	PhysicsContactUserdata() = default;
	PhysicsContactUserdata(LoveRuntime *valueRuntime, PhysicsBackend::ContactHandle valueHandle,
		PhysicsBackend::WorldHandle valueWorld, PhysicsBackend::FixtureHandle valueFixtureA,
		PhysicsBackend::FixtureHandle valueFixtureB, int valueChildA, int valueChildB)
		: runtime(valueRuntime), handle(valueHandle), world(valueWorld), fixtureA(valueFixtureA),
		  fixtureB(valueFixtureB), childA(valueChildA), childB(valueChildB) { }
	~PhysicsContactUserdata() override = default;
	bool isValid() const override; int getPositions(lua_State *L) override;
	int getNormal(lua_State *L) override; float getFriction() const override;
	float getRestitution() const override; bool isEnabled() const override;
	bool isTouching() const override; void setFriction(float value) override;
	void setRestitution(float value) override; void setEnabled(bool value) override;
	void resetFriction() override; void resetRestitution() override;
	void setTangentSpeed(float value) override; float getTangentSpeed() const override;
	void getChildren(int &a, int &b) override;
	void getFixtures(::love::physics::Fixture *&a, ::love::physics::Fixture *&b) override;
	LoveRuntime *runtime = nullptr;
	PhysicsBackend::ContactHandle handle = 0;
	PhysicsBackend::WorldHandle world = 0;
	PhysicsBackend::FixtureHandle fixtureA = 0;
	PhysicsBackend::FixtureHandle fixtureB = 0;
	int childA = 0;
	int childB = 0;
	::love::StrongRef<PhysicsFixtureUserdata> fixtureAObject;
	::love::StrongRef<PhysicsFixtureUserdata> fixtureBObject;
};

const char *physicsShapeObjectName(const PhysicsShapeUserdata *shape)
{
	if (shape->type == "circle") return "CircleShape";
	if (shape->type == "edge") return "EdgeShape";
	if (shape->type == "chain") return "ChainShape";
	return "PolygonShape";
}

int physicsShapeObjectType(lua_State *state)
{
	auto *shape = ::love::luax_checktype<PhysicsShapeUserdata>(state, 1, ::love::physics::Shape::type);
	lua_pushstring(state, physicsShapeObjectName(shape));
	return 1;
}

int physicsShapeObjectTypeOf(lua_State *state)
{
	auto *shape = ::love::luax_checktype<PhysicsShapeUserdata>(state, 1, ::love::physics::Shape::type);
	const std::string_view requested = luaL_checkstring(state, 2);
	lua_pushboolean(state, requested == physicsShapeObjectName(shape)
		|| requested == "Shape" || requested == "Object");
	return 1;
}

const char *physicsJointObjectName(const PhysicsJointUserdata *joint)
{
	if (joint->type == "distance") return "DistanceJoint";
	if (joint->type == "revolute") return "RevoluteJoint";
	if (joint->type == "prismatic") return "PrismaticJoint";
	if (joint->type == "weld") return "WeldJoint";
	if (joint->type == "friction") return "FrictionJoint";
	if (joint->type == "rope") return "RopeJoint";
	if (joint->type == "pulley") return "PulleyJoint";
	if (joint->type == "wheel") return "WheelJoint";
	if (joint->type == "mouse") return "MouseJoint";
	if (joint->type == "motor") return "MotorJoint";
	return "GearJoint";
}

int physicsJointObjectType(lua_State *state)
{
	auto *joint = ::love::luax_checktype<PhysicsJointUserdata>(state, 1, ::love::physics::Joint::type);
	lua_pushstring(state, physicsJointObjectName(joint));
	return 1;
}

int physicsJointObjectTypeOf(lua_State *state)
{
	auto *joint = ::love::luax_checktype<PhysicsJointUserdata>(state, 1, ::love::physics::Joint::type);
	const std::string_view requested = luaL_checkstring(state, 2);
	lua_pushboolean(state, requested == physicsJointObjectName(joint)
		|| requested == "Joint" || requested == "Object");
	return 1;
}

LoveRuntime *runtimeFromUpvalue(lua_State *state)
{
	return static_cast<LoveRuntime *>(lua_touserdata(state, lua_upvalueindex(1)));
}

CanvasUserdata *checkCanvas(lua_State *state, int index)
{
	return ::love::luax_checktype<CanvasUserdata>(state, index);
}

std::size_t meshAttributeByteSize(std::string_view type, int components)
{
	const std::size_t componentSize = type == "float" ? sizeof(float)
		: type == "unorm16" ? sizeof(std::uint16_t) : sizeof(std::uint8_t);
	return componentSize * static_cast<std::size_t>(components);
}

bool decodeMeshStorage(const MeshUserdata &mesh, std::span<const std::uint8_t> bytes,
	std::vector<float> &values)
{
	if (mesh.vertexStride == 0 || bytes.size() < mesh.vertexCount * mesh.vertexStride)
		return false;
	values.assign(mesh.vertexCount * mesh.componentCount, 0.0f);
	for (std::size_t vertex = 0; vertex < mesh.vertexCount; ++vertex)
	{
		const std::uint8_t *source = bytes.data() + vertex * mesh.vertexStride;
		float *destination = values.data() + vertex * mesh.componentCount;
		for (const auto &attribute : mesh.format)
		{
			const std::uint8_t *attributeBytes = source + attribute.byteOffset;
			for (int component = 0; component < attribute.components; ++component)
			{
				float value = 0.0f;
				if (attribute.type == "float")
				{
					std::memcpy(&value, attributeBytes + component * sizeof(float), sizeof(float));
					if (!std::isfinite(value)) return false;
				}
				else if (attribute.type == "unorm16")
				{
					std::uint16_t raw = 0;
					std::memcpy(&raw, attributeBytes + component * sizeof(std::uint16_t), sizeof(raw));
					value = static_cast<float>(raw) / 65535.0f;
				}
				else value = static_cast<float>(attributeBytes[component]) / 255.0f;
				destination[attribute.offset + static_cast<std::size_t>(component)] = value;
			}
		}
	}
	return true;
}

void encodeMeshVertex(MeshUserdata &mesh, std::size_t vertex)
{
	std::uint8_t *destination = mesh.bytes.data() + vertex * mesh.vertexStride;
	float *values = mesh.values.data() + vertex * mesh.componentCount;
	for (const auto &attribute : mesh.format)
	{
		std::uint8_t *attributeBytes = destination + attribute.byteOffset;
		for (int component = 0; component < attribute.components; ++component)
		{
			float &value = values[attribute.offset + static_cast<std::size_t>(component)];
			if (attribute.type == "float")
				std::memcpy(attributeBytes + component * sizeof(float), &value, sizeof(float));
			else if (attribute.type == "unorm16")
			{
				const auto raw = static_cast<std::uint16_t>(std::clamp(value, 0.0f, 1.0f) * 65535.0f);
				std::memcpy(attributeBytes + component * sizeof(std::uint16_t), &raw, sizeof(raw));
				value = static_cast<float>(raw) / 65535.0f;
			}
			else
			{
				const auto raw = static_cast<std::uint8_t>(std::clamp(value, 0.0f, 1.0f) * 255.0f);
				attributeBytes[component] = raw;
				value = static_cast<float>(raw) / 255.0f;
			}
		}
	}
}

void encodeMeshStorage(MeshUserdata &mesh)
{
	mesh.bytes.assign(mesh.vertexCount * mesh.vertexStride, 0);
	for (std::size_t vertex = 0; vertex < mesh.vertexCount; ++vertex)
		encodeMeshVertex(mesh, vertex);
}

MeshUserdata *newDoraMesh(LoveRuntime *runtime,
	const std::vector<::love::graphics::Mesh::AttribFormat> &upstreamFormat,
	std::size_t vertexCount, ::love::graphics::PrimitiveType drawMode,
	::love::graphics::vertex::Usage usage)
{
	if (vertexCount == 0)
		throw ::love::Exception("vertex count must be greater than 0");
	if (upstreamFormat.empty())
		throw ::love::Exception("Mesh vertex format must not be empty");
	auto *mesh = new MeshUserdata;
	mesh->runtime = runtime;
	mesh->upstreamFormat = upstreamFormat;
	const char *drawModeName = nullptr;
	const char *usageName = nullptr;
	if (!::love::graphics::vertex::getConstant(drawMode, drawModeName)
		|| !::love::graphics::vertex::getConstant(usage, usageName))
	{
		mesh->release();
		throw ::love::Exception("Invalid Mesh draw mode or usage hint");
	}
	mesh->drawMode = drawModeName;
	mesh->usage = usageName;
	std::set<std::string> names;
	for (const auto &source : upstreamFormat)
	{
		const char *typeName = nullptr;
		if (source.name.empty() || !names.insert(source.name).second
			|| !::love::graphics::vertex::getConstant(source.type, typeName)
			|| source.components < 1 || source.components > 4)
		{
			mesh->release();
			throw ::love::Exception("Invalid Mesh vertex format");
		}
		MeshAttribute attribute;
		attribute.name = source.name;
		attribute.type = typeName;
		attribute.components = source.components;
		attribute.offset = mesh->componentCount;
		attribute.byteOffset = mesh->vertexStride;
		attribute.byteSize = meshAttributeByteSize(attribute.type, attribute.components);
		if (attribute.byteSize % 4 != 0)
		{
			mesh->release();
			throw ::love::Exception("Mesh vertex attributes must occupy a multiple of 4 bytes");
		}
		mesh->componentCount += static_cast<std::size_t>(attribute.components);
		mesh->vertexStride += attribute.byteSize;
		mesh->format.push_back(std::move(attribute));
	}
	mesh->vertexCount = vertexCount;
	mesh->values.assign(vertexCount * mesh->componentCount, 0.0f);
	mesh->bytes.assign(vertexCount * mesh->vertexStride, 0);
	return mesh;
}

std::size_t meshAttributeIndex(const MeshUserdata &mesh, std::string_view name)
{
	for (std::size_t index = 0; index < mesh.format.size(); ++index)
		if (mesh.format[index].name == name) return index;
	return mesh.format.size();
}

void MeshUserdata::setVertex(size_t vertindex, const void *data, size_t datasize)
{
	if (vertindex >= vertexCount)
		throw ::love::Exception("Invalid vertex index: %zu", vertindex + 1);
	const std::size_t size = std::min(datasize, vertexStride);
	std::memcpy(bytes.data() + vertindex * vertexStride, data, size);
	if (!decodeMeshStorage(*this, bytes, values))
		throw ::love::Exception("Mesh vertex data contains a non-finite float component.");
	++geometryRevision;
}

size_t MeshUserdata::getVertex(size_t vertindex, void *data, size_t datasize)
{
	if (vertindex >= vertexCount)
		throw ::love::Exception("Invalid vertex index: %zu", vertindex + 1);
	const std::size_t size = std::min(datasize, vertexStride);
	std::memcpy(data, bytes.data() + vertindex * vertexStride, size);
	return size;
}

void *MeshUserdata::getVertexScratchBuffer()
{
	vertexScratch.resize(vertexStride);
	return vertexScratch.data();
}

void MeshUserdata::setVertexAttribute(size_t vertindex, int attribindex,
	const void *data, size_t datasize)
{
	if (vertindex >= vertexCount)
		throw ::love::Exception("Invalid vertex index: %zu", vertindex + 1);
	if (attribindex < 0 || static_cast<std::size_t>(attribindex) >= format.size())
		throw ::love::Exception("Invalid vertex attribute index: %d", attribindex + 1);
	const auto &attribute = format[static_cast<std::size_t>(attribindex)];
	const std::size_t size = std::min(datasize, attribute.byteSize);
	std::memcpy(bytes.data() + vertindex * vertexStride + attribute.byteOffset, data, size);
	if (!decodeMeshStorage(*this, bytes, values))
		throw ::love::Exception("Mesh vertex data contains a non-finite float component.");
	++geometryRevision;
}

size_t MeshUserdata::getVertexAttribute(size_t vertindex, int attribindex,
	void *data, size_t datasize)
{
	if (vertindex >= vertexCount)
		throw ::love::Exception("Invalid vertex index: %zu", vertindex + 1);
	if (attribindex < 0 || static_cast<std::size_t>(attribindex) >= format.size())
		throw ::love::Exception("Invalid vertex attribute index: %d", attribindex + 1);
	const auto &attribute = format[static_cast<std::size_t>(attribindex)];
	const std::size_t size = std::min(datasize, attribute.byteSize);
	std::memcpy(data, bytes.data() + vertindex * vertexStride + attribute.byteOffset, size);
	return size;
}

::love::graphics::vertex::DataType MeshUserdata::getAttributeInfo(
	int attribindex, int &components) const
{
	if (attribindex < 0 || static_cast<std::size_t>(attribindex) >= upstreamFormat.size())
		throw ::love::Exception("Invalid vertex attribute index: %d", attribindex + 1);
	const auto &attribute = upstreamFormat[static_cast<std::size_t>(attribindex)];
	components = attribute.components;
	return attribute.type;
}

int MeshUserdata::getAttributeIndex(const std::string &name) const
{
	const std::size_t index = meshAttributeIndex(*this, name);
	return index == format.size() ? -1 : static_cast<int>(index);
}

void MeshUserdata::setAttributeEnabled(const std::string &name, bool enable)
{
	if (auto found = attachments.find(name); found != attachments.end())
		found->second.enabled = enable;
	else
	{
		const std::size_t index = meshAttributeIndex(*this, name);
		if (index == format.size())
			throw ::love::Exception(
				"Mesh does not have an attached vertex attribute named '%s'", name.c_str());
		format[index].enabled = enable;
	}
	++geometryRevision;
}

bool MeshUserdata::isAttributeEnabled(const std::string &name) const
{
	if (const auto found = attachments.find(name); found != attachments.end())
		return found->second.enabled;
	const std::size_t index = meshAttributeIndex(*this, name);
	if (index == format.size())
		throw ::love::Exception(
			"Mesh does not have an attached vertex attribute named '%s'", name.c_str());
	return format[index].enabled;
}

void MeshUserdata::attachAttribute(const std::string &name,
	::love::graphics::Mesh *mesh, const std::string &attachname,
	::love::graphics::AttributeStep step)
{
	auto *source = dynamic_cast<MeshUserdata *>(mesh);
	if (!source || source->runtime != runtime)
		throw ::love::Exception("Attached Mesh belongs to another or closed LoveRuntime.");
	const std::size_t sourceIndex = meshAttributeIndex(*source, attachname);
	if (sourceIndex == source->format.size())
		throw ::love::Exception(
			"The specified Mesh does not have a vertex attribute named '%s'", attachname.c_str());
	if (source != this)
	{
		for (const auto &[attachedName, attachment] : source->attachments)
		{
			(void)attachedName;
			if (attachment.mesh != source)
				throw ::love::Exception(
					"Cannot attach a Mesh which has attached Meshes of its own.");
		}
	}
	bool enabled = true;
	if (const auto old = attachments.find(name); old != attachments.end())
		enabled = old->second.enabled;
	else if (const std::size_t own = meshAttributeIndex(*this, name); own != format.size())
		enabled = format[own].enabled;
	else
	{
		std::size_t uniqueCount = format.size();
		for (const auto &[attachedName, attachment] : attachments)
		{
			(void)attachment;
			if (meshAttributeIndex(*this, attachedName) == format.size()) ++uniqueCount;
		}
		if (uniqueCount >= 16)
			throw ::love::Exception("A maximum of 16 attributes can be attached at once.");
	}
	attachments[name] = {source, sourceIndex,
		step == ::love::graphics::STEP_PER_INSTANCE ? "perinstance" : "pervertex", enabled};
	if (source == this) attachmentObjects.erase(name);
	else attachmentObjects[name].set(source);
	++geometryRevision;
}

bool MeshUserdata::detachAttribute(const std::string &name)
{
	const auto found = attachments.find(name);
	if (found == attachments.end() || found->second.mesh == this) return false;
	attachments.erase(found);
	attachmentObjects.erase(name);
	if (const std::size_t own = meshAttributeIndex(*this, name); own != format.size())
		format[own].enabled = true;
	++geometryRevision;
	return true;
}

void MeshUserdata::unmapVertexData(size_t, size_t)
{
	if (!decodeMeshStorage(*this, bytes, values))
		throw ::love::Exception("Mesh vertex data contains a non-finite float component.");
	++geometryRevision;
}

void MeshUserdata::setVertexMap(const std::vector<::love::uint32> &map)
{
	for (const auto index : map)
		if (index >= vertexCount)
			throw ::love::Exception("Invalid vertex map value: %u", index + 1);
	vertexMap.assign(map.begin(), map.end());
	useVertexMap = true;
	++geometryRevision;
}

void MeshUserdata::setVertexMap(::love::graphics::IndexDataType datatype,
	const void *data, size_t datasize)
{
	const std::size_t elementSize = ::love::graphics::vertex::getIndexDataSize(datatype);
	if (elementSize == 0 || datasize % elementSize != 0)
		throw ::love::Exception("Invalid Mesh vertex map data size.");
	std::vector<::love::uint32> map(datasize / elementSize);
	for (std::size_t index = 0; index < map.size(); ++index)
	{
		if (datatype == ::love::graphics::INDEX_UINT16)
		{
			::love::uint16 value = 0;
			std::memcpy(&value, static_cast<const std::uint8_t *>(data) + index * elementSize,
				elementSize);
			map[index] = value;
		}
		else std::memcpy(&map[index],
			static_cast<const std::uint8_t *>(data) + index * elementSize, elementSize);
	}
	setVertexMap(map);
}

void MeshUserdata::setVertexMap()
{
	useVertexMap = false;
	++geometryRevision;
}

bool MeshUserdata::getVertexMap(std::vector<::love::uint32> &map) const
{
	if (!useVertexMap) return false;
	map.assign(vertexMap.begin(), vertexMap.end());
	return true;
}

void MeshUserdata::setTexture(::love::graphics::Texture *texture)
{
	if (auto *source = dynamic_cast<ImageUserdata *>(texture))
	{
		if (source->runtime != runtime || source->handle == 0)
			throw ::love::Exception("Image belongs to another or closed LoveRuntime.");
		image = source->handle;
		canvas = 0;
		textureObject.set(source);
	}
	else if (auto *target = dynamic_cast<CanvasUserdata *>(texture))
	{
		if (target->runtime != runtime || target->handle == 0)
			throw ::love::Exception("Canvas belongs to another or closed LoveRuntime.");
		image = 0;
		canvas = target->handle;
		textureObject.set(target);
	}
	else throw ::love::Exception("Unsupported Dora Mesh texture backend.");
	++geometryRevision;
}

void MeshUserdata::setTexture()
{
	image = 0;
	canvas = 0;
	textureObject.set(nullptr);
	++geometryRevision;
}

::love::graphics::Texture *MeshUserdata::getTexture() const
{
	return dynamic_cast<::love::graphics::Texture *>(textureObject.get());
}

void MeshUserdata::setDrawMode(::love::graphics::PrimitiveType mode)
{
	const char *name = nullptr;
	if (!::love::graphics::vertex::getConstant(mode, name))
		throw ::love::Exception("Unknown Mesh draw mode.");
	drawMode = name;
	++geometryRevision;
}

::love::graphics::PrimitiveType MeshUserdata::getDrawMode() const
{
	::love::graphics::PrimitiveType mode;
	if (!::love::graphics::vertex::getConstant(drawMode.c_str(), mode))
		throw ::love::Exception("Unknown Mesh draw mode.");
	return mode;
}

void MeshUserdata::setDrawRange(int start, int count)
{
	if (start < 0 || count <= 0) throw ::love::Exception("Invalid draw range.");
	drawStart = start;
	drawCount = count;
	++geometryRevision;
}

void MeshUserdata::setDrawRange()
{
	drawStart = -1;
	drawCount = 0;
	++geometryRevision;
}

bool MeshUserdata::getDrawRange(int &start, int &count) const
{
	if (drawStart < 0 || drawCount <= 0) return false;
	start = drawStart;
	count = drawCount;
	return true;
}

AudioSourceUserdata *checkAudioSource(lua_State *state, int index)
{
	auto *source = ::love::audio::luax_checksource(state, index);
	auto *result = dynamic_cast<AudioSourceUserdata *>(source);
	if (!result) luaL_argerror(state, index, "Dora-backed Source expected");
	return result;
}

AudioSourceUserdata *testAudioSource(lua_State *state, int index)
{
	if (!::love::luax_istype(state, index, ::love::audio::Source::type)) return nullptr;
	return dynamic_cast<AudioSourceUserdata *>(
		::love::luax_totype<::love::audio::Source>(state, index));
}

VideoUserdata *testVideo(lua_State *state, int index)
{
	if (!::love::luax_istype(state, index, ::love::graphics::Video::type)) return nullptr;
	return dynamic_cast<VideoUserdata *>(
		::love::luax_totype<::love::graphics::Video>(state, index));
}

PhysicsWorldUserdata *checkPhysicsWorld(lua_State *state, int index)
{
	return ::love::luax_checktype<PhysicsWorldUserdata>(state, index, ::love::physics::World::type);
}

PhysicsBodyUserdata *checkPhysicsBody(lua_State *state, int index)
{
	return ::love::luax_checktype<PhysicsBodyUserdata>(state, index, ::love::physics::Body::type);
}

PhysicsShapeUserdata *checkPhysicsShape(lua_State *state, int index)
{
	return ::love::luax_checktype<PhysicsShapeUserdata>(state, index, ::love::physics::Shape::type);
}

PhysicsFixtureUserdata *checkPhysicsFixture(lua_State *state, int index)
{
	return ::love::luax_checktype<PhysicsFixtureUserdata>(state, index, ::love::physics::Fixture::type);
}

PhysicsJointUserdata *checkPhysicsJoint(lua_State *state, int index)
{
	return ::love::luax_checktype<PhysicsJointUserdata>(state, index, ::love::physics::Joint::type);
}

const ImagePixelFormatInfo &getImageDataFormat(const ImageDataUserdata &data)
{
	const char *name = nullptr;
	if (!::love::getConstant(data.getFormat(), name)) std::abort();
	const auto *format = imagePixelFormatInfo(name);
	if (!format) std::abort();
	return *format;
}

const char *getImageDataFormatName(const ImageDataUserdata &data)
{
	const char *name = nullptr;
	if (!::love::getConstant(data.getFormat(), name)) std::abort();
	return name;
}

const std::uint8_t *getImageDataPixel(const ImageDataUserdata &data, int x, int y)
{
	const auto &format = getImageDataFormat(data);
	return static_cast<const std::uint8_t *>(data.getData())
		+ (static_cast<std::size_t>(y) * data.getWidth() + x) * format.bytes;
}

bool imageDataToRGBA8(const ImageDataUserdata &data, std::vector<std::uint8_t> &rgba8)
{
	const auto &format = getImageDataFormat(data);
	if (format.value == ImagePixelFormat::RGBA8)
	{
		const auto *bytes = static_cast<const std::uint8_t *>(data.getData());
		rgba8.assign(bytes, bytes + data.getSize());
		return true;
	}
	rgba8.resize(static_cast<std::size_t>(data.getWidth()) * data.getHeight() * 4);
	for (int y = 0; y < data.getHeight(); ++y)
		for (int x = 0; x < data.getWidth(); ++x)
		{
			ImagePixelColor color;
			readImagePixel(format, getImageDataPixel(data, x, y), color);
			const std::size_t offset = (static_cast<std::size_t>(y) * data.getWidth() + x) * 4;
			const auto &rgba8Format = *imagePixelFormatInfo("rgba8");
			writeImagePixel(rgba8Format, rgba8.data() + offset, color);
		}
	return true;
}

GraphicsBackend::TextureFilter toBackendFilter(
	::love::graphics::Texture::FilterMode mode, float anisotropy)
{
	if (mode == ::love::graphics::Texture::FILTER_NEAREST)
		return GraphicsBackend::TextureFilter::Nearest;
	return anisotropy > 1.0f
		? GraphicsBackend::TextureFilter::Anisotropic
		: GraphicsBackend::TextureFilter::Linear;
}

GraphicsBackend::TextureWrap toBackendWrap(::love::graphics::Texture::WrapMode mode)
{
	switch (mode)
	{
		case ::love::graphics::Texture::WRAP_REPEAT:
			return GraphicsBackend::TextureWrap::Repeat;
		case ::love::graphics::Texture::WRAP_MIRRORED_REPEAT:
			return GraphicsBackend::TextureWrap::MirroredRepeat;
		case ::love::graphics::Texture::WRAP_CLAMP_ZERO:
			return GraphicsBackend::TextureWrap::ClampZero;
		case ::love::graphics::Texture::WRAP_CLAMP:
		case ::love::graphics::Texture::WRAP_MAX_ENUM:
			return GraphicsBackend::TextureWrap::Clamp;
	}
	return GraphicsBackend::TextureWrap::Clamp;
}

void ImageUserdata::setFilter(const ::love::graphics::Texture::Filter &value)
{
	if (!std::isfinite(value.anisotropy) || value.anisotropy < 0.0f)
		throw ::love::Exception("Anisotropy must be a finite non-negative number.");
	auto normalized = value;
	normalized.anisotropy = std::max(1.0f, value.anisotropy);
	::love::graphics::Texture::setFilter(normalized);
	anisotropy = normalized.anisotropy;
	filter = toBackendFilter(normalized.min, anisotropy);
	magFilter = toBackendFilter(normalized.mag, 1.0f);
	if (normalized.mipmap == ::love::graphics::Texture::FILTER_NONE)
		mipmapFilter.reset();
	else
		mipmapFilter = toBackendFilter(normalized.mipmap, 1.0f);
}

bool ImageUserdata::setWrap(const ::love::graphics::Texture::Wrap &value)
{
	::love::graphics::Texture::wrap = value;
	wrapU = toBackendWrap(value.s);
	wrapV = toBackendWrap(value.t);
	wrapW = toBackendWrap(value.r);
	return true;
}

bool ImageUserdata::setMipmapSharpness(float value)
{
	if (!std::isfinite(value))
		throw ::love::Exception("Mipmap sharpness must be finite.");
	::love::graphics::Texture::mipmapSharpness = value;
	mipmapSharpness = value;
	return true;
}

void ImageUserdata::setDepthSampleMode(
	::love::Optional<::love::graphics::CompareMode> mode)
{
	if (mode.hasValue && (!readable || !::love::isPixelFormatDepthStencil(
		::love::graphics::Texture::format)))
		throw ::love::Exception("Only readable depth textures can have a depth sample compare mode.");
	depthCompareMode = mode;
}

void ImageUserdata::replacePixels(::love::image::ImageDataBase *source,
	int slice, int mipmap, int x, int y, bool reloadMipmaps)
{
	auto *imageData = dynamic_cast<ImageDataUserdata *>(source);
	if (!runtime || handle == 0 || !runtime->getGraphicsBackend())
		throw ::love::Exception("closed Image");
	if (!imageData || imageData->getRuntime() != runtime)
		throw ::love::Exception("ImageData belongs to another LoveRuntime");
	if (compressed)
		throw ::love::Exception("replacePixels is unavailable for compressed Images");
	if (!isValidSlice(slice))
		throw ::love::Exception("Invalid image slice index %d.", slice + 1);
	if (mipmap < 0 || mipmap >= getMipmapCount())
		throw ::love::Exception("Invalid image mipmap index %d.", mipmap + 1);
	const int targetWidth = getPixelWidth(mipmap);
	const int targetHeight = getPixelHeight(mipmap);
	if (x < 0 || y < 0 || imageData->getWidth() <= 0 || imageData->getHeight() <= 0
		|| x > targetWidth - imageData->getWidth()
		|| y > targetHeight - imageData->getHeight())
		throw ::love::Exception("ImageData replacement region is outside the target mipmap");
	std::vector<std::uint8_t> rgba8;
	imageDataToRGBA8(*imageData, rgba8);
	std::string error;
	if (!runtime->getGraphicsBackend()->replaceImagePixels(handle, slice, mipmap,
		x, y, imageData->getWidth(), imageData->getHeight(), rgba8, error))
		throw ::love::Exception("Love Image replacePixels failed: %s",
			error.empty() ? "Dora graphics backend rejected the pixel update" : error.c_str());
	(void) reloadMipmaps;
}

void ImageUserdata::replacePixels(const void *bytes, size_t size, int slice,
	int mipmap, const ::love::Rect &rect, bool reloadMipmaps)
{
	if (bytes == nullptr || rect.w <= 0 || rect.h <= 0)
		throw ::love::Exception("Image pixel data is empty.");
	const auto pixelSize = ::love::getPixelFormatSize(::love::graphics::Texture::format);
	if (pixelSize == 0 || size < static_cast<size_t>(rect.w) * rect.h * pixelSize)
		throw ::love::Exception("Image pixel data is truncated.");
	DoraImageData source(runtime, rect.w, rect.h,
		::love::graphics::Texture::format, bytes);
	replacePixels(&source, slice, mipmap, rect.x, rect.y, reloadMipmaps);
}

void ImageUserdata::uploadByteData(::love::PixelFormat pixelFormat,
	const void *bytes, size_t size, int level, int slice, const ::love::Rect &rect)
{
	if (pixelFormat != ::love::graphics::Texture::format)
		throw ::love::Exception("Pixel formats must match.");
	replacePixels(bytes, size, slice, level, rect, false);
}

void ImageUserdata::syncUpstreamMetadata()
{
	if (!runtime || handle == 0 || !runtime->getGraphicsBackend())
		return;
	texType = toLoveTextureType(textureType);
	pixelWidth = runtime->getGraphicsBackend()->getImageWidth(handle);
	pixelHeight = runtime->getGraphicsBackend()->getImageHeight(handle);
	width = static_cast<int>(pixelWidth / dpiScale + 0.5f);
	height = static_cast<int>(pixelHeight / dpiScale + 0.5f);
	::love::graphics::Texture::dpiScale = dpiScale;
	depth = textureType == GraphicsBackend::TextureType::Volume ? slices : 1;
	layers = textureType == GraphicsBackend::TextureType::Array ? slices : 1;
	::love::PixelFormat upstreamFormat = ::love::PIXELFORMAT_RGBA8;
	if (::love::getConstant(format.c_str(), upstreamFormat))
		::love::graphics::Texture::format = upstreamFormat;
	else
		::love::graphics::Texture::format = ::love::PIXELFORMAT_RGBA8;
	::love::graphics::Texture::readable = readable;
	::love::graphics::Texture::mipmapCount = mipmapCount;
	settings.mipmaps = mipmapCount > 1;
	settings.linear = linear;
	settings.dpiScale = dpiScale;
	mipmapsType = mipmapCount > 1
		? (compressed ? MIPMAPS_DATA : MIPMAPS_GENERATED)
		: MIPMAPS_NONE;
	// love.graphics.isGammaCorrect() is fixed to false in this embedded
	// runtime, so no Image is tagged as sRGB by the upstream object layer.
	sRGB = false;
	::love::graphics::Texture::filter.min = filter == GraphicsBackend::TextureFilter::Nearest
		? FILTER_NEAREST : FILTER_LINEAR;
	::love::graphics::Texture::filter.mag = magFilter == GraphicsBackend::TextureFilter::Nearest
		? FILTER_NEAREST : FILTER_LINEAR;
	::love::graphics::Texture::filter.mipmap = !mipmapFilter
		? FILTER_NONE : (*mipmapFilter == GraphicsBackend::TextureFilter::Nearest
			? FILTER_NEAREST : FILTER_LINEAR);
	::love::graphics::Texture::filter.anisotropy = anisotropy;
	::love::graphics::Texture::wrap.s = wrapU == GraphicsBackend::TextureWrap::Repeat
		? WRAP_REPEAT : wrapU == GraphicsBackend::TextureWrap::MirroredRepeat
			? WRAP_MIRRORED_REPEAT : wrapU == GraphicsBackend::TextureWrap::ClampZero
				? WRAP_CLAMP_ZERO : WRAP_CLAMP;
	::love::graphics::Texture::wrap.t = wrapV == GraphicsBackend::TextureWrap::Repeat
		? WRAP_REPEAT : wrapV == GraphicsBackend::TextureWrap::MirroredRepeat
			? WRAP_MIRRORED_REPEAT : wrapV == GraphicsBackend::TextureWrap::ClampZero
				? WRAP_CLAMP_ZERO : WRAP_CLAMP;
	::love::graphics::Texture::wrap.r = wrapW == GraphicsBackend::TextureWrap::Repeat
		? WRAP_REPEAT : wrapW == GraphicsBackend::TextureWrap::MirroredRepeat
			? WRAP_MIRRORED_REPEAT : wrapW == GraphicsBackend::TextureWrap::ClampZero
				? WRAP_CLAMP_ZERO : WRAP_CLAMP;
	::love::graphics::Texture::mipmapSharpness = mipmapSharpness;
	initQuad();
}

void CanvasUserdata::setFilter(const ::love::graphics::Texture::Filter &value)
{
	if (!std::isfinite(value.anisotropy) || value.anisotropy < 0.0f)
		throw ::love::Exception("Anisotropy must be a finite non-negative number.");
	auto normalized = value;
	normalized.anisotropy = std::max(1.0f, value.anisotropy);
	::love::graphics::Texture::setFilter(normalized);
	anisotropy = normalized.anisotropy;
	filter = toBackendFilter(normalized.min, anisotropy);
	if (normalized.mipmap == ::love::graphics::Texture::FILTER_NONE)
		mipmapFilter.reset();
	else
		mipmapFilter = toBackendFilter(normalized.mipmap, 1.0f);
}

bool CanvasUserdata::setWrap(const ::love::graphics::Texture::Wrap &value)
{
	::love::graphics::Texture::wrap = value;
	wrapU = toBackendWrap(value.s);
	wrapV = toBackendWrap(value.t);
	wrapW = toBackendWrap(value.r);
	return true;
}

bool CanvasUserdata::setMipmapSharpness(float value)
{
	if (!std::isfinite(value))
		throw ::love::Exception("Mipmap sharpness must be finite.");
	::love::graphics::Texture::mipmapSharpness = value;
	mipmapSharpness = value;
	return true;
}

void CanvasUserdata::setDepthSampleMode(
	::love::Optional<::love::graphics::CompareMode> mode)
{
	::love::graphics::Texture::setDepthSampleMode(mode);
	depthCompareMode = mode;
	if (!mode.hasValue)
		depthSampleMode.reset();
	else
	{
		const char *name = nullptr;
		if (!::love::graphics::getConstant(mode.value, name))
			throw ::love::Exception("Invalid depth comparison mode.");
		depthSampleMode = name;
	}
}

void CanvasUserdata::generateMipmaps()
{
	if (!runtime || !runtime->getGraphicsBackend() || handle == 0)
		throw ::love::Exception("closed Canvas");
	if (mipmapMode == "none" || mipmapCount <= 1)
		throw ::love::Exception(
			"generateMipmaps can only be called on a Canvas created with mipmaps enabled");
	if (isDepthStencilCanvasFormat(format))
		throw ::love::Exception(
			"generateMipmaps cannot be called on a depth/stencil Canvas");
	std::string error;
	if (!runtime->getGraphicsBackend()->generateCanvasMipmaps(handle, error))
		throw ::love::Exception("Love Canvas mipmap generation failed: %s",
			error.empty() ? "Dora graphics backend rejected mipmap generation" : error.c_str());
}

void CanvasUserdata::syncUpstreamMetadata()
{
	if (!runtime || handle == 0 || !runtime->getGraphicsBackend())
		return;
	texType = toLoveTextureType(textureType);
	pixelWidth = runtime->getGraphicsBackend()->getCanvasWidth(handle);
	pixelHeight = runtime->getGraphicsBackend()->getCanvasHeight(handle);
	width = static_cast<int>(pixelWidth / dpiScale + 0.5f);
	height = static_cast<int>(pixelHeight / dpiScale + 0.5f);
	::love::graphics::Texture::dpiScale = dpiScale;
	depth = textureType == GraphicsBackend::TextureType::Volume ? slices : 1;
	layers = textureType == GraphicsBackend::TextureType::Array ? slices : 1;
	::love::PixelFormat upstreamFormat = ::love::PIXELFORMAT_RGBA8;
	if (::love::getConstant(format, upstreamFormat))
		::love::graphics::Texture::format = upstreamFormat;
	else
		::love::graphics::Texture::format = ::love::PIXELFORMAT_RGBA8;
	::love::graphics::Texture::readable = readable;
	::love::graphics::Texture::mipmapCount = mipmapCount;
	::love::graphics::Texture::filter.min = filter == GraphicsBackend::TextureFilter::Nearest
		? FILTER_NEAREST : FILTER_LINEAR;
	::love::graphics::Texture::filter.mag = ::love::graphics::Texture::filter.min;
	::love::graphics::Texture::filter.mipmap = !mipmapFilter
		? FILTER_NONE : (*mipmapFilter == GraphicsBackend::TextureFilter::Nearest
			? FILTER_NEAREST : FILTER_LINEAR);
	::love::graphics::Texture::filter.anisotropy = anisotropy;
	::love::graphics::Texture::wrap.s = wrapU == GraphicsBackend::TextureWrap::Repeat
		? WRAP_REPEAT : wrapU == GraphicsBackend::TextureWrap::MirroredRepeat
			? WRAP_MIRRORED_REPEAT : wrapU == GraphicsBackend::TextureWrap::ClampZero
				? WRAP_CLAMP_ZERO : WRAP_CLAMP;
	::love::graphics::Texture::wrap.t = wrapV == GraphicsBackend::TextureWrap::Repeat
		? WRAP_REPEAT : wrapV == GraphicsBackend::TextureWrap::MirroredRepeat
			? WRAP_MIRRORED_REPEAT : wrapV == GraphicsBackend::TextureWrap::ClampZero
				? WRAP_CLAMP_ZERO : WRAP_CLAMP;
	::love::graphics::Texture::wrap.r = wrapW == GraphicsBackend::TextureWrap::Repeat
		? WRAP_REPEAT : wrapW == GraphicsBackend::TextureWrap::MirroredRepeat
			? WRAP_MIRRORED_REPEAT : wrapW == GraphicsBackend::TextureWrap::ClampZero
				? WRAP_CLAMP_ZERO : WRAP_CLAMP;
	::love::graphics::Texture::mipmapSharpness = mipmapSharpness;
	initQuad();
}

void pushImageData(lua_State *state, LoveRuntime *runtime, int width, int height,
	const char *format, std::vector<std::uint8_t> pixels)
{
	::love::PixelFormat pixelFormat = ::love::PIXELFORMAT_UNKNOWN;
	if (!::love::getConstant(format, pixelFormat))
		throw ::love::Exception("Unsupported ImageData pixel format: %s", format);
	auto *imageData = new ImageDataUserdata(runtime, width, height, pixelFormat, pixels.data());
	::love::luax_pushtype(state, ::love::image::ImageData::type, imageData);
	imageData->release();
}

void pushThreadImageData(lua_State *state, const ThreadValue &value)
{
	lua_getfield(state, LUA_REGISTRYINDEX, LoveRuntimeRegistry);
	auto *runtime = static_cast<LoveRuntime *>(lua_touserdata(state, -1));
	lua_pop(state, 1);
	const auto *format = imagePixelFormatInfo(value.format);
	pushImageData(state, runtime, value.width, value.height,
		format ? format->name : "rgba8", value.data);
}

::love::font::GlyphData *makeGlyphData(GlyphDataBuilder glyphData)
{
	const ::love::font::GlyphMetrics metrics = {glyphData.height, glyphData.width,
		glyphData.advance, glyphData.bearingX, glyphData.bearingY};
	const auto format = glyphData.pixelSize == 2
		? ::love::PIXELFORMAT_LA8 : ::love::PIXELFORMAT_RGBA8;
	auto *data = new ::love::font::GlyphData(glyphData.glyph, metrics, format);
	if (!glyphData.pixels.empty())
		std::memcpy(data->getData(), glyphData.pixels.data(), glyphData.pixels.size());
	return data;
}

::love::font::GlyphData *makeRasterizerGlyphData(
	const RasterizerUserdata *rasterizer, std::uint32_t codepoint)
{
	if (rasterizer->kind == RasterizerUserdata::Kind::BMFont)
	{
		GlyphDataBuilder glyphData;
		glyphData.glyph = codepoint;
		const auto found = rasterizer->bmGlyphs.find(codepoint);
		if (found != rasterizer->bmGlyphs.end())
		{
			const auto &glyph = found->second;
			glyphData.width = glyph.width;
			glyphData.height = glyph.height;
			glyphData.advance = glyph.advance;
			glyphData.bearingX = glyph.bearingX;
			glyphData.bearingY = glyph.bearingY;
			if (glyph.page < 0
				|| static_cast<std::size_t>(glyph.page) >= rasterizer->sourceObjects.size())
				throw ::love::Exception("Rasterizer page reference is missing");
			auto *image = static_cast<ImageDataUserdata *>(
				rasterizer->sourceObjects[static_cast<std::size_t>(glyph.page)].get());
			std::vector<std::uint8_t> rgba8;
			imageDataToRGBA8(*image, rgba8);
			glyphData.pixels.resize(static_cast<std::size_t>(glyph.width)
				* static_cast<std::size_t>(glyph.height) * 4);
			for (int row = 0; row < glyph.height; ++row)
			{
				const auto source = rgba8.begin() + static_cast<std::ptrdiff_t>(
					(static_cast<std::size_t>(glyph.y + row) * image->getWidth() + glyph.x) * 4);
				const auto destination = glyphData.pixels.begin() + static_cast<std::ptrdiff_t>(
					static_cast<std::size_t>(row) * glyph.width * 4);
				std::copy_n(source, static_cast<std::size_t>(glyph.width) * 4, destination);
			}
		}
		return makeGlyphData(std::move(glyphData));
	}
	if (rasterizer->kind == RasterizerUserdata::Kind::TrueType)
	{
		GlyphDataBuilder glyphData;
		glyphData.glyph = codepoint;
		glyphData.pixelSize = 2;
		glyphData.format = "la8";
		int unscaledAdvance = 0;
		int leftBearing = 0;
		stbtt_GetCodepointHMetrics(&rasterizer->fontInfo, static_cast<int>(codepoint),
			&unscaledAdvance, &leftBearing);
		int x0 = 0, y0 = 0, x1 = 0, y1 = 0;
		stbtt_GetCodepointBitmapBox(&rasterizer->fontInfo, static_cast<int>(codepoint),
			rasterizer->fontScale, rasterizer->fontScale, &x0, &y0, &x1, &y1);
		glyphData.width = std::max(0, x1 - x0);
		glyphData.height = std::max(0, y1 - y0);
		glyphData.advance = static_cast<int>(std::floor(unscaledAdvance * rasterizer->fontScale + 0.5f));
		glyphData.bearingX = x0;
		glyphData.bearingY = -y0;
		if (glyphData.width > 0 && glyphData.height > 0)
		{
			std::vector<std::uint8_t> coverage(static_cast<std::size_t>(glyphData.width)
				* static_cast<std::size_t>(glyphData.height));
			stbtt_MakeCodepointBitmap(&rasterizer->fontInfo, coverage.data(), glyphData.width,
				glyphData.height, glyphData.width, rasterizer->fontScale, rasterizer->fontScale,
				static_cast<int>(codepoint));
			glyphData.pixels.resize(coverage.size() * 2);
			for (std::size_t index = 0; index < coverage.size(); ++index)
			{
				const std::uint8_t alpha = rasterizer->monochrome
					? (coverage[index] >= 128 ? 255 : 0) : coverage[index];
				glyphData.pixels[index * 2] = 255;
				glyphData.pixels[index * 2 + 1] = alpha;
			}
		}
		return makeGlyphData(std::move(glyphData));
	}
	if (rasterizer->sourceObjects.empty())
		throw ::love::Exception("Rasterizer ImageData reference is missing");
	auto *image = static_cast<ImageDataUserdata *>(rasterizer->sourceObjects.front().get());
	std::vector<std::uint8_t> rgba8;
	imageDataToRGBA8(*image, rgba8);

	GlyphDataBuilder glyphData;
	glyphData.glyph = codepoint;
	glyphData.height = rasterizer->height;
	const auto found = std::find_if(rasterizer->imageGlyphs.begin(), rasterizer->imageGlyphs.end(),
		[codepoint](const ImageRasterizerGlyph &glyph) { return glyph.codepoint == codepoint; });
	if (found != rasterizer->imageGlyphs.end())
	{
		glyphData.width = found->width;
		glyphData.advance = found->width + rasterizer->extraSpacing;
		const std::size_t byteCount = static_cast<std::size_t>(glyphData.width)
			* static_cast<std::size_t>(glyphData.height) * 4;
		glyphData.pixels.resize(byteCount);
		for (int row = 0; row < glyphData.height; ++row)
		{
			for (int column = 0; column < glyphData.width; ++column)
			{
				const std::size_t sourceOffset = (static_cast<std::size_t>(row)
					* static_cast<std::size_t>(image->getWidth())
					+ static_cast<std::size_t>(found->x + column)) * 4;
				const std::size_t destinationOffset = (static_cast<std::size_t>(row)
					* static_cast<std::size_t>(glyphData.width)
					+ static_cast<std::size_t>(column)) * 4;
				if (std::equal(rasterizer->spacer.begin(), rasterizer->spacer.end(),
					rgba8.begin() + static_cast<std::ptrdiff_t>(sourceOffset)))
					std::fill_n(glyphData.pixels.begin() + static_cast<std::ptrdiff_t>(destinationOffset), 4, 0);
				else
					std::copy_n(rgba8.begin() + static_cast<std::ptrdiff_t>(sourceOffset), 4,
						glyphData.pixels.begin() + static_cast<std::ptrdiff_t>(destinationOffset));
			}
		}
	}
	return makeGlyphData(std::move(glyphData));
}

::love::font::GlyphData *RasterizerUserdata::getGlyphData(std::uint32_t glyph) const
{
	return makeRasterizerGlyphData(this, glyph);
}

int RasterizerUserdata::getGlyphCount() const
{
	return kind == Kind::TrueType ? fontInfo.numGlyphs
		: kind == Kind::BMFont ? static_cast<int>(bmGlyphs.size())
		: static_cast<int>(glyphs.size());
}

bool RasterizerUserdata::hasGlyph(std::uint32_t glyph) const
{
	if (kind == Kind::TrueType)
		return stbtt_FindGlyphIndex(&fontInfo, static_cast<int>(glyph)) != 0;
	if (kind == Kind::BMFont)
		return bmGlyphs.contains(glyph);
	return std::any_of(imageGlyphs.begin(), imageGlyphs.end(),
		[glyph](const ImageRasterizerGlyph &entry) { return entry.codepoint == glyph; });
}

void pushSoundData(lua_State *state, int sampleRate, int bitDepth, int channels,
	int sampleCount, std::vector<std::uint8_t> samples)
{
	auto *data = new ::love::sound::SoundData(samples.data(), sampleCount,
		sampleRate, bitDepth, channels);
	::love::luax_pushtype(state, data);
	data->release();
}

bool isAffine2DTransform(const TransformMatrix &transform) noexcept
{
	const float *elements = transform.elements;
	constexpr float epsilon = 0.00001f;
	return std::abs(elements[2]) < epsilon && std::abs(elements[3]) < epsilon
		&& std::abs(elements[6]) < epsilon && std::abs(elements[7]) < epsilon
		&& std::abs(elements[8]) < epsilon && std::abs(elements[9]) < epsilon
		&& std::abs(elements[10] - 1.0f) < epsilon && std::abs(elements[11]) < epsilon
		&& std::abs(elements[14]) < epsilon && std::abs(elements[15] - 1.0f) < epsilon;
}

void setTransformIdentity(TransformMatrix &transform)
{
	std::fill(std::begin(transform.elements), std::end(transform.elements), 0.0f);
	transform.elements[0] = transform.elements[5] = transform.elements[10]
		= transform.elements[15] = 1.0f;
}

void multiplyTransforms(const TransformMatrix &left, const TransformMatrix &right,
	TransformMatrix &result)
{
	float values[16]{};
	for (int column = 0; column < 4; ++column)
		for (int row = 0; row < 4; ++row)
			for (int component = 0; component < 4; ++component)
				values[column * 4 + row] += left.elements[component * 4 + row]
					* right.elements[column * 4 + component];
	std::copy(std::begin(values), std::end(values), std::begin(result.elements));
}

void setTransform(TransformMatrix &transform, float x, float y, float angle,
	float sx, float sy, float ox, float oy, float kx, float ky)
{
	std::fill(std::begin(transform.elements), std::end(transform.elements), 0.0f);
	const float cosine = std::cos(angle);
	const float sine = std::sin(angle);
	transform.elements[10] = transform.elements[15] = 1.0f;
	transform.elements[0] = cosine * sx - ky * sine * sy;
	transform.elements[1] = sine * sx + ky * cosine * sy;
	transform.elements[4] = kx * cosine * sx - sine * sy;
	transform.elements[5] = kx * sine * sx + cosine * sy;
	transform.elements[12] = x - ox * transform.elements[0] - oy * transform.elements[4];
	transform.elements[13] = y - ox * transform.elements[1] - oy * transform.elements[5];
}

void pushAudioSource(lua_State *state, LoveRuntime *runtime, AudioBackend::SourceHandle handle,
	bool stream, bool queue = false)
{
	auto *source = new AudioSourceUserdata(runtime, handle, stream, queue);
	pushNewDoraHandleObject(state, AudioSourceUserdata::type, source);
	source->onProxyCreated(state, -1);
}

bool pushAudioSourceByHandle(lua_State *state, AudioBackend::SourceHandle handle)
{
	lua_getfield(state, LUA_REGISTRYINDEX, AudioSourceRegistry);
	if (!lua_istable(state, -1))
	{
		lua_pop(state, 1);
		return false;
	}
	lua_pushinteger(state, static_cast<lua_Integer>(handle));
	lua_rawget(state, -2);
	lua_remove(state, -2);
	if (lua_isnil(state, -1))
	{
		lua_pop(state, 1);
		return false;
	}
	if (luaL_testudata(state, -1, AudioSourceUserdata::type.getName()) == nullptr
		|| !::love::luax_istype(state, -1, AudioSourceUserdata::type))
	{
		lua_pop(state, 1);
		return false;
	}
	return true;
}

RecordingDeviceUserdata *checkRecordingDevice(lua_State *state, int index)
{
	return ::love::luax_checktype<RecordingDeviceUserdata>(state, index);
}

void pushRecordingDevice(lua_State *state, LoveRuntime *runtime, std::string_view name)
{
	// Keep device identity stable across repeated enumeration, as Love's audio
	// module does for its retained RecordingDevice objects.
	lua_getfield(state, LUA_REGISTRYINDEX, RecordingDeviceRegistry);
	if (!lua_istable(state, -1))
	{
		lua_pop(state, 1);
		lua_newtable(state);
		lua_newtable(state);
		lua_pushliteral(state, "v");
		lua_setfield(state, -2, "__mode");
		lua_setmetatable(state, -2);
		lua_pushvalue(state, -1);
		lua_setfield(state, LUA_REGISTRYINDEX, RecordingDeviceRegistry);
	}
	lua_pushlstring(state, name.data(), name.size());
	lua_rawget(state, -2);
	if (!lua_isnil(state, -1)
		&& luaL_testudata(state, -1, RecordingDeviceUserdata::type.getName()) != nullptr
		&& ::love::luax_istype(state, -1, RecordingDeviceUserdata::type))
	{
		lua_remove(state, -2);
		return;
	}
	lua_pop(state, 1);

	auto *device = new RecordingDeviceUserdata(runtime, std::string(name));
	pushNewDoraHandleObject(state, RecordingDeviceUserdata::type, device);
	lua_pushlstring(state, name.data(), name.size());
	lua_pushvalue(state, -2);
	lua_rawset(state, -4);
	lua_remove(state, -2);
}

bool normalizeLoveVirtualPath(std::string_view filename, std::string &normalized,
	bool allowEmpty = false)
{
	if (filename.find('\\') != std::string_view::npos)
		return false;
	// PhysFS-backed LÖVE paths are rooted at the game's virtual filesystem.
	// Existing games commonly spell that root with a leading slash and keep a
	// trailing slash for directories. Normalize both forms before confinement.
	while (filename.starts_with('/'))
		filename.remove_prefix(1);
	while (filename.starts_with("./"))
		filename.remove_prefix(2);
	while (filename.ends_with('/'))
		filename.remove_suffix(1);
	if (filename.empty())
	{
		normalized.clear();
		return allowEmpty;
	}
	normalized.clear();
	std::size_t start = 0;
	while (start <= filename.size())
	{
		const std::size_t slash = filename.find('/', start);
		const std::size_t end = slash == std::string_view::npos ? filename.size() : slash;
		const std::string_view component = filename.substr(start, end - start);
		if (component.empty() || component == "." || component == "..")
			return false;
		if (!normalized.empty()) normalized.push_back('/');
		normalized.append(component);
		if (slash == std::string_view::npos) break;
		start = slash + 1;
	}
	return true;
}

bool isSafeVirtualPath(std::string_view filename, bool allowEmpty = false)
{
	std::string normalized;
	return normalizeLoveVirtualPath(filename, normalized, allowEmpty);
}

bool normalizeLoveModulePath(std::string_view moduleName, std::string &modulePath)
{
	while (moduleName.starts_with("./"))
		moduleName.remove_prefix(2);
	// Love's filesystem searcher treats a leading slash as game-root-relative,
	// which is used by several LuaJIT-era libraries.
	while (moduleName.starts_with('/'))
		moduleName.remove_prefix(1);
	if (moduleName.empty())
		return false;
	modulePath.clear();
	modulePath.reserve(moduleName.size());
	bool componentEmpty = true;
	for (const char character : moduleName)
	{
		if (character == '.' || character == '/')
		{
			// Lua accepts both package-style names (foo.bar) and path-style names
			// (foo/bar). Empty components also cover '.', '..', repeated
			// separators, and leading/trailing separators after normalization.
			if (componentEmpty)
				return false;
			modulePath.push_back('/');
			componentEmpty = true;
			continue;
		}
		if (character == '\\' || character == ':' || character == '\0')
			return false;
		modulePath.push_back(character);
		componentEmpty = false;
	}
	return !componentEmpty && isSafeVirtualPath(modulePath);
}

bool isInsideRoot(const std::filesystem::path &root, const std::filesystem::path &candidate, bool allowRoot = false)
{
	const std::filesystem::path relative = candidate.lexically_relative(root);
	if (relative.empty() || relative == ".")
		return allowRoot;
	return *relative.begin() != "..";
}

bool resolveEntryWithinRoot(const std::string &rootText, std::string_view filename,
	std::filesystem::path &resolved, bool allowRoot, std::string &error)
{
	if (rootText.empty())
		return false;
	std::string normalized;
	if (!normalizeLoveVirtualPath(filename, normalized, allowRoot))
	{
		error = "Love filesystem path must be relative and cannot contain '.', '..', or backslashes: "
			+ std::string(filename);
		return false;
	}
	std::error_code pathError;
	const std::filesystem::path root = std::filesystem::weakly_canonical(rootText, pathError);
	if (pathError)
	{
		error = "failed to resolve Love filesystem root: " + pathError.message();
		return false;
	}
	const std::filesystem::path unresolved = normalized.empty()
		? root : root / std::filesystem::path(normalized);
	resolved = std::filesystem::weakly_canonical(unresolved, pathError);
	if (pathError || !isInsideRoot(root, resolved, allowRoot))
	{
		error = "Love filesystem path escapes its instance root: " + std::string(filename);
		return false;
	}
	return true;
}

bool resolveMountedEntry(const std::string &root, const std::string &mountpoint,
	std::string_view filename, std::filesystem::path &resolved, bool allowRoot, std::string &error)
{
	std::string_view relative;
	if (mountpoint.empty())
		relative = filename;
	else if (filename == mountpoint)
		relative = {};
	else if (filename.size() > mountpoint.size()
		&& filename.substr(0, mountpoint.size()) == mountpoint
		&& filename[mountpoint.size()] == '/')
		relative = filename.substr(mountpoint.size() + 1);
	else
		return false;
	return resolveEntryWithinRoot(root, relative, resolved, allowRoot, error);
}

int pushFilesystemFailure(lua_State *state, const std::string &message)
{
	lua_pushnil(state);
	lua_pushlstring(state, message.data(), message.size());
	return 2;
}

bool resolveWritableEntry(LoveRuntime *runtime, std::string_view filename,
	std::filesystem::path &resolved, bool allowRoot, std::string &error)
{
	// A leading slash is accepted as a read-only virtual-root spelling for
	// compatibility, but writes remain explicitly relative to the identity
	// directory so no game can confuse them with host absolute paths.
	if (filename.starts_with('/'))
	{
		error = "Love filesystem write path must be relative: " + std::string(filename);
		return false;
	}
	if (runtime == nullptr || runtime->getSaveRoot().empty())
	{
		error = "Love filesystem save directory is not configured";
		return false;
	}
	auto *backend = runtime->getFilesystemBackend();
	if (backend == nullptr)
	{
		error = "Love filesystem is not attached to a Dora Content backend";
		return false;
	}
	if (!backend->createFolder(runtime->getSaveRoot(), error))
		return false;
	return resolveEntryWithinRoot(runtime->getSaveRoot(), filename, resolved, allowRoot, error);
}

bool flushFile(FileUserdata *file, std::string &error)
{
	if (!file || !file->runtime || (file->mode != FileMode::MODE_WRITE && file->mode != FileMode::MODE_APPEND))
	{
		error = "File is not open for writing";
		return false;
	}
	std::filesystem::path target;
	if (!resolveWritableEntry(file->runtime, file->filename, target, false, error))
		return false;
	auto *backend = file->runtime->getFilesystemBackend();
	if (!backend->isFolder(target.parent_path().string()))
	{
		error = "Love filesystem parent directory does not exist: " + file->filename;
		return false;
	}
	if (!backend->save(target.string(), file->data, error))
	{
		if (error.empty()) error = "failed to write Love filesystem file: " + file->filename;
		return false;
	}
	error.clear();
	return true;
}

bool openFile(FileUserdata *file, FileMode mode, std::string &error)
{
	if (!file || !file->runtime || !file->runtime->getFilesystemBackend())
	{
		error = "Love filesystem is not attached to a Dora Content backend";
		return false;
	}
	if (mode == FileMode::MODE_CLOSED)
	{
		file->mode = FileMode::MODE_CLOSED;
		file->position = 0;
		return true;
	}
	std::string data;
	if (mode == FileMode::MODE_READ)
	{
		std::string resolved;
		if (!file->runtime->resolveReadPath(file->filename, resolved, error)
			|| !file->runtime->getFilesystemBackend()->load(resolved, data, error))
		{
			if (error.empty()) error = "failed to open Love filesystem file for reading: " + file->filename;
			return false;
		}
	}
	else
	{
		std::filesystem::path target;
		if (!resolveWritableEntry(file->runtime, file->filename, target, false, error))
			return false;
		auto *backend = file->runtime->getFilesystemBackend();
		if (!backend->isFolder(target.parent_path().string()))
		{
			error = "Love filesystem parent directory does not exist: " + file->filename;
			return false;
		}
		if (mode == FileMode::MODE_APPEND && backend->exist(target.string())
			&& !backend->load(target.string(), data, error))
			return false;
		if (!backend->save(target.string(), data, error))
		{
			if (error.empty()) error = "failed to create Love filesystem file: " + file->filename;
			return false;
		}
	}
	file->data = std::move(data);
	file->mode = mode;
	file->position = mode == FileMode::MODE_APPEND ? file->data.size() : 0;
	error.clear();
	return true;
}

bool FileUserdata::open(Mode value)
{
	std::string error;
	if (!openFile(this, value, error))
		throw ::love::Exception("%s", error.c_str());
	return true;
}

bool FileUserdata::close()
{
	mode = MODE_CLOSED;
	position = 0;
	return true;
}

bool FileUserdata::isOpen() const { return mode != MODE_CLOSED; }

::love::int64 FileUserdata::getSize()
{
	if (mode != MODE_CLOSED)
		return static_cast<::love::int64>(data.size());
	std::string resolved;
	std::string error;
	if (!runtime || !runtime->resolveReadPath(filename, resolved, error)
		|| !runtime->getFilesystemBackend())
		throw ::love::Exception("%s", error.empty() ? "Could not determine file size." : error.c_str());
	const auto size = runtime->getFilesystemBackend()->getFileSize(resolved);
	if (!size || *size > static_cast<std::uint64_t>(std::numeric_limits<::love::int64>::max()))
		return -1;
	return static_cast<::love::int64>(*size);
}

::love::int64 FileUserdata::read(void *destination, ::love::int64 requested)
{
	if (mode != MODE_READ || requested < 0)
		return -1;
	const std::size_t available = data.size() - std::min(position, data.size());
	const std::size_t count = std::min<std::size_t>(available, static_cast<std::size_t>(requested));
	if (count > 0)
		std::memcpy(destination, data.data() + position, count);
	position += count;
	return static_cast<::love::int64>(count);
}

bool FileUserdata::write(const void *source, ::love::int64 requested)
{
	if ((mode != MODE_WRITE && mode != MODE_APPEND) || requested < 0)
		return false;
	const auto size = static_cast<std::size_t>(requested);
	if (mode == MODE_APPEND)
		position = data.size();
	if (position > data.size())
		data.resize(position, '\0');
	const std::size_t overwritten = std::min(size, data.size() - position);
	data.replace(position, overwritten, static_cast<const char *>(source), size);
	position += size;
	return flush();
}

bool FileUserdata::flush()
{
	std::string error;
	if (!flushFile(this, error))
		throw ::love::Exception("%s", error.c_str());
	return true;
}

bool FileUserdata::isEOF() { return mode == MODE_READ && position >= data.size(); }

::love::int64 FileUserdata::tell()
{
	return mode == MODE_CLOSED ? -1 : static_cast<::love::int64>(position);
}

bool FileUserdata::seek(::love::uint64 value)
{
	if (mode == MODE_CLOSED || value > data.size())
		return false;
	position = static_cast<std::size_t>(value);
	return true;
}

bool FileUserdata::setBuffer(BufferMode value, ::love::int64 size)
{
	if (size < 0)
		return false;
	bufferMode = value;
	bufferSize = static_cast<std::size_t>(size);
	return true;
}

FileUserdata::BufferMode FileUserdata::getBuffer(::love::int64 &size) const
{
	size = static_cast<::love::int64>(bufferSize);
	return bufferMode;
}

FileUserdata::Mode FileUserdata::getMode() const { return mode; }
const std::string &FileUserdata::getFilename() const { return filename; }

} // namespace

::love::image::ImageData *LoveRuntime::readCanvasImageData(
	GraphicsBackend::CanvasHandle canvas, ::love::PixelFormat format,
	int slice, int mipmap, const ::love::Rect &rect)
{
	if (!_graphicsBackend || !_canvasHandles.contains(canvas))
		throw ::love::Exception("closed Canvas");
	if (std::find(_graphicsCanvases.begin(), _graphicsCanvases.end(), canvas)
		!= _graphicsCanvases.end() || canvas == _graphicsCanvasDepthStencil)
		throw ::love::Exception(
			"Canvas:newImageData cannot be called while that Canvas is currently active");
	if (_graphicsFrameActive && !_graphicsLoadCallbackActive)
		throw ::love::Exception(
			"embedded Dora Canvas:newImageData is currently available only outside love.draw");
	std::vector<std::uint8_t> pixels;
	std::string error;
	const bool resumeLoadFrame = _graphicsFrameActive && _graphicsLoadCallbackActive;
	if (resumeLoadFrame)
	{
		_graphicsBackend->endFrame();
		_graphicsFrameActive = false;
	}
	const bool read = _graphicsBackend->readCanvas(canvas, slice, mipmap,
		rect.x, rect.y, rect.w, rect.h, pixels, error);
	if (resumeLoadFrame)
	{
		_graphicsBackend->beginFrame();
		_graphicsFrameActive = true;
	}
	if (!read)
		throw ::love::Exception("Love Canvas readback failed: %s",
			error.empty() ? "Dora graphics backend rejected the readback" : error.c_str());
	if (!::love::image::ImageData::validPixelFormat(format))
		throw ::love::Exception("Canvas pixel format cannot be represented as ImageData");
	const auto pixelSize = ::love::getPixelFormatSize(format);
	if (pixelSize == 0 || pixels.size() != static_cast<std::size_t>(rect.w)
		* static_cast<std::size_t>(rect.h) * pixelSize)
		throw ::love::Exception("Love Canvas readback returned an invalid byte count");
	return new DoraImageData(this, rect.w, rect.h, format, pixels.data());
}

::love::sound::Decoder *DoraLoveSound::newDecoder(::love::filesystem::FileData *file,
	int requestedBufferSize)
{
	if (!_runtime || !_runtime->_soundBackend)
		throw ::love::Exception("love.sound is not attached to the Dora SoLoud decoder.");
	if (!file || file->getSize() == 0)
		throw ::love::Exception("Cannot decode empty sound data.");
	if (requestedBufferSize <= 0
		|| static_cast<std::size_t>(requestedBufferSize) > MaximumSoundDataBytes)
		throw ::love::Exception("Decoder buffer size must be between 1 byte and 256 MiB.");

	int decodedSampleRate = 0;
	int decodedChannels = 0;
	std::vector<float> decoded;
	std::string error;
	const std::string_view encoded(static_cast<const char *>(file->getData()), file->getSize());
	if (!_runtime->_soundBackend->decodeSound(encoded, decodedSampleRate, decodedChannels,
		decoded, error))
		throw ::love::Exception("Love Decoder '%s' decode failed: %s",
			file->getFilename().c_str(), error.empty()
				? "Dora SoLoud decoder rejected the data" : error.c_str());
	if (decodedSampleRate <= 0 || decodedSampleRate > 384000
		|| decodedChannels < 1 || decodedChannels > 8 || decoded.empty()
		|| decoded.size() % static_cast<std::size_t>(decodedChannels) != 0
		|| decoded.size() > MaximumSoundDataBytes / 2)
		throw ::love::Exception("Love Decoder '%s' decode failed: Dora SoLoud decoder returned invalid sample metadata",
			file->getFilename().c_str());

	std::vector<std::uint8_t> samples(decoded.size() * 2);
	for (std::size_t sample = 0; sample < decoded.size(); ++sample)
	{
		if (!std::isfinite(decoded[sample]))
			throw ::love::Exception("Love Decoder '%s' decode failed: Dora SoLoud decoder returned a non-finite sample",
				file->getFilename().c_str());
		const auto signedValue = static_cast<std::int16_t>(std::lround(
			std::clamp(static_cast<double>(decoded[sample]), -1.0, 1.0) * 32767.0));
		const auto bits = static_cast<std::uint16_t>(signedValue);
		samples[sample * 2] = static_cast<std::uint8_t>(bits & 0xff);
		samples[sample * 2 + 1] = static_cast<std::uint8_t>(bits >> 8);
	}
	const int frameBytes = decodedChannels * 2;
	return new DecoderUserdata(file, std::max(requestedBufferSize, frameBytes),
		decodedSampleRate, decodedChannels, std::move(samples));
}

::love::filesystem::FileData *DoraImageData::encode(
	::love::image::FormatHandler::EncodedFormat encodedFormat,
	const char *filename, bool writeFile) const
{
	const char *format = nullptr;
	if (!::love::image::ImageData::getConstant(encodedFormat, format))
		throw ::love::Exception("Unknown encoded image format.");
	auto *imageBackend = _runtime ? _runtime->getImageBackend() : nullptr;
	if (!imageBackend)
		throw ::love::Exception("love.image is not attached to a Dora image encoder.");

	const std::string outputName = filename ? filename : std::string("Image.") + format;
	std::filesystem::path target;
	std::string error;
	if (writeFile && !resolveWritableEntry(_runtime, outputName, target, false, error))
		throw ::love::Exception("Love ImageData '%s' save failed: %s",
			outputName.c_str(), error.c_str());

	std::vector<std::uint8_t> rgba8;
	imageDataToRGBA8(*this, rgba8);
	std::vector<std::uint8_t> encoded;
	if (!imageBackend->encodeImage(format, getWidth(), getHeight(),
		rgba8, encoded, error))
		throw ::love::Exception("Love ImageData encode failed: %s",
			error.empty() ? "Dora image encoder rejected the data" : error.c_str());
	if (encoded.empty())
		throw ::love::Exception("Love ImageData encode failed: Dora image encoder returned empty data.");

	if (writeFile)
	{
		auto *filesystemBackend = _runtime->getFilesystemBackend();
		if (!filesystemBackend || !filesystemBackend->save(target.string(),
			std::string_view(reinterpret_cast<const char *>(encoded.data()), encoded.size()), error))
			throw ::love::Exception("Love ImageData '%s' save failed: %s", outputName.c_str(),
				error.empty() ? "Dora Content rejected the write" : error.c_str());
	}

	auto *fileData = new ::love::filesystem::FileData(encoded.size(), outputName);
	std::memcpy(fileData->getData(), encoded.data(), encoded.size());
	return fileData;
}

bool DoraLoveFilesystem::setupWriteDirectory()
{
	if (!_runtime || !_runtime->_filesystemBackend || _runtime->_saveRoot.empty())
		return false;
	std::string error;
	return _runtime->_filesystemBackend->createFolder(_runtime->_saveRoot, error);
}

bool DoraLoveFilesystem::setIdentity(const char *identity, bool)
{
	std::string error;
	return _runtime && _runtime->setIdentity(identity ? identity : "", error);
}

const char *DoraLoveFilesystem::getIdentity() const
{
	return _runtime ? _runtime->_identity.c_str() : "";
}

bool DoraLoveFilesystem::setSource(const char *source)
{
	if (!_runtime || !source) return false;
	if (_runtime->_sourceRoot.empty())
	{
		std::string error;
		return _runtime->setSourceRoot(source, error);
	}
	return _runtime->_sourceRoot == source;
}

const char *DoraLoveFilesystem::getSource() const
{
	return _runtime ? _runtime->_sourceRoot.c_str() : "";
}

bool DoraLoveFilesystem::mount(const char *archive, const char *mountpoint, bool appendToPath)
{
	if (!_runtime || !_runtime->_filesystemBackend || !archive || !mountpoint) return false;
	std::string resolved, bytes, error;
	if (!_runtime->resolveReadPath(archive, resolved, error)
		|| !_runtime->_filesystemBackend->load(resolved, bytes, error))
		return false;
	if (!isSafeVirtualPath(mountpoint, true) || bytes.empty()) return false;
	for (const auto &entry : _runtime->_mountedArchives)
		if (!entry.dataIdentity && entry.archiveName == archive) return false;
	std::string root;
	if (!_runtime->_filesystemBackend->mountArchive(archive, bytes, root, error)) return false;
	LoveRuntime::MountedArchive mounted{archive, mountpoint, root, nullptr, LUA_NOREF, {}};
	if (appendToPath) _runtime->_mountedArchives.push_back(std::move(mounted));
	else _runtime->_mountedArchives.insert(_runtime->_mountedArchives.begin(), std::move(mounted));
	return true;
}

bool DoraLoveFilesystem::mount(::love::Data *data, const char *archiveName,
	const char *mountpoint, bool appendToPath)
{
	if (!_runtime || !_runtime->_filesystemBackend || !data || !archiveName || !mountpoint
		|| !isSafeVirtualPath(mountpoint, true) || data->getSize() == 0)
		return false;
	for (const auto &entry : _runtime->_mountedArchives)
		if (entry.dataIdentity == data) return false;
	const std::string_view bytes(static_cast<const char *>(data->getData()), data->getSize());
	std::string root, error;
	if (!_runtime->_filesystemBackend->mountArchive(archiveName, bytes, root, error)) return false;
	LoveRuntime::MountedArchive mounted{archiveName, mountpoint, root, data, LUA_NOREF, {}};
	mounted.dataObject.set(data);
	if (appendToPath) _runtime->_mountedArchives.push_back(std::move(mounted));
	else _runtime->_mountedArchives.insert(_runtime->_mountedArchives.begin(), std::move(mounted));
	return true;
}

bool DoraLoveFilesystem::unmount(const char *archive)
{
	if (!_runtime || !archive) return false;
	auto found = std::find_if(_runtime->_mountedArchives.begin(), _runtime->_mountedArchives.end(),
		[&](const auto &entry) { return !entry.dataIdentity && entry.archiveName == archive; });
	if (found == _runtime->_mountedArchives.end()) return false;
	if (_runtime->_filesystemBackend) _runtime->_filesystemBackend->unmountArchive(found->root);
	if (found->dataReference != LUA_NOREF && _runtime->_state)
		luaL_unref(_runtime->_state, LUA_REGISTRYINDEX, found->dataReference);
	_runtime->_mountedArchives.erase(found);
	return true;
}

bool DoraLoveFilesystem::unmount(::love::Data *data)
{
	if (!_runtime || !data) return false;
	auto found = std::find_if(_runtime->_mountedArchives.begin(), _runtime->_mountedArchives.end(),
		[&](const auto &entry) { return entry.dataIdentity == data; });
	if (found == _runtime->_mountedArchives.end()) return false;
	if (_runtime->_filesystemBackend) _runtime->_filesystemBackend->unmountArchive(found->root);
	if (found->dataReference != LUA_NOREF && _runtime->_state)
		luaL_unref(_runtime->_state, LUA_REGISTRYINDEX, found->dataReference);
	_runtime->_mountedArchives.erase(found);
	return true;
}

::love::filesystem::File *DoraLoveFilesystem::newFile(const char *filename) const
{
	if (!_runtime || !filename || !isSafeVirtualPath(filename))
		throw ::love::Exception("File path must be relative and confined to the Love instance.");
	auto *file = new FileUserdata;
	file->runtime = _runtime;
	file->filename = filename;
	return file;
}

const char *DoraLoveFilesystem::getWorkingDirectory()
{
	return getSource();
}

std::string DoraLoveFilesystem::getUserDirectory()
{
	return !_runtime || _runtime->_saveBaseRoot.empty() ? std::string()
		: std::filesystem::path(_runtime->_saveBaseRoot).parent_path().string();
}

std::string DoraLoveFilesystem::getAppdataDirectory()
{
	return _runtime ? _runtime->_saveBaseRoot : std::string();
}

const char *DoraLoveFilesystem::getSaveDirectory()
{
	return _runtime ? _runtime->_saveRoot.c_str() : "";
}

std::string DoraLoveFilesystem::getSourceBaseDirectory() const
{
	return !_runtime || _runtime->_sourceRoot.empty() ? std::string()
		: std::filesystem::path(_runtime->_sourceRoot).parent_path().string();
}

std::string DoraLoveFilesystem::getRealDirectory(const char *filename) const
{
	if (!_runtime || !_runtime->_filesystemBackend || !filename || !isSafeVirtualPath(filename))
		throw ::love::Exception("Love filesystem path must be relative and confined.");
	std::filesystem::path candidate;
	std::string error;
	if (resolveEntryWithinRoot(_runtime->_saveRoot, filename, candidate, true, error)
		&& _runtime->_filesystemBackend->exist(candidate.string())) return _runtime->_saveRoot;
	for (const auto &mount : _runtime->_mountedArchives)
	{
		error.clear();
		if (resolveMountedEntry(mount.root, mount.mountpoint, filename, candidate, true, error)
			&& _runtime->_filesystemBackend->exist(candidate.string())) return mount.root;
	}
	error.clear();
	if (resolveEntryWithinRoot(_runtime->_sourceRoot, filename, candidate, true, error)
		&& _runtime->_filesystemBackend->exist(candidate.string())) return _runtime->_sourceRoot;
	throw ::love::Exception("Love filesystem entry does not exist: %s", filename);
}

bool DoraLoveFilesystem::getInfo(const char *filepath, Info &info) const
{
	if (!_runtime || !_runtime->_filesystemBackend || !filepath || !isSafeVirtualPath(filepath, true))
		return false;
	auto probe = [&](const std::filesystem::path &candidate, bool virtualDirectory) {
		if (!virtualDirectory && !_runtime->_filesystemBackend->exist(candidate.string())) return false;
		info.type = virtualDirectory || _runtime->_filesystemBackend->isFolder(candidate.string())
			? FILETYPE_DIRECTORY : FILETYPE_FILE;
		info.modtime = -1;
		info.size = -1;
		if (info.type == FILETYPE_FILE)
			if (const auto size = _runtime->_filesystemBackend->getFileSize(candidate.string()))
				info.size = static_cast<::love::int64>(*size);
		return true;
	};
	std::filesystem::path candidate;
	std::string error;
	if (resolveEntryWithinRoot(_runtime->_saveRoot, filepath, candidate, true, error)
		&& probe(candidate, false)) return true;
	const std::string path(filepath);
	for (const auto &mount : _runtime->_mountedArchives)
	{
		const bool ancestor = !mount.mountpoint.empty() && path.size() < mount.mountpoint.size()
			&& mount.mountpoint.starts_with(path.empty() ? "" : path + "/");
		if (ancestor && probe({}, true)) return true;
		error.clear();
		if (resolveMountedEntry(mount.root, mount.mountpoint, filepath, candidate, true, error)
			&& probe(candidate, false)) return true;
	}
	error.clear();
	return resolveEntryWithinRoot(_runtime->_sourceRoot, filepath, candidate, true, error)
		&& probe(candidate, false);
}

bool DoraLoveFilesystem::createDirectory(const char *directory)
{
	std::filesystem::path target;
	std::string error;
	return directory && resolveWritableEntry(_runtime, directory, target, false, error)
		&& _runtime->_filesystemBackend->createFolder(target.string(), error);
}

bool DoraLoveFilesystem::remove(const char *file)
{
	std::filesystem::path target;
	std::string error;
	return file && resolveWritableEntry(_runtime, file, target, false, error)
		&& _runtime->_filesystemBackend->remove(target.string(), error);
}

::love::filesystem::FileData *DoraLoveFilesystem::read(const char *filename, ::love::int64 size) const
{
	if (!_runtime || !_runtime->_filesystemBackend || !filename || size < ::love::filesystem::File::ALL)
		throw ::love::Exception("Invalid Love filesystem read.");
	std::string resolved, bytes, error;
	if (!_runtime->resolveReadPath(filename, resolved, error)
		|| !_runtime->_filesystemBackend->load(resolved, bytes, error))
		throw ::love::Exception("%s", error.empty() ? "File could not be read." : error.c_str());
	if (size != ::love::filesystem::File::ALL)
		bytes.resize(std::min<std::size_t>(bytes.size(), static_cast<std::size_t>(size)));
	auto *result = new ::love::filesystem::FileData(bytes.size(), filename);
	if (!bytes.empty()) std::memcpy(result->getData(), bytes.data(), bytes.size());
	return result;
}

void DoraLoveFilesystem::write(const char *filename, const void *source, ::love::int64 size) const
{
	if (!filename || !source || size < 0) throw ::love::Exception("Invalid Love filesystem write.");
	std::filesystem::path target;
	std::string error;
	if (!resolveWritableEntry(_runtime, filename, target, false, error)
		|| !_runtime->_filesystemBackend->isFolder(target.parent_path().string())
		|| !_runtime->_filesystemBackend->save(target.string(),
			std::string_view(static_cast<const char *>(source), static_cast<std::size_t>(size)), error))
		throw ::love::Exception("%s", error.empty() ? "File could not be written." : error.c_str());
}

void DoraLoveFilesystem::append(const char *filename, const void *source, ::love::int64 size) const
{
	if (!filename || !source || size < 0) throw ::love::Exception("Invalid Love filesystem append.");
	std::filesystem::path target;
	std::string bytes, error;
	if (!resolveWritableEntry(_runtime, filename, target, false, error)
		|| !_runtime->_filesystemBackend->isFolder(target.parent_path().string()))
		throw ::love::Exception("%s", error.empty() ? "File could not be appended." : error.c_str());
	if (_runtime->_filesystemBackend->exist(target.string())
		&& !_runtime->_filesystemBackend->load(target.string(), bytes, error))
		throw ::love::Exception("%s", error.c_str());
	bytes.append(static_cast<const char *>(source), static_cast<std::size_t>(size));
	if (!_runtime->_filesystemBackend->save(target.string(), bytes, error))
		throw ::love::Exception("%s", error.empty() ? "File could not be appended." : error.c_str());
}

void DoraLoveFilesystem::getDirectoryItems(const char *directory, std::vector<std::string> &output)
{
	const std::string path = directory ? directory : "";
	if (!_runtime || !_runtime->_filesystemBackend || !isSafeVirtualPath(path, true)) return;
	std::set<std::string> items;
	auto collect = [&](const std::string &root, std::string_view relative) {
		std::filesystem::path candidate;
		std::string error;
		if (!resolveEntryWithinRoot(root, relative, candidate, true, error)
			|| !_runtime->_filesystemBackend->isFolder(candidate.string())) return;
		for (const auto &item : _runtime->_filesystemBackend->getDirectoryItems(candidate.string())) items.insert(item);
	};
	collect(_runtime->_saveRoot, path);
	for (const auto &mount : _runtime->_mountedArchives)
	{
		if (!mount.mountpoint.empty() && (path.empty()
			|| (mount.mountpoint.size() > path.size() && mount.mountpoint.starts_with(path + "/"))))
		{
			const std::size_t start = path.empty() ? 0 : path.size() + 1;
			const std::size_t slash = mount.mountpoint.find('/', start);
			items.insert(mount.mountpoint.substr(start, slash - start));
		}
		std::filesystem::path mapped;
		std::string error;
		if (resolveMountedEntry(mount.root, mount.mountpoint, path, mapped, true, error)
			&& _runtime->_filesystemBackend->isFolder(mapped.string()))
			for (const auto &item : _runtime->_filesystemBackend->getDirectoryItems(mapped.string())) items.insert(item);
	}
	collect(_runtime->_sourceRoot, path);
	output.assign(items.begin(), items.end());
}

std::vector<std::string> &DoraLoveFilesystem::getRequirePath()
{
	return _runtime->_requirePath;
}

std::string DoraLoveFilesystem::getExecutablePath() const
{
	return _runtime && _runtime->_filesystemBackend
		? _runtime->_filesystemBackend->getExecutablePath() : std::string();
}

LoveRuntime::~LoveRuntime()
{
	close();
}

void LoveRuntime::releaseLoveImage(GraphicsBackend::ImageHandle handle) noexcept
{
	if (handle != 0 && _imageHandles.erase(handle) != 0 && _graphicsBackend)
		_graphicsBackend->releaseImage(handle);
}

void LoveRuntime::retainLoveImageHandle(GraphicsBackend::ImageHandle handle) noexcept
{
	if (handle != 0) _imageHandles.insert(handle);
}

void LoveRuntime::forgetLoveImageHandle(GraphicsBackend::ImageHandle handle) noexcept
{
	_imageHandles.erase(handle);
}

void LoveRuntime::retainLoveCanvasHandle(GraphicsBackend::CanvasHandle handle) noexcept
{
	if (handle != 0) _canvasHandles.insert(handle);
}

void LoveRuntime::releaseLoveCanvas(GraphicsBackend::CanvasHandle handle) noexcept
{
	if (handle != 0 && _canvasHandles.erase(handle) != 0 && _graphicsBackend)
		_graphicsBackend->releaseCanvas(handle);
}

void LoveRuntime::forgetLoveCanvasHandle(GraphicsBackend::CanvasHandle handle) noexcept
{
	_canvasHandles.erase(handle);
}

void LoveRuntime::retainLoveFontHandle(GraphicsBackend::FontHandle handle) noexcept
{
	if (handle != 0) _fontHandles.insert(handle);
}

void LoveRuntime::releaseLoveFont(GraphicsBackend::FontHandle handle) noexcept
{
	if (handle != 0 && _fontHandles.erase(handle) != 0 && _graphicsBackend)
		_graphicsBackend->releaseFont(handle);
}

void LoveRuntime::forgetLoveFontHandle(GraphicsBackend::FontHandle handle) noexcept
{
	_fontHandles.erase(handle);
}

void LoveRuntime::retainLoveShaderHandle(GraphicsBackend::ShaderHandle handle) noexcept
{
	if (handle != 0) _shaderHandles.insert(handle);
}

void LoveRuntime::releaseLoveShader(GraphicsBackend::ShaderHandle handle) noexcept
{
	if (handle != 0 && _shaderHandles.erase(handle) != 0 && _graphicsBackend)
		_graphicsBackend->releaseShader(handle);
}

void LoveRuntime::forgetLoveShaderHandle(GraphicsBackend::ShaderHandle handle) noexcept
{
	_shaderHandles.erase(handle);
}

void LoveRuntime::retainLoveAudioSourceHandle(AudioBackend::SourceHandle handle) noexcept
{
	if (handle != 0) _audioHandles.insert(handle);
}

void LoveRuntime::releaseLoveAudioSource(AudioBackend::SourceHandle handle) noexcept
{
	if (handle == 0) return;
	_audioSourceFilters.erase(handle);
	_audioSourceEffects.erase(handle);
	if (_audioHandles.erase(handle) != 0 && _audioBackend)
		_audioBackend->releaseSource(handle);
}

void LoveRuntime::forgetLoveAudioSourceHandle(AudioBackend::SourceHandle handle) noexcept
{
	_audioSourceFilters.erase(handle);
	_audioSourceEffects.erase(handle);
	_audioHandles.erase(handle);
}

void LoveRuntime::copyAudioSourceSettings(AudioBackend::SourceHandle source,
	AudioBackend::SourceHandle destination)
{
	if (const auto found = _audioSourceFilters.find(source);
		found != _audioSourceFilters.end())
		_audioSourceFilters[destination] = found->second;
	if (const auto found = _audioSourceEffects.find(source);
		found != _audioSourceEffects.end())
		_audioSourceEffects[destination] = found->second;
}

bool LoveRuntime::setAudioSourceFilter(AudioBackend::SourceHandle source,
	const AudioBackend::FilterSettings *filter, std::string &error)
{
	if (!_audioBackend || !_audioBackend->setSourceFilter(source, filter, error))
		return false;
	if (filter) _audioSourceFilters[source] = *filter;
	else _audioSourceFilters.erase(source);
	return true;
}

bool LoveRuntime::getAudioSourceFilter(AudioBackend::SourceHandle source,
	AudioBackend::FilterSettings &filter) const
{
	const auto found = _audioSourceFilters.find(source);
	if (found == _audioSourceFilters.end()) return false;
	filter = found->second;
	return true;
}

bool LoveRuntime::setAudioSourceEffect(AudioBackend::SourceHandle source,
	std::string_view name, const AudioBackend::FilterSettings *filter,
	bool enabled, std::string &error)
{
	if (!_audioBackend || !_audioBackend->setSourceEffect(source, name, filter, enabled, error))
		return false;
	auto &effects = _audioSourceEffects[source];
	if (enabled)
		effects[std::string(name)] = filter
			? std::optional<AudioBackend::FilterSettings>(*filter) : std::nullopt;
	else effects.erase(std::string(name));
	if (effects.empty()) _audioSourceEffects.erase(source);
	return true;
}

bool LoveRuntime::getAudioSourceEffect(AudioBackend::SourceHandle source,
	std::string_view name, std::optional<AudioBackend::FilterSettings> &filter) const
{
	const auto sourceEffects = _audioSourceEffects.find(source);
	if (sourceEffects == _audioSourceEffects.end()) return false;
	const auto found = sourceEffects->second.find(std::string(name));
	if (found == sourceEffects->second.end()) return false;
	filter = found->second;
	return true;
}

void LoveRuntime::getAudioSourceEffects(AudioBackend::SourceHandle source,
	std::vector<std::string> &effects) const
{
	effects.clear();
	const auto found = _audioSourceEffects.find(source);
	if (found == _audioSourceEffects.end()) return;
	for (const auto &[name, _] : found->second) effects.push_back(name);
}

void LoveRuntime::retainLoveCursorHandle(MouseBackend::CursorHandle handle) noexcept
{
	if (handle != 0) _mouseCursorHandles.insert(handle);
}

void LoveRuntime::releaseLoveCursor(MouseBackend::CursorHandle handle) noexcept
{
	if (handle != 0 && _mouseCursorHandles.erase(handle) != 0 && _mouseBackend)
		_mouseBackend->releaseCursor(handle);
}

void LoveRuntime::forgetLoveCursorHandle(MouseBackend::CursorHandle handle) noexcept
{
	_mouseCursorHandles.erase(handle);
}

void LoveRuntime::retainLoveRecordingHandle(AudioBackend::RecordingHandle handle) noexcept
{
	if (handle != 0) _recordingHandles.insert(handle);
}

void LoveRuntime::stopLoveRecording(AudioBackend::RecordingHandle handle) noexcept
{
	if (handle != 0 && _recordingHandles.erase(handle) != 0 && _audioBackend)
		_audioBackend->stopRecording(handle);
}

void LoveRuntime::forgetLoveRecordingHandle(AudioBackend::RecordingHandle handle) noexcept
{
	_recordingHandles.erase(handle);
}

void LoveRuntime::retainLovePhysicsWorldHandle(PhysicsBackend::WorldHandle handle) noexcept
{
	if (handle != 0) _physicsWorldHandles.insert(handle);
}

void LoveRuntime::releaseLovePhysicsWorld(PhysicsBackend::WorldHandle handle) noexcept
{
	if (handle != 0 && _physicsWorldHandles.erase(handle) != 0 && _physicsBackend
		&& _physicsBackend->isWorldValid(handle))
		_physicsBackend->releaseWorld(handle);
}

void LoveRuntime::forgetLovePhysicsWorldHandle(PhysicsBackend::WorldHandle handle) noexcept
{
	_physicsWorldHandles.erase(handle);
}

void LoveRuntime::retainLovePhysicsBodyHandle(PhysicsBackend::BodyHandle handle) noexcept
{
	if (handle != 0) _physicsBodyHandles.insert(handle);
}

void LoveRuntime::releaseLovePhysicsBody(PhysicsBackend::BodyHandle handle) noexcept
{
	if (handle != 0 && _physicsBodyHandles.erase(handle) != 0 && _physicsBackend
		&& _physicsBackend->isBodyValid(handle))
		_physicsBackend->releaseBody(handle);
}

void LoveRuntime::forgetLovePhysicsBodyHandle(PhysicsBackend::BodyHandle handle) noexcept
{
	_physicsBodyHandles.erase(handle);
}

void LoveRuntime::retainLovePhysicsShapeHandle(PhysicsBackend::ShapeHandle handle) noexcept
{
	if (handle != 0) _physicsShapeHandles.insert(handle);
}

void LoveRuntime::releaseLovePhysicsShape(PhysicsBackend::ShapeHandle handle) noexcept
{
	if (handle != 0 && _physicsShapeHandles.erase(handle) != 0 && _physicsBackend)
		_physicsBackend->releaseShape(handle);
}

void LoveRuntime::forgetLovePhysicsShapeHandle(PhysicsBackend::ShapeHandle handle) noexcept
{
	_physicsShapeHandles.erase(handle);
}

void LoveRuntime::retainLovePhysicsFixtureHandle(PhysicsBackend::FixtureHandle handle) noexcept
{
	if (handle != 0) _physicsFixtureHandles.insert(handle);
}

void LoveRuntime::releaseLovePhysicsFixture(PhysicsBackend::FixtureHandle handle) noexcept
{
	if (handle != 0 && _physicsFixtureHandles.erase(handle) != 0 && _physicsBackend
		&& _physicsBackend->isFixtureValid(handle))
		_physicsBackend->releaseFixture(handle);
}

void LoveRuntime::forgetLovePhysicsFixtureHandle(PhysicsBackend::FixtureHandle handle) noexcept
{
	_physicsFixtureHandles.erase(handle);
}

void LoveRuntime::retainLovePhysicsJointHandle(PhysicsBackend::JointHandle handle) noexcept
{
	if (handle != 0) _physicsJointHandles.insert(handle);
}

void LoveRuntime::releaseLovePhysicsJoint(PhysicsBackend::JointHandle handle) noexcept
{
	if (handle != 0 && _physicsJointHandles.erase(handle) != 0 && _physicsBackend
		&& _physicsBackend->isJointValid(handle))
		_physicsBackend->releaseJoint(handle);
}

void LoveRuntime::forgetLovePhysicsJointHandle(PhysicsBackend::JointHandle handle) noexcept
{
	_physicsJointHandles.erase(handle);
}

void *LoveRuntime::luaAllocator(void *userdata, void *pointer, std::size_t oldSize, std::size_t newSize)
{
	auto *runtime = static_cast<LoveRuntime *>(userdata);
	if (newSize == 0)
	{
		std::free(pointer);
		if (pointer != nullptr)
			runtime->_allocationBytes -= std::min(runtime->_allocationBytes, oldSize);
		return nullptr;
	}

	void *newPointer = std::realloc(pointer, newSize);
	if (newPointer == nullptr)
		return nullptr;

	if (pointer == nullptr)
		runtime->_allocationBytes += newSize;
	else if (newSize >= oldSize)
		runtime->_allocationBytes += newSize - oldSize;
	else
		runtime->_allocationBytes -= std::min(runtime->_allocationBytes, oldSize - newSize);

	runtime->_peakAllocationBytes = std::max(runtime->_peakAllocationBytes, runtime->_allocationBytes);
	return newPointer;
}

bool LoveRuntime::open(std::string &error)
{
	if (_state != nullptr)
	{
		error = "LoveRuntime is already open";
		return false;
	}

	if (!_threadContext)
	{
		_threadContext = std::make_shared<ThreadContext>();
		_ownsThreadContext = true;
	}
	_allocationBytes = 0;
	_peakAllocationBytes = 0;
	_state = lua_newstate(luaAllocator, this, luaL_makeseed(nullptr));
	if (_state == nullptr)
	{
		if (_ownsThreadContext) _threadContext.reset();
		_ownsThreadContext = false;
		error = "failed to create Love Lua 5.5 state";
		return false;
	}
	// LÖVE 11.5 embeds LuaJIT/Lua 5.1 semantics, where loop variables can be
	// reassigned. Keep this compatibility local to the isolated Love state.
	lua_setloopvarcompat(_state, 1);
	lua_pushlightuserdata(_state, this);
	lua_setfield(_state, LUA_REGISTRYINDEX, LoveRuntimeRegistry);

	luaL_openlibs(_state);
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, runtimePrint, 1);
	lua_setglobal(_state, "print");
	// LOVE Reference instances (used by compatibility bridges while userdata
	// types are migrated incrementally) require a pinned thread for unref.
	::love::luax_insistpinnedthread(_state);
	static constexpr std::string_view compatibility = R"lua(
unpack = table.unpack
table.getn = table.getn or function(value)
	return #value
end
arg = arg or {}
math.pow = math.pow or function(base, exponent)
	return base ^ exponent
end
math.atan2 = math.atan2 or function(y, x)
	return math.atan(y, x)
end
local compatibility_require_loading = {}
require = function(name)
	local loaded = package.loaded[name]
	if loaded then return loaded end
	if compatibility_require_loading[name] then
		error("loop or previous error loading module '" .. name .. "'", 2)
	end
	local messages = {}
	for _, searcher in ipairs(package.searchers) do
		local loader, search_data = searcher(name)
		if type(loader) == "function" then
			compatibility_require_loading[name] = true
			-- LuaJIT/Lua 5.1 passes only the module name to its loader. Lua 5.2+
			-- also passes searcher data (usually a filename), which old modules
			-- can mistake for a real second vararg.
			local ok, result = pcall(loader, name)
			compatibility_require_loading[name] = nil
			if not ok then error(result, 0) end
			if result ~= nil then package.loaded[name] = result
			elseif package.loaded[name] == nil then package.loaded[name] = true end
			return package.loaded[name]
		elseif type(loader) == "string" then
			messages[#messages + 1] = loader
		elseif type(search_data) == "string" then
			messages[#messages + 1] = search_data
		end
	end
	error("module '" .. name .. "' not found:" .. table.concat(messages), 2)
end
local native_load = load
load = function(chunk, chunkname, mode, env)
	if type(chunk) == "string" and chunk:byte(1) == 0x1b then
		if chunk:sub(2, 3) == "LJ" then
			return nil, "Dora Love runtime uses Lua 5.5 and cannot load LuaJIT bytecode; provide Lua source or recompile it with Lua 5.5"
		end
		if chunk:sub(2, 4) == "Lua" and chunk:byte(5) ~= 0x55 then
			local version = chunk:byte(5) or 0
			return nil, ("Dora Love runtime uses Lua 5.5 and cannot load Lua %d.%d bytecode; provide Lua source or recompile it with Lua 5.5")
				:format(version >> 4, version & 0x0f)
		end
	end
	-- Passing an explicit nil environment to Lua 5.5 creates a chunk whose
	-- _ENV is nil. LuaJIT loadstring omits that argument and inherits _G.
	if env == nil then return native_load(chunk, chunkname, mode) end
	return native_load(chunk, chunkname, mode, env)
end
loadstring = load
package.loaders = package.searchers
package.loadlib = function()
	error("Dora Love runtime uses Lua 5.5 and does not support native Lua modules", 0)
end

local compatibility_global = _G
local compatibility_type = type
local compatibility_error = error
local compatibility_native_randomseed = math.randomseed
local compatibility_native_random = math.random
local compatibility_native_format = string.format
local compatibility_native_io_open = io.open
local compatibility_native_io_lines = io.lines
local compatibility_rawget = rawget
local compatibility_getinfo = debug.getinfo
local compatibility_getupvalue = debug.getupvalue
local compatibility_upvaluejoin = debug.upvaluejoin
local compatibility_noenv = setmetatable({}, {__mode = "k"})

local function compatibility_io_path(filename, mode)
	if compatibility_type(filename) ~= "string" or filename:sub(1, 1) == "/" then return filename end
	local normalized = filename:gsub("^%./+", "")
	if normalized == "" or normalized:find("\\", 1, true)
		or normalized:find("..", 1, true) then return filename end
	local filesystem = compatibility_global.love and compatibility_global.love.filesystem
	if not filesystem then return filename end
	if mode:find("[wa+]") then
		return filesystem.getSaveDirectory() .. "/" .. normalized
	end
	local root = filesystem.getRealDirectory(normalized)
	if root and root ~= "" and root:sub(-5) ~= ".love" then return root .. "/" .. normalized end
	return filename
end

io.open = function(filename, mode)
	mode = mode or "r"
	return compatibility_native_io_open(compatibility_io_path(filename, mode), mode)
end

io.lines = function(filename, ...)
	if filename == nil then return compatibility_native_io_lines() end
	local file, message = io.open(filename, "r")
	if not file then compatibility_error(message, 2) end
	return file:lines(...)
end

local function compatibility_ipairs_next(value, index)
	index = index + 1
	local item = compatibility_rawget(value, index)
	if item ~= nil then return index, item end
end

function ipairs(value)
	return compatibility_ipairs_next, value, 0
end

-- LuaJIT's math.randomseed accepts any finite number, while Lua 5.5 requires
-- an exact integer. Existing Love games commonly seed it from getTime(), so
-- truncate fractional inputs just like LuaJIT-compatible numeric C APIs.
math.randomseed = function(seed, stream)
	if compatibility_type(seed) == "number" and math.tointeger(seed) == nil then
		seed = seed < 0 and math.ceil(seed) or math.floor(seed)
	end
	if compatibility_type(stream) == "number" and math.tointeger(stream) == nil then
		stream = stream < 0 and math.ceil(stream) or math.floor(stream)
	end
	return compatibility_native_randomseed(seed, stream)
end

-- LuaJIT's numeric C API truncates finite numeric bounds toward zero. Lua 5.5
-- requires exact integer values, so preserve the behavior expected by older
-- LÖVE games without changing Dora's main Lua state.
math.random = function(lower, upper)
	if lower == nil then return compatibility_native_random() end
	if compatibility_type(lower) == "number" and math.tointeger(lower) == nil then
		lower = lower < 0 and math.ceil(lower) or math.floor(lower)
	end
	if upper == nil then return compatibility_native_random(lower) end
	if compatibility_type(upper) == "number" and math.tointeger(upper) == nil then
		upper = upper < 0 and math.ceil(upper) or math.floor(upper)
	end
	-- LuaJIT accepts reversed integer bounds and produces a value in the same
	-- inclusive interval. Lua 5.5 rejects the interval as empty.
	if lower > upper then lower, upper = upper, lower end
	return compatibility_native_random(lower, upper)
end

-- LuaJIT's string.format integer conversions accept finite numbers and
-- truncate them toward zero. Lua 5.5 requires an integer representation.
string.format = function(format, ...)
	local arguments = table.pack(...)
	local argument = 1
	local offset = 1
	while true do
		local percent = format:find("%", offset, true)
		if percent == nil then break end
		local nextCharacter = format:sub(percent + 1, percent + 1)
		if nextCharacter == "%" then
			offset = percent + 2
		else
			local finish = percent + 1
			while finish <= #format and not format:sub(finish, finish):match("[cdiouxXeEfgGaAsq]") do
				if format:sub(finish, finish) == "*" then argument = argument + 1 end
				finish = finish + 1
			end
			local conversion = format:sub(finish, finish)
			if conversion:match("[cdiouxX]") and compatibility_type(arguments[argument]) == "number"
				and math.tointeger(arguments[argument]) == nil then
				local value = arguments[argument]
				arguments[argument] = value < 0 and math.ceil(value) or math.floor(value)
			end
			argument = argument + 1
			offset = finish + 1
		end
	end
	return compatibility_native_format(format, table.unpack(arguments, 1, arguments.n))
end

local function compatibility_function(selector, api)
	local kind = compatibility_type(selector)
	if kind == "function" then
		return selector, selector
	end
	if kind ~= "number" or selector < 0 or selector % 1 ~= 0 then
		compatibility_error(("bad argument #1 to '%s' (function or non-negative integer expected)"):format(api), 3)
	end
	if selector == 0 then
		return nil, selector
	end
	local info = compatibility_getinfo(selector + 2, "f")
	if info == nil then
		compatibility_error("invalid level", 3)
	end
	return info.func, selector
end

local function compatibility_env_upvalue(func)
	local index = 1
	while true do
		local name, value = compatibility_getupvalue(func, index)
		if name == nil then return nil end
		if name == "_ENV" then return index, value end
		index = index + 1
	end
end

getfenv = function(selector)
	if selector == nil then selector = 1 end
	local func = compatibility_function(selector, "getfenv")
	if func == nil then return compatibility_global end
	local info = compatibility_getinfo(func, "S")
	if info == nil or (info.what ~= "Lua" and info.what ~= "main") then
		return compatibility_global
	end
	local _, env = compatibility_env_upvalue(func)
	return env or compatibility_noenv[func] or compatibility_global
end

setfenv = function(selector, env)
	if compatibility_type(env) ~= "table" then
		compatibility_error("bad argument #2 to 'setfenv' (table expected)", 2)
	end
	local func, original = compatibility_function(selector, "setfenv")
	if func == nil then
		compatibility_error("Dora Love runtime uses Lua 5.5 and cannot replace the running thread environment with setfenv(0, env)", 2)
	end
	local info = compatibility_getinfo(func, "S")
	if info == nil or (info.what ~= "Lua" and info.what ~= "main") then
		compatibility_error("setfenv cannot change the environment of a C function", 2)
	end
	local index = compatibility_env_upvalue(func)
	if index == nil then
		compatibility_noenv[func] = env
	else
		local function holder() return env end
		compatibility_upvaluejoin(func, index, holder, 1)
	end
	return original
end

-- Lua 5.1's module helper is still used by older Love games and libraries.
package.seeall = package.seeall or function(target)
	local meta = getmetatable(target) or {}
	meta.__index = compatibility_global
	setmetatable(target, meta)
end

module = module or function(name, ...)
	local target = package.loaded[name]
	if compatibility_type(target) ~= "table" then
		target = {}
		package.loaded[name] = target
	end
	local parent = _G
	local leaf = name
	for component in name:gmatch("([^.]+)%.") do
		if compatibility_type(parent[component]) ~= "table" then parent[component] = {} end
		parent = parent[component]
		leaf = leaf:sub(#component + 2)
	end
	parent[leaf] = target
	target._M = target
	target._NAME = name
	target._PACKAGE = name:match("^(.*%.)") or ""
	setfenv(2, target)
	for index = 1, select("#", ...) do
		local option = select(index, ...)
		if option ~= nil then option(target) end
	end
	return target
end

package.preload.ffi = function()
	error("Dora Love runtime uses Lua 5.5 and does not support LuaJIT ffi", 0)
end

package.preload.jit = function()
	error("Dora Love runtime uses Lua 5.5 and does not provide the LuaJIT compiler", 0)
end

package.preload.bit = function()
	local bit = {}
	local mask = 0xffffffff
	local function tobit(value)
		value = math.tointeger(value) & mask
		if value >= 0x80000000 then return value - 0x100000000 end
		return value
	end
	bit.tobit = tobit
	function bit.bnot(value) return tobit(~math.tointeger(value)) end
	function bit.band(value, ...)
		local result = math.tointeger(value)
		for index = 1, select("#", ...) do result = result & math.tointeger(select(index, ...)) end
		return tobit(result)
	end
	function bit.bor(value, ...)
		local result = math.tointeger(value)
		for index = 1, select("#", ...) do result = result | math.tointeger(select(index, ...)) end
		return tobit(result)
	end
	function bit.bxor(value, ...)
		local result = math.tointeger(value)
		for index = 1, select("#", ...) do result = result ~ math.tointeger(select(index, ...)) end
		return tobit(result)
	end
	function bit.lshift(value, shift) return tobit((math.tointeger(value) & mask) << (math.tointeger(shift) & 31)) end
	function bit.rshift(value, shift) return ((math.tointeger(value) & mask) >> (math.tointeger(shift) & 31)) & mask end
	function bit.arshift(value, shift)
		shift = math.tointeger(shift) & 31
		return tobit(math.floor(tobit(value) / (2 ^ shift)))
	end
	function bit.rol(value, shift)
		shift = math.tointeger(shift) & 31
		local input = math.tointeger(value) & mask
		if shift == 0 then return tobit(input) end
		return tobit((input << shift) | (input >> (32 - shift)))
	end
	function bit.ror(value, shift) return bit.rol(value, -(math.tointeger(shift) & 31)) end
	function bit.tohex(value, digits)
		digits = digits or 8
		local upper = digits < 0
		digits = math.min(math.abs(math.tointeger(digits)), 8)
		local text = string.format("%08x", math.tointeger(value) & mask):sub(9 - digits)
		return upper and text:upper() or text
	end
	return bit
end
)lua";
	if (luaL_loadbufferx(_state, compatibility.data(), compatibility.size(), "@dora-love-compat.lua", "t") != LUA_OK
		|| lua_pcall(_state, 0, 0, 0) != LUA_OK)
	{
		error = lua_tostring(_state, -1);
		close();
		return false;
	}
	if (!dora_open_builtin_modules(_state, error))
	{
		close();
		return false;
	}
	for (const auto &[name, code] : _preloadModules)
	{
		if (!installPreloadModule(name, code, error))
		{
			close();
			return false;
		}
	}
	registerImageType();
	registerCanvasType();
	registerCompressedImageDataType();
	registerQuadType();
	registerMeshType();
	registerSpriteBatchType();
	registerParticleSystemType();
	registerTextType();
	registerShaderType();
	registerFontType();
	registerAudioSourceType();
	registerVideoTypes();
	registerRecordingDeviceType();
	registerThreadTypes();
	registerPhysicsTypes();
	registerLoveModule();
	_graphicsColor[0] = _graphicsColor[1] = _graphicsColor[2] = _graphicsColor[3] = 1.0f;
	_graphicsBackgroundColor[0] = _graphicsBackgroundColor[1] = _graphicsBackgroundColor[2] = 0.0f;
	_graphicsBackgroundColor[3] = 1.0f;
	_graphicsDefaultFilter = GraphicsBackend::TextureFilter::Linear;
	_graphicsDefaultAnisotropy = 1.0f;
	_graphicsLineWidth = 1.0f;
	_graphicsLineStyle = GraphicsBackend::LineStyle::Smooth;
	_graphicsLineJoin = GraphicsBackend::LineJoin::Miter;
	_graphicsPointSize = 1.0f;
	_graphicsBlendMode = "alpha";
	_graphicsBlendAlphaMode = "alphamultiply";
	_graphicsScissorEnabled = false;
	std::fill(std::begin(_graphicsScissor), std::end(_graphicsScissor), 0.0f);
	std::fill(std::begin(_graphicsColorMask), std::end(_graphicsColorMask), true);
	_graphicsDepthCompare = "always";
	_graphicsDepthWrite = false;
	_graphicsMeshCullMode = "none";
	_graphicsFrontFaceWinding = "ccw";
	_graphicsWireframe = false;
	_graphicsStencilTestEnabled = false;
	_graphicsStencilCompare = "always";
	_graphicsStencilValue = 0;
	_graphicsStencilMode = "off";
	_graphicsStencilWriting = false;
	_graphicsCanvasDepthStencil = 0;
	_graphicsCanvasDepthStencilTarget = {};
	_graphicsCanvasDepthStencilReference = LUA_NOREF;
	_graphicsCanvasDepth = false;
	_graphicsCanvasStencil = false;
	_graphicsShader = 0;
	_graphicsShaderObject.set(nullptr);
	if (_graphicsBackend)
	{
		if (!_graphicsBackend->setBlendMode(_graphicsBlendMode, _graphicsBlendAlphaMode, error))
		{
			close();
			return false;
		}
		_graphicsBackend->setScissor(false, 0.0f, 0.0f, 0.0f, 0.0f);
		_graphicsBackend->setColorMask(true, true, true, true);
		_graphicsBackend->setDepthMode(_graphicsDepthCompare, _graphicsDepthWrite);
		_graphicsBackend->setMeshCullMode(_graphicsMeshCullMode, _graphicsFrontFaceWinding);
		_graphicsBackend->setWireframe(_graphicsWireframe);
		_graphicsBackend->setStencilTest(_graphicsStencilCompare, _graphicsStencilValue);
	}
	_configuredWidth = DefaultWindowWidth;
	_configuredHeight = DefaultWindowHeight;
	_windowResizable = false;
	_windowTitle = "Untitled";
	_windowVSync = 1;
	_windowDisplaySleepEnabled = false;
	_sourceRoot.clear();
	_saveBaseRoot.clear();
	_saveRoot.clear();
	_identity.clear();
	_requirePath = {"?.lua", "?/init.lua"};
	_generatedLineMaps.clear();
	resetGraphicsTransform();
	_graphicsStateStack.clear();
	_graphicsCanvases.clear();
	_graphicsCanvasTargets.clear();
	_graphicsCanvasReferences.clear();
	_graphicsCanvasObjects.clear();
	_graphicsCanvasDepthStencilObject.set(nullptr);
	_screenshotRequests.clear();
	_nextScreenshotRequest = 1;
	clearQueuedEvents();
	_pressedKeys.clear();
	_pressedScancodes.clear();
	_keyRepeatEnabled = false;
	_pressedMouseButtons.clear();
	_touches.clear();
	_fontHandles.clear();
	_imageHandles.clear();
	_canvasHandles.clear();
	_shaderHandles.clear();
	_audioHandles.clear();
	_recordingHandles.clear();
	_physicsWorldHandles.clear();
	_physicsBodyHandles.clear();
	_physicsShapeHandles.clear();
	_physicsFixtureHandles.clear();
	_physicsJointHandles.clear();
	_audioEffects.clear();
	_audioSourceFilters.clear();
	_audioSourceEffects.clear();
	_audioVolume = 1.0f;
	if (_audioBackend)
		_audioBackend->setInstanceVolume(_audioVolume);
	_physicsMeter = 30.0f;
	if (_physicsBackend)
		_physicsBackend->setMeter(_physicsMeter);
	_currentFont = 0;
	_graphicsFontObject.set(nullptr);
	_mouseX = _mouseY = 0.0f;
	_mouseVisible = true;
	_mouseGrabbed = false;
	_mouseRelativeMode = false;
	_mouseCursor = 0;
	_mouseCursorHandles.clear();
	_timerOrigin = steadySeconds();
	_timerDelta = 0.0;
	_timerAverageDelta = 0.0;
	_timerWindow = 0.0;
	_timerFrames = 0;
	_timerFPS = 0;
	_status = Status::Ready;
	_lastError.clear();
	error.clear();
	return true;
}

int LoveRuntime::runtimePrint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const int argumentCount = lua_gettop(state);
	std::string output;
	for (int index = 1; index <= argumentCount; ++index)
	{
		std::size_t length = 0;
		const char *text = luaL_tolstring(state, index, &length);
		if (index > 1) output.push_back('\t');
		output.append(text, length);
		lua_pop(state, 1);
	}
	const std::string_view identity = runtime && !runtime->_identity.empty()
		? std::string_view(runtime->_identity) : std::string_view("runtime");
	LogInfoThreaded("[Love:" + std::string(identity) + "] " + output);
	return 0;
}

bool LoveRuntime::installPreloadModule(std::string_view name, std::string_view code,
	std::string &error)
{
	const int base = lua_gettop(_state);
	const std::string chunkName = "@dora-preload/" + std::string(name) + ".lua";
	if (loadLoveChunk(_state, code, chunkName.c_str()) != LUA_OK)
	{
		error = lua_tostring(_state, -1);
		lua_settop(_state, base);
		return false;
	}
	lua_getglobal(_state, "package");
	lua_getfield(_state, -1, "preload");
	lua_pushvalue(_state, base + 1);
	lua_setfield(_state, -2, std::string(name).c_str());
	lua_settop(_state, base);
	error.clear();
	return true;
}

bool LoveRuntime::setPreloadModule(std::string_view name, std::string_view code,
	std::string &error)
{
	if (name.empty() || name.front() == '.' || name.back() == '.'
		|| name.find("..") != std::string_view::npos
		|| name.find('/') != std::string_view::npos || name.find('\\') != std::string_view::npos)
	{
		error = "invalid Love preload module name: " + std::string(name);
		return false;
	}
	if (_status != Status::Closed && _status != Status::Ready)
	{
		error = "Love preload modules can only be changed while the runtime is closed or ready";
		return false;
	}
	_preloadModules[std::string(name)] = std::string(code);
	if (_state != nullptr && !installPreloadModule(name, code, error))
	{
		_preloadModules.erase(std::string(name));
		return false;
	}
	error.clear();
	return true;
}

void LoveRuntime::close()
{
	if (_state == nullptr)
		return;
	if (_ownsThreadContext && _threadContext)
	{
		_threadContext->stopping.store(true, std::memory_order_release);
		{
			std::lock_guard lock(_threadContext->filesystemMutex);
			for (const auto &request : _threadContext->filesystemRequests)
				request->changed.notify_all();
		}
		std::vector<std::shared_ptr<ThreadChannel>> channels;
		std::vector<std::shared_ptr<ThreadWorker>> workers;
		{
			std::lock_guard lock(_threadContext->mutex);
			for (const auto &weak : _threadContext->channels)
				if (auto channel = weak.lock()) channels.push_back(std::move(channel));
			workers = _threadContext->workers;
		}
		for (const auto &channel : channels) channel->changed.notify_all();
		for (const auto &worker : workers)
			if (worker && worker->worker.joinable()) worker->worker.join();
		{
			std::lock_guard lock(_threadContext->mutex);
			_threadContext->workers.clear();
			_threadContext->channels.clear();
			_threadContext->namedChannels.clear();
		}
		{
			std::lock_guard lock(_threadContext->errorMutex);
			_threadContext->pendingErrors.clear();
		}
		{
			std::lock_guard lock(_threadContext->filesystemMutex);
			_threadContext->filesystemRequests.clear();
		}
	}
	_threadWorkers.clear();
	if (_graphicsBackend)
	{
		std::string ignored;
		if (_graphicsStencilWriting)
			_graphicsBackend->endStencilWrite();
		_graphicsBackend->setCanvases({}, 0, false, false, ignored);
		_graphicsBackend->setShader(0, ignored);
	}

	_screenshotRequests.clear();
	clearQueuedEvents();
	clearMountedArchives();
	// Releasing Bodies and Fixtures can synchronously emit PlayRho end-contact
	// notifications. Detach callbacks before tearing down the state-local object
	// maps so a callback cannot observe a partially-cleared Fixture registry.
	if (_physicsBackend)
	{
		for (const auto &[world, _] : _physicsWorldCallbacks)
		{
			std::string ignored;
			_physicsBackend->setWorldContactCallback(world, {}, ignored);
		}
	}
	// Physics objects can own love::Reference values. Drop Runtime's strong
	// references while the Lua state is still alive so their destructors can
	// safely release registry entries during lua_close.
	_physicsBodyObjects.clear();
	_physicsFixtureObjects.clear();
	_physicsJointObjects.clear();
	_physicsContactObjects.clear();
	lua_close(_state);
	_state = nullptr;
	while (!_mouseCursorHandles.empty())
		releaseLoveCursor(*_mouseCursorHandles.begin());
	_mouseCursor = 0;
	_physicsFixtureReferences.clear();
	_physicsContactReferences.clear();
	_physicsWorldCallbacks.clear();
	if (_audioBackend)
	{
		std::string ignored;
		for (const auto &[name, _] : _audioEffects)
			_audioBackend->setEffect(name, nullptr, ignored);
	}
	while (!_recordingHandles.empty())
		stopLoveRecording(*_recordingHandles.begin());
	while (!_audioHandles.empty())
		releaseLoveAudioSource(*_audioHandles.begin());
	_audioEffects.clear();
	_audioSourceFilters.clear();
	_audioSourceEffects.clear();
	// lua_close does not guarantee that every still-referenced Shader userdata
	// reaches our __gc path before the state disappears. Release any remaining
	// backend handles explicitly, and do it before Canvas handles so Shader
	// sampler bindings cannot retain their textures past Runtime shutdown.
	while (!_shaderHandles.empty())
		releaseLoveShader(*_shaderHandles.begin());
	while (!_imageHandles.empty())
		releaseLoveImage(*_imageHandles.begin());
	while (!_canvasHandles.empty())
		releaseLoveCanvas(*_canvasHandles.begin());
	while (!_fontHandles.empty())
		releaseLoveFont(*_fontHandles.begin());
	// A parent Physics destroy can invalidate several child handles at once.
	// Drain owned handles from leaves to roots so Runtime close never depends
	// on Lua finalizer order and each surviving Dora handle is released once.
	while (!_physicsJointHandles.empty())
		releaseLovePhysicsJoint(*_physicsJointHandles.begin());
	while (!_physicsFixtureHandles.empty())
		releaseLovePhysicsFixture(*_physicsFixtureHandles.begin());
	while (!_physicsBodyHandles.empty())
		releaseLovePhysicsBody(*_physicsBodyHandles.begin());
	while (!_physicsWorldHandles.empty())
		releaseLovePhysicsWorld(*_physicsWorldHandles.begin());
	while (!_physicsShapeHandles.empty())
		releaseLovePhysicsShape(*_physicsShapeHandles.begin());
	_canvasHandles.clear();
	_imageHandles.clear();
	_shaderHandles.clear();
	_recordingHandles.clear();
	_physicsWorldHandles.clear();
	_physicsBodyHandles.clear();
	_physicsShapeHandles.clear();
	_physicsFixtureHandles.clear();
	_physicsJointHandles.clear();
	_graphicsCanvases.clear();
	_graphicsCanvasTargets.clear();
	_graphicsCanvasReferences.clear();
	_graphicsCanvasObjects.clear();
	_graphicsCanvasDepthStencil = 0;
	_graphicsCanvasDepthStencilTarget = {};
	_graphicsCanvasDepthStencilReference = LUA_NOREF;
	_graphicsCanvasDepthStencilObject.set(nullptr);
	_graphicsCanvasDepth = false;
	_graphicsCanvasStencil = false;
	_graphicsShader = 0;
	_graphicsShaderObject.set(nullptr);
	_graphicsStencilWriting = false;
	_graphicsStateStack.clear();
	_fontHandles.clear();
	_currentFont = 0;
	_graphicsFontObject.set(nullptr);
	_status = Status::Closed;
	_lastError.clear();
	_bootCode.clear();
	_bootChunkName.clear();
	_generatedLineMaps.clear();
	_sourceRoot.clear();
	_saveBaseRoot.clear();
	_saveRoot.clear();
	_identity.clear();
	_requirePath.clear();
	_pressedKeys.clear();
	_pressedScancodes.clear();
	_keyRepeatEnabled = false;
	_pressedMouseButtons.clear();
	_touches.clear();
	if (_joystickBackend)
	{
		for (const auto &[id, joystick] : _joysticks)
		{
			if (joystick.connected && (joystick.vibrationLeft > 0.0f || joystick.vibrationRight > 0.0f))
				_joystickBackend->setJoystickVibration(id, 0.0f, 0.0f, 0.0);
		}
	}
	_joysticks.clear();
	_textInputEnabled = true;
	_threadContext.reset();
	_ownsThreadContext = false;
}

void LoveRuntime::releaseQueuedEvent(QueuedEvent &event) noexcept
{
	if (_state && event.registryReference != LUA_NOREF)
		luaL_unref(_state, LUA_REGISTRYINDEX, event.registryReference);
	event.registryReference = LUA_NOREF;
}

void LoveRuntime::clearQueuedEvents() noexcept
{
	for (auto &event : _eventQueue)
		releaseQueuedEvent(event);
	_eventQueue.clear();
}

void LoveRuntime::drainThreadErrors()
{
	if (!_state || !_threadContext) return;
	std::vector<std::pair<std::weak_ptr<ThreadWorker>, std::string>> errors;
	{
		std::lock_guard lock(_threadContext->errorMutex);
		errors.swap(_threadContext->pendingErrors);
	}
	for (auto &[weakWorker, message] : errors)
	{
		auto worker = weakWorker.lock();
		if (!worker) continue;
		auto *module = ::love::luax_getmodule<::love::thread::ThreadModule>(
			_state, ::love::Module::M_THREAD);
		auto *doraModule = dynamic_cast<DoraLoveThreadModule *>(module);
		if (!doraModule) continue;
		lua_createtable(_state, 2, 0);
		::love::luax_pushtype(_state, doraModule->threadForWorker(worker));
		lua_rawseti(_state, -2, 1);
		lua_pushlstring(_state, message.data(), message.size());
		lua_rawseti(_state, -2, 2);
		QueuedEvent event{QueuedEventType::Custom};
		event.first = "threaderror";
		event.presses = 2;
		event.registryReference = luaL_ref(_state, LUA_REGISTRYINDEX);
		_eventQueue.push_back(std::move(event));
	}
}

void LoveRuntime::drainThreadFilesystemRequests()
{
	if (!_threadContext || !_ownsThreadContext) return;
	std::deque<std::shared_ptr<ThreadFilesystemRequest>> requests;
	{
		std::lock_guard lock(_threadContext->filesystemMutex);
		requests.swap(_threadContext->filesystemRequests);
	}
	for (const auto &request : requests)
	{
		std::unique_lock lock(request->mutex);
		if (!request->cancelled && request->work) request->work();
		request->work = {};
		request->done = true;
		lock.unlock();
		request->changed.notify_all();
	}
}

int LoveRuntime::pushQueuedEventArguments(QueuedEvent &event, const char *&name)
{
	name = nullptr;
	switch (event.type)
	{
		case QueuedEventType::KeyPressed:
			_pressedKeys.insert(event.first);
			_pressedScancodes.insert(event.second);
			name = "keypressed";
			lua_pushlstring(_state, event.first.data(), event.first.size());
			lua_pushlstring(_state, event.second.data(), event.second.size());
			lua_pushboolean(_state, event.flag);
			return 3;
		case QueuedEventType::KeyReleased:
			_pressedKeys.erase(event.first);
			_pressedScancodes.erase(event.second);
			name = "keyreleased";
			lua_pushlstring(_state, event.first.data(), event.first.size());
			lua_pushlstring(_state, event.second.data(), event.second.size());
			return 2;
		case QueuedEventType::TextInput:
			name = "textinput";
			lua_pushlstring(_state, event.first.data(), event.first.size());
			return 1;
		case QueuedEventType::TextEdited:
			name = "textedited";
			lua_pushlstring(_state, event.first.data(), event.first.size());
			lua_pushinteger(_state, event.button);
			lua_pushinteger(_state, event.presses);
			return 3;
		case QueuedEventType::MousePressed:
			_mouseX = event.x;
			_mouseY = event.y;
			_pressedMouseButtons.insert(event.button);
			name = "mousepressed";
			lua_pushnumber(_state, event.x);
			lua_pushnumber(_state, event.y);
			lua_pushinteger(_state, event.button);
			lua_pushboolean(_state, event.flag);
			lua_pushinteger(_state, event.presses);
			return 5;
		case QueuedEventType::MouseReleased:
			_mouseX = event.x;
			_mouseY = event.y;
			_pressedMouseButtons.erase(event.button);
			name = "mousereleased";
			lua_pushnumber(_state, event.x);
			lua_pushnumber(_state, event.y);
			lua_pushinteger(_state, event.button);
			lua_pushboolean(_state, event.flag);
			lua_pushinteger(_state, event.presses);
			return 5;
		case QueuedEventType::MouseMoved:
			_mouseX = event.x;
			_mouseY = event.y;
			name = "mousemoved";
			lua_pushnumber(_state, event.x);
			lua_pushnumber(_state, event.y);
			lua_pushnumber(_state, event.deltaX);
			lua_pushnumber(_state, event.deltaY);
			lua_pushboolean(_state, event.flag);
			return 5;
		case QueuedEventType::WheelMoved:
			name = "wheelmoved";
			lua_pushnumber(_state, event.x);
			lua_pushnumber(_state, event.y);
			return 2;
		case QueuedEventType::TouchPressed:
		case QueuedEventType::TouchMoved:
		case QueuedEventType::TouchReleased:
			if (event.type == QueuedEventType::TouchReleased)
				_touches.erase(event.touchId);
			else
				_touches[event.touchId] = {event.x, event.y, event.pressure};
			name = event.type == QueuedEventType::TouchPressed ? "touchpressed"
				: event.type == QueuedEventType::TouchMoved ? "touchmoved" : "touchreleased";
			lua_pushlightuserdata(_state, reinterpret_cast<void *>(event.touchId));
			lua_pushnumber(_state, event.x);
			lua_pushnumber(_state, event.y);
			lua_pushnumber(_state, event.deltaX);
			lua_pushnumber(_state, event.deltaY);
			lua_pushnumber(_state, event.pressure);
			return 6;
		case QueuedEventType::JoystickAdded:
			name = "joystickadded";
			pushJoystick(event.controllerId);
			return 1;
		case QueuedEventType::JoystickRemoved:
			name = "joystickremoved";
			pushJoystick(event.controllerId);
			return 1;
		case QueuedEventType::JoystickPressed:
		case QueuedEventType::JoystickReleased:
			name = event.type == QueuedEventType::JoystickPressed
				? "joystickpressed" : "joystickreleased";
			pushJoystick(event.controllerId);
			lua_pushinteger(_state, event.button + 1);
			return 2;
		case QueuedEventType::JoystickAxis:
			name = "joystickaxis";
			pushJoystick(event.controllerId);
			lua_pushinteger(_state, event.button + 1);
			lua_pushnumber(_state, event.x);
			return 3;
		case QueuedEventType::JoystickHat:
			name = "joystickhat";
			pushJoystick(event.controllerId);
			lua_pushinteger(_state, event.button + 1);
			lua_pushlstring(_state, event.first.data(), event.first.size());
			return 3;
		case QueuedEventType::GamepadPressed:
		{
			auto found = _joysticks.find(event.controllerId);
			if (found == _joysticks.end())
				return -1;
			found->second.buttons.insert(event.first);
			name = "gamepadpressed";
			pushJoystick(event.controllerId);
			lua_pushlstring(_state, event.first.data(), event.first.size());
			return 2;
		}
		case QueuedEventType::GamepadReleased:
		{
			auto found = _joysticks.find(event.controllerId);
			if (found == _joysticks.end())
				return -1;
			found->second.buttons.erase(event.first);
			name = "gamepadreleased";
			pushJoystick(event.controllerId);
			lua_pushlstring(_state, event.first.data(), event.first.size());
			return 2;
		}
		case QueuedEventType::GamepadAxis:
		{
			auto found = _joysticks.find(event.controllerId);
			if (found == _joysticks.end())
				return -1;
			found->second.axes[event.first] = event.x;
			name = "gamepadaxis";
			pushJoystick(event.controllerId);
			lua_pushlstring(_state, event.first.data(), event.first.size());
			lua_pushnumber(_state, event.x);
			return 3;
		}
		case QueuedEventType::Custom:
		{
			name = event.first.c_str();
			if (event.registryReference == LUA_NOREF)
				return 0;
			const int base = lua_gettop(_state);
			lua_rawgeti(_state, LUA_REGISTRYINDEX, event.registryReference);
			for (int index = 1; index <= event.presses; ++index)
				lua_rawgeti(_state, base + 1, index);
			lua_remove(_state, base + 1);
			return event.presses;
		}
		case QueuedEventType::Quit:
			name = "quit";
			if (!event.first.empty())
			{
				lua_pushlstring(_state, event.first.data(), event.first.size());
				return 1;
			}
			if (event.flag)
			{
				lua_pushinteger(_state, event.button);
				return 1;
			}
			return 0;
	}
	return -1;
}

int LoveRuntime::pollQueuedEvent(lua_State *state)
{
	while (!_eventQueue.empty())
	{
		QueuedEvent event = std::move(_eventQueue.front());
		_eventQueue.pop_front();
		const int base = lua_gettop(state);
		const char *name = nullptr;
		const int argumentCount = pushQueuedEventArguments(event, name);
		if (argumentCount < 0 || name == nullptr)
		{
			lua_settop(state, base);
			releaseQueuedEvent(event);
			continue;
		}
		lua_pushstring(state, name);
		lua_insert(state, base + 1);
		releaseQueuedEvent(event);
		return argumentCount + 1;
	}
	return 0;
}

void LoveRuntime::queueKeyPressed(std::string key, std::string scancode, bool repeat)
{
	if (repeat && !_keyRepeatEnabled)
		return;
	_eventQueue.push_back({QueuedEventType::KeyPressed, std::move(key), std::move(scancode),
		0.0f, 0.0f, 0.0f, 0.0f, 0, 0, repeat});
}

void LoveRuntime::queueKeyReleased(std::string key, std::string scancode)
{
	_eventQueue.push_back({QueuedEventType::KeyReleased, std::move(key), std::move(scancode)});
}

void LoveRuntime::queueTextInput(std::string text)
{
	_eventQueue.push_back({QueuedEventType::TextInput, std::move(text)});
}

void LoveRuntime::queueTextEdited(std::string text, int start, int length)
{
	QueuedEvent event{QueuedEventType::TextEdited};
	event.first = std::move(text);
	event.button = start;
	event.presses = length;
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueMousePressed(float x, float y, int button, bool touch, int presses)
{
	_eventQueue.push_back({QueuedEventType::MousePressed, {}, {}, x, y, 0.0f, 0.0f, button, presses, touch});
}

void LoveRuntime::queueMouseReleased(float x, float y, int button, bool touch, int presses)
{
	_eventQueue.push_back({QueuedEventType::MouseReleased, {}, {}, x, y, 0.0f, 0.0f, button, presses, touch});
}

void LoveRuntime::queueMouseMoved(float x, float y, float deltaX, float deltaY, bool touch)
{
	_eventQueue.push_back({QueuedEventType::MouseMoved, {}, {}, x, y, deltaX, deltaY, 0, 0, touch});
}

void LoveRuntime::queueWheelMoved(float x, float y)
{
	_eventQueue.push_back({QueuedEventType::WheelMoved, {}, {}, x, y});
}

void LoveRuntime::queueTouchPressed(std::uintptr_t id, float x, float y,
	float deltaX, float deltaY, float pressure)
{
	QueuedEvent event{QueuedEventType::TouchPressed};
	event.x = x;
	event.y = y;
	event.deltaX = deltaX;
	event.deltaY = deltaY;
	event.touchId = id;
	event.pressure = pressure;
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueTouchReleased(std::uintptr_t id, float x, float y,
	float deltaX, float deltaY, float pressure)
{
	QueuedEvent event{QueuedEventType::TouchReleased};
	event.x = x;
	event.y = y;
	event.deltaX = deltaX;
	event.deltaY = deltaY;
	event.touchId = id;
	event.pressure = pressure;
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueTouchMoved(std::uintptr_t id, float x, float y,
	float deltaX, float deltaY, float pressure)
{
	QueuedEvent event{QueuedEventType::TouchMoved};
	event.x = x;
	event.y = y;
	event.deltaX = deltaX;
	event.deltaY = deltaY;
	event.touchId = id;
	event.pressure = pressure;
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::pushJoystick(int id)
{
	auto it = _joysticks.find(id);
	if (it == _joysticks.end())
	{
		lua_pushnil(_state);
		return;
	}
	if (it->second.object)
	{
		::love::luax_pushtype(_state,
			static_cast<::love::joystick::Joystick *>(it->second.object.get()));
		return;
	}
	auto *joystick = new JoystickUserdata(this, id);
	it->second.object.set(joystick);
	::love::luax_pushtype(_state, joystick);
	joystick->release();
}

void LoveRuntime::addJoystick(int id, std::string name, bool notify)
{
	auto [it, inserted] = _joysticks.try_emplace(id);
	const bool wasConnected = !inserted && it->second.connected;
	it->second.name = std::move(name);
	if (_joystickBackend)
		it->second.info = _joystickBackend->getJoystickInfo(id);
	else
		it->second.info.instanceId = id;
	if (!it->second.object)
	{
		auto *joystick = new JoystickUserdata(this, id);
		it->second.object.set(joystick);
		joystick->release();
	}
	it->second.connected = true;
	if (notify && !wasConnected)
	{
		QueuedEvent event{QueuedEventType::JoystickAdded};
		event.controllerId = id;
		_eventQueue.push_back(std::move(event));
	}
}

void LoveRuntime::removeJoystick(int id, bool notify)
{
	auto it = _joysticks.find(id);
	if (it == _joysticks.end() || !it->second.connected)
		return;
	it->second.connected = false;
	it->second.info.instanceId = -1;
	it->second.buttons.clear();
	it->second.axes.clear();
	it->second.vibrationLeft = 0.0f;
	it->second.vibrationRight = 0.0f;
	it->second.vibrationEndTime = 0.0;
	if (notify)
	{
		QueuedEvent event{QueuedEventType::JoystickRemoved};
		event.controllerId = id;
		_eventQueue.push_back(std::move(event));
	}
}

void LoveRuntime::queueJoystickPressed(int id, int button)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end() || !found->second.connected
		|| button < 0 || button >= found->second.info.buttonCount)
		return;
	QueuedEvent event{QueuedEventType::JoystickPressed};
	event.controllerId = id;
	event.button = button;
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueJoystickReleased(int id, int button)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end() || !found->second.connected
		|| button < 0 || button >= found->second.info.buttonCount)
		return;
	QueuedEvent event{QueuedEventType::JoystickReleased};
	event.controllerId = id;
	event.button = button;
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueJoystickAxis(int id, int axis, float value)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end() || !found->second.connected
		|| axis < 0 || axis >= found->second.info.axisCount)
		return;
	QueuedEvent event{QueuedEventType::JoystickAxis};
	event.controllerId = id;
	event.button = axis;
	event.x = std::clamp(value, -1.0f, 1.0f);
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueJoystickHat(int id, int hat, std::string direction)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end() || !found->second.connected
		|| hat < 0 || hat >= found->second.info.hatCount)
		return;
	static constexpr std::array<std::string_view, 9> directions = {
		"c", "u", "r", "d", "l", "ru", "rd", "lu", "ld"};
	if (std::find(directions.begin(), directions.end(), direction) == directions.end())
		direction = "c";
	QueuedEvent event{QueuedEventType::JoystickHat};
	event.controllerId = id;
	event.button = hat;
	event.first = std::move(direction);
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueGamepadPressed(int id, std::string button)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end())
		addJoystick(id, "Dora Controller " + std::to_string(id), false);
	else if (!found->second.connected)
		return;
	QueuedEvent event{QueuedEventType::GamepadPressed};
	event.controllerId = id;
	event.first = std::move(button);
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueGamepadReleased(int id, std::string button)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end())
		addJoystick(id, "Dora Controller " + std::to_string(id), false);
	else if (!found->second.connected)
		return;
	QueuedEvent event{QueuedEventType::GamepadReleased};
	event.controllerId = id;
	event.first = std::move(button);
	_eventQueue.push_back(std::move(event));
}

void LoveRuntime::queueGamepadAxis(int id, std::string axis, float value)
{
	const auto found = _joysticks.find(id);
	if (found == _joysticks.end())
		addJoystick(id, "Dora Controller " + std::to_string(id), false);
	else if (!found->second.connected)
		return;
	QueuedEvent event{QueuedEventType::GamepadAxis};
	event.controllerId = id;
	event.first = std::move(axis);
	event.x = std::clamp(value, -1.0f, 1.0f);
	_eventQueue.push_back(std::move(event));
}

bool LoveRuntime::completeScreenshot(std::uint64_t requestId, int width, int height,
	std::vector<std::uint8_t> rgba8, std::string &error)
{
	if (!_state)
	{
		error = "LoveRuntime is closed";
		return false;
	}
	auto found = _screenshotRequests.find(requestId);
	if (found == _screenshotRequests.end())
	{
		error = "Love screenshot request is no longer active";
		return false;
	}
	ScreenshotRequest request = std::move(found->second);
	_screenshotRequests.erase(found);
	const std::size_t expected = width > 0 && height > 0
		? static_cast<std::size_t>(width) * static_cast<std::size_t>(height) * 4 : 0;
	if (expected == 0 || rgba8.size() != expected)
	{
		if (request.callbackReference != LUA_NOREF)
			luaL_unref(_state, LUA_REGISTRYINDEX, request.callbackReference);
		return fail("Dora screenshot backend returned invalid RGBA8 dimensions", error);
	}

	auto imageData = ::love::StrongRef<::love::image::ImageData>(
		new ImageDataUserdata(this, width, height, ::love::PIXELFORMAT_RGBA8, rgba8.data()),
		::love::Acquire::NORETAIN);

	if (request.channel.get())
	{
		auto *channel = dynamic_cast<::love::thread::Channel *>(request.channel.get());
		if (!channel)
			return fail("Love screenshot Channel is no longer valid", error);
		channel->push(::love::Variant(&::love::image::ImageData::type, imageData.get()));
		error.clear();
		return true;
	}

	if (!request.filename.empty())
	{
		::love::image::FormatHandler::EncodedFormat format;
		if (!::love::image::ImageData::getConstant(request.format.c_str(), format))
			return fail("Unknown Love screenshot image format", error);
		try
		{
			auto encoded = ::love::StrongRef<::love::filesystem::FileData>(
				imageData->encode(format, request.filename.c_str(), true),
				::love::Acquire::NORETAIN);
		}
		catch (const ::love::Exception &exception)
		{
			return fail(exception.what(), error);
		}
		error.clear();
		return true;
	}

	const int stackBase = lua_gettop(_state);
	lua_pushcfunction(_state, traceback);
	const int errorHandler = stackBase + 1;
	lua_rawgeti(_state, LUA_REGISTRYINDEX, request.callbackReference);
	luaL_unref(_state, LUA_REGISTRYINDEX, request.callbackReference);
	::love::luax_pushtype(_state, ::love::image::ImageData::type, imageData.get());
	if (lua_pcall(_state, 1, 0, errorHandler) != LUA_OK)
	{
		std::string message = lua_tostring(_state, -1);
		lua_settop(_state, stackBase);
		return fail(std::move(message), error);
	}
	lua_settop(_state, stackBase);
	error.clear();
	return true;
}

bool LoveRuntime::setSourceRoot(std::string_view sourceRoot, std::string &error)
{
	if (_status != Status::Ready)
	{
		error = "LoveRuntime must be ready before setting its source root";
		return false;
	}
	if (sourceRoot.empty())
	{
		error = "Love source root is empty";
		return false;
	}
	if (!_filesystemBackend)
	{
		error = "Love filesystem backend is not attached";
		return false;
	}

	namespace fs = std::filesystem;
	std::error_code pathError;
	const fs::path root = fs::weakly_canonical(fs::path(sourceRoot), pathError);
	if (pathError || !_filesystemBackend->isFolder(root.string()))
	{
		error = "failed to resolve Love source root: "
			+ (pathError ? pathError.message() : std::string("not a directory"));
		return false;
	}
	_sourceRoot = root.string();
	if (_identity.empty())
	{
		const std::string defaultIdentity = root.filename().string();
		if (!setIdentity(defaultIdentity.empty() ? "love" : defaultIdentity, error))
			return false;
	}

	// Keep only preload and the confined instance searcher. In particular, do
	// not expose the process working directory or native Lua modules to Love.
	lua_getglobal(_state, "package");
	lua_getfield(_state, -1, "searchers");
	lua_newtable(_state);
	lua_geti(_state, -2, 1);
	lua_seti(_state, -2, 1);
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, sourceModuleSearcher, 1);
	lua_seti(_state, -2, 2);
	lua_setfield(_state, -3, "searchers");
	lua_getfield(_state, -2, "searchers");
	lua_setfield(_state, -3, "loaders");
	lua_pushliteral(_state, "");
	lua_setfield(_state, -3, "path");
	lua_pushliteral(_state, "");
	lua_setfield(_state, -3, "cpath");
	lua_pop(_state, 2);

	error.clear();
	return true;
}

bool LoveRuntime::setSaveBaseRoot(std::string_view saveBaseRoot, std::string &error)
{
	if (_status != Status::Ready)
	{
		error = "LoveRuntime must be ready before setting its save base root";
		return false;
	}
	if (saveBaseRoot.empty())
	{
		error = "Love save base root is empty";
		return false;
	}
	std::error_code pathError;
	const std::filesystem::path absolute = std::filesystem::absolute(
		std::filesystem::path(saveBaseRoot), pathError).lexically_normal();
	if (pathError)
	{
		error = "failed to resolve Love save base root: " + pathError.message();
		return false;
	}
	const std::filesystem::path canonical = std::filesystem::weakly_canonical(absolute, pathError);
	if (pathError)
	{
		error = "failed to canonicalize Love save base root: " + pathError.message();
		return false;
	}
	_saveBaseRoot = canonical.string();
	return refreshSaveRoot(error);
}

bool LoveRuntime::setIdentity(std::string_view identity, std::string &error)
{
	std::string normalized;
	if (identity.empty() || identity.size() > 128
		|| !normalizeLoveVirtualPath(identity, normalized))
	{
		error = "Love filesystem identity must be a safe relative path of 1 to 128 characters";
		return false;
	}
	for (const unsigned char character : identity)
	{
		if (character < 0x20 || character == 0x7f)
		{
			error = "Love filesystem identity cannot contain control characters";
			return false;
		}
	}
	_identity = std::move(normalized);
	return refreshSaveRoot(error);
}

bool LoveRuntime::refreshSaveRoot(std::string &error)
{
	_saveRoot.clear();
	if (_saveBaseRoot.empty() || _identity.empty())
	{
		error.clear();
		return true;
	}
	const std::filesystem::path base(_saveBaseRoot);
	const std::filesystem::path target = (base / _identity).lexically_normal();
	if (!isInsideRoot(base, target))
	{
		error = "Love filesystem identity escapes the save base root";
		return false;
	}
	_saveRoot = target.string();
	std::error_code createError;
	std::filesystem::create_directories(target, createError);
	if (createError)
	{
		error = "failed to create Love save directory: " + createError.message();
		_saveRoot.clear();
		return false;
	}
	error.clear();
	return true;
}

bool LoveRuntime::resolveReadPath(std::string_view filename, std::string &resolvedPath, std::string &error) const
{
	auto accept = [&](const std::filesystem::path &candidate) {
		if (_filesystemBackend && _filesystemBackend->exist(candidate.string())
			&& !_filesystemBackend->isFolder(candidate.string()))
		{
			resolvedPath = candidate.string();
			error.clear();
			return true;
		}
		return false;
	};
	const std::filesystem::path requested(filename);
	if (requested.is_absolute())
	{
		const std::filesystem::path normalized = requested.lexically_normal();
		const auto inside = [&](const std::string &root) {
			return !root.empty() && isInsideRoot(std::filesystem::path(root), normalized);
		};
		bool confined = inside(_saveRoot) || inside(_sourceRoot);
		for (const auto &mount : _mountedArchives)
			confined = confined || inside(mount.root);
		// A real absolute filename is accepted only when it is already confined
		// to this runtime. Otherwise keep resolving it as a PhysFS-style path:
		// LÖVE treats a leading slash as the root of the game's virtual filesystem.
		if (confined && accept(normalized)) return true;
	}
	std::filesystem::path candidate;
	std::string candidateError;
	if (resolveEntryWithinRoot(_saveRoot, filename, candidate, false, candidateError) && accept(candidate))
		return true;
	if (!candidateError.empty())
	{
		error = candidateError;
		return false;
	}
	for (const auto &mount : _mountedArchives)
	{
		candidateError.clear();
		if (resolveMountedEntry(mount.root, mount.mountpoint, filename, candidate, false, candidateError)
			&& accept(candidate))
			return true;
		if (!candidateError.empty())
		{
			error = candidateError;
			return false;
		}
	}
	candidateError.clear();
	if (resolveEntryWithinRoot(_sourceRoot, filename, candidate, false, candidateError) && accept(candidate))
		return true;
	if (!candidateError.empty())
	{
		error = candidateError;
		return false;
	}
	error = "Love filesystem file does not exist: " + std::string(filename);
	return false;
}

void LoveRuntime::clearMountedArchives()
{
	for (auto &mount : _mountedArchives)
	{
		if (_filesystemBackend)
			_filesystemBackend->unmountArchive(mount.root);
		if (_state && mount.dataReference != LUA_NOREF)
			luaL_unref(_state, LUA_REGISTRYINDEX, mount.dataReference);
	}
	_mountedArchives.clear();
}

int LoveRuntime::openLoveModule(lua_State *state)
{
	lua_getglobal(state, "love");
	return 1;
}

int LoveRuntime::loveRun(lua_State *)
{
	// Dora owns the application loop. The compatibility entry point must never
	// start Love's standalone loop or present an operating-system window.
	return 0;
}

int LoveRuntime::loveGetVersion(lua_State *state)
{
	lua_pushinteger(state, 11);
	lua_pushinteger(state, 5);
	lua_pushinteger(state, 0);
	lua_pushliteral(state, "Mysterious Mysteries");
	return 4;
}

int LoveRuntime::loveHandler(lua_State *state)
{
	const int argumentCount = lua_gettop(state);
	const char *name = lua_tostring(state, lua_upvalueindex(1));
	lua_getglobal(state, "love");
	lua_getfield(state, -1, name);
	lua_remove(state, -2);
	if (!lua_isfunction(state, -1))
	{
		lua_pop(state, 1);
		return 0;
	}
	lua_insert(state, 1);
	lua_call(state, argumentCount, 0);
	return 0;
}

int LoveRuntime::openLoveGraphicsModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "graphics");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveImageModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "image");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveFontModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "font");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveSoundModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "sound");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveMathModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "math");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveDataModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "data");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveWindowModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "window");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveEventModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "event");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveFilesystemModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "filesystem");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveKeyboardModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "keyboard");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveMouseModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "mouse");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveTouchModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "touch");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveJoystickModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "joystick");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveTimerModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "timer");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveAudioModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "audio");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveVideoModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "video");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::openLoveSystemModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "system");
	lua_remove(state, -2);
	return 1;
}

std::string DoraLoveSystem::getOS() const
{
	return _runtime && _runtime->_systemBackend ? _runtime->_systemBackend->getOS() : "Unknown";
}

int DoraLoveSystem::getProcessorCount() const
{
	return _runtime && _runtime->_systemBackend
		? std::max(1, _runtime->_systemBackend->getProcessorCount()) : 1;
}

void DoraLoveSystem::setClipboardText(const std::string &text) const
{
	if (!_runtime || !_runtime->_systemBackend)
		throw ::love::Exception("love.system clipboard backend is unavailable");
	std::string error;
	if (!_runtime->_systemBackend->setClipboardText(text, error))
		throw ::love::Exception("%s", error.empty()
			? "failed to set clipboard text" : error.c_str());
}

std::string DoraLoveSystem::getClipboardText() const
{
	if (!_runtime || !_runtime->_systemBackend)
		throw ::love::Exception("love.system clipboard backend is unavailable");
	std::string text;
	std::string error;
	if (!_runtime->_systemBackend->getClipboardText(text, error))
		throw ::love::Exception("%s", error.empty()
			? "failed to get clipboard text" : error.c_str());
	return text;
}

DoraLoveSystem::PowerState DoraLoveSystem::getPowerInfo(int &seconds, int &percent) const
{
	const auto info = _runtime && _runtime->_systemBackend
		? _runtime->_systemBackend->getPowerInfo()
		: SystemBackend::PowerInfo{};
	seconds = info.seconds;
	percent = info.percent;
	switch (info.state)
	{
		case SystemBackend::PowerState::Battery: return POWER_BATTERY;
		case SystemBackend::PowerState::NoBattery: return POWER_NO_BATTERY;
		case SystemBackend::PowerState::Charging: return POWER_CHARGING;
		case SystemBackend::PowerState::Charged: return POWER_CHARGED;
		case SystemBackend::PowerState::Unknown: return POWER_UNKNOWN;
	}
	return POWER_UNKNOWN;
}

bool DoraLoveSystem::openURL(const std::string &url) const
{
	if (!_runtime || !_runtime->_systemBackend) return false;
	std::string error;
	return _runtime->_systemBackend->openURL(url, error);
}

void DoraLoveSystem::vibrate(double seconds) const
{
	if (!std::isfinite(seconds) || seconds < 0.0)
		throw ::love::Exception("vibration duration must be a finite non-negative number");
	if (_runtime && _runtime->_systemBackend) _runtime->_systemBackend->vibrate(seconds);
}

bool DoraLoveSystem::hasBackgroundMusic() const
{
	return _runtime && _runtime->_systemBackend
		&& _runtime->_systemBackend->hasBackgroundMusic();
}

int LoveRuntime::openLoveThreadModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "thread");
	lua_remove(state, -2);
	return 1;
}

bool threadValueFromVariant(const ::love::Variant &variant, ThreadValue &value,
	std::string &error, int depth)
{
	if (depth > 32)
	{
		error = "thread value table nesting exceeds 32 levels";
		return false;
	}
	const auto &data = variant.getData();
	switch (variant.getType())
	{
		case ::love::Variant::NIL:
			value.type = ThreadValue::Type::Nil;
			return true;
		case ::love::Variant::BOOLEAN:
			value.type = ThreadValue::Type::Boolean;
			value.boolean = data.boolean;
			return true;
		case ::love::Variant::NUMBER:
			value.type = ThreadValue::Type::Number;
			value.number = data.number;
			return true;
		case ::love::Variant::STRING:
			value.type = ThreadValue::Type::String;
			value.string.assign(data.string->str, data.string->len);
			return true;
		case ::love::Variant::SMALLSTRING:
			value.type = ThreadValue::Type::String;
			value.string.assign(data.smallstring.str, data.smallstring.len);
			return true;
		case ::love::Variant::LOVEOBJECT:
		{
			auto *object = data.objectproxy.object;
			if (auto *channel = dynamic_cast<DoraLoveChannel *>(object))
			{
				value.type = ThreadValue::Type::Channel;
				value.channel = channel->channel();
				return true;
			}
			if (auto *image = dynamic_cast<::love::image::ImageData *>(object))
			{
				const char *format = nullptr;
				if (!::love::getConstant(image->getFormat(), format))
				{
					error = "unsupported ImageData pixel format in thread value";
					return false;
				}
				value.type = ThreadValue::Type::ImageData;
				value.width = image->getWidth();
				value.height = image->getHeight();
				value.format = format;
				const auto *bytes = static_cast<const std::uint8_t *>(image->getData());
				value.data.assign(bytes, bytes + image->getSize());
				return true;
			}
			if (auto *bytes = dynamic_cast<::love::Data *>(object))
			{
				value.type = ThreadValue::Type::Data;
				const auto *start = static_cast<const std::uint8_t *>(bytes->getData());
				value.data.clear();
				if (bytes->getSize() > 0)
					value.data.assign(start, start + bytes->getSize());
				return true;
			}
			error = "only Data, ImageData, and Channel objects can cross Dora Love thread states";
			return false;
		}
		case ::love::Variant::TABLE:
		{
			value.type = ThreadValue::Type::Table;
			value.table.clear();
			value.table.reserve(data.table->table->size());
			for (const auto &[variantKey, variantItem] : *data.table->table)
			{
				ThreadValue key, item;
				if (!threadValueFromVariant(variantKey, key, error, depth + 1)
					|| !threadValueFromVariant(variantItem, item, error, depth + 1))
					return false;
				if (key.type != ThreadValue::Type::Boolean
					&& key.type != ThreadValue::Type::Number
					&& key.type != ThreadValue::Type::String)
				{
					error = "thread value table keys must be booleans, numbers, or strings";
					return false;
				}
				value.table.emplace_back(std::move(key), std::move(item));
			}
			return true;
		}
		default:
			error = "boolean, number, string, Data, ImageData, Channel, or table expected";
			return false;
	}
}

::love::Variant threadValueToVariant(LoveRuntime *runtime, const ThreadValue &value)
{
	switch (value.type)
	{
		case ThreadValue::Type::Nil: return {};
		case ThreadValue::Type::Boolean: return ::love::Variant(value.boolean);
		case ThreadValue::Type::Number: return ::love::Variant(value.number);
		case ThreadValue::Type::String: return ::love::Variant(value.string);
		case ThreadValue::Type::Data:
		{
			auto *data = new ::love::data::ByteData(value.data.data(), value.data.size());
			::love::Variant result(&::love::data::ByteData::type, data);
			data->release();
			return result;
		}
		case ThreadValue::Type::ImageData:
		{
			::love::PixelFormat format = ::love::PIXELFORMAT_UNKNOWN;
			if (!::love::getConstant(value.format.c_str(), format))
				throw ::love::Exception("Unsupported ImageData pixel format in thread value: %s",
					value.format.c_str());
			auto *data = new ImageDataUserdata(runtime, value.width, value.height,
				format, value.data.data());
			::love::Variant result(&::love::image::ImageData::type, data);
			data->release();
			return result;
		}
		case ThreadValue::Type::Channel:
		{
			auto *channel = new DoraLoveChannel(runtime, value.channel);
			::love::Variant result(&::love::thread::Channel::type, channel);
			channel->release();
			return result;
		}
		case ThreadValue::Type::Table:
		{
			auto *table = new std::vector<std::pair<::love::Variant, ::love::Variant>>;
			table->reserve(value.table.size());
			for (const auto &[key, item] : value.table)
				table->emplace_back(threadValueToVariant(runtime, key),
					threadValueToVariant(runtime, item));
			return ::love::Variant(table);
		}
	}
	return {};
}

::love::thread::LuaThread *DoraLoveThreadModule::newThread(
	const std::string &name, ::love::Data *data)
{
	if (!_runtime || !_runtime->_threadContext || !data)
		throw ::love::Exception("Love thread runtime is unavailable");
	auto worker = std::make_shared<ThreadWorker>();
	worker->code.assign(static_cast<const char *>(data->getData()), data->getSize());
	worker->chunkName = name;
	worker->context = _runtime->_threadContext;
	worker->filesystem = _runtime->_filesystemBackend;
	worker->image = _runtime->_imageBackend;
	worker->sourceRoot = _runtime->_sourceRoot;
	worker->saveBaseRoot = _runtime->_saveBaseRoot;
	worker->identity = _runtime->_identity;
	worker->preloadModules = _runtime->_preloadModules;
	{
		std::lock_guard lock(_runtime->_threadContext->mutex);
		_runtime->_threadContext->workers.push_back(worker);
	}
	_runtime->_threadWorkers.push_back(worker);
	auto *thread = new DoraLoveLuaThread(_runtime, worker);
	_threads.emplace(worker.get(), ::love::StrongRef<DoraLoveLuaThread>(thread));
	return thread;
}

DoraLoveChannel *DoraLoveThreadModule::newChannel(std::shared_ptr<ThreadChannel> channel)
{
	return new DoraLoveChannel(_runtime, std::move(channel));
}

::love::thread::Channel *DoraLoveThreadModule::newChannel()
{
	if (!_runtime || !_runtime->_threadContext)
		throw ::love::Exception("Love thread runtime is unavailable");
	auto channel = std::make_shared<ThreadChannel>();
	channel->context = _runtime->_threadContext;
	{
		std::lock_guard lock(_runtime->_threadContext->mutex);
		_runtime->_threadContext->channels.push_back(channel);
	}
	return newChannel(std::move(channel));
}

::love::thread::Channel *DoraLoveThreadModule::getChannel(const std::string &name)
{
	auto local = _namedChannels.find(name);
	if (local != _namedChannels.end()) return local->second;
	if (!_runtime || !_runtime->_threadContext)
		throw ::love::Exception("Love thread runtime is unavailable");
	std::shared_ptr<ThreadChannel> channel;
	{
		std::lock_guard lock(_runtime->_threadContext->mutex);
		auto &slot = _runtime->_threadContext->namedChannels[name];
		if (!slot)
		{
			slot = std::make_shared<ThreadChannel>();
			slot->context = _runtime->_threadContext;
			_runtime->_threadContext->channels.push_back(slot);
		}
		channel = slot;
	}
	auto *result = newChannel(std::move(channel));
	_namedChannels.emplace(name,
		::love::StrongRef<DoraLoveChannel>(result, ::love::Acquire::NORETAIN));
	return result;
}

DoraLoveLuaThread *DoraLoveThreadModule::threadForWorker(
	const std::shared_ptr<ThreadWorker> &worker)
{
	const auto found = _threads.find(worker.get());
	if (found != _threads.end()) return found->second;
	auto *thread = new DoraLoveLuaThread(_runtime, worker);
	_threads.emplace(worker.get(),
		::love::StrongRef<DoraLoveLuaThread>(thread, ::love::Acquire::NORETAIN));
	return thread;
}

bool DoraLoveLuaThread::start(const std::vector<::love::Variant> &args)
{
	if (!_worker) return false;
	auto worker = _worker;
	std::vector<ThreadValue> arguments;
	arguments.reserve(args.size());
	for (const auto &argument : args)
	{
		ThreadValue value;
		std::string conversionError;
		if (!threadValueFromVariant(argument, value, conversionError))
			throw ::love::Exception("%s", conversionError.c_str());
		arguments.push_back(std::move(value));
	}
	std::unique_lock lock(worker->mutex);
	if (worker->running || (worker->context && worker->context->stopping.load(std::memory_order_acquire)))
		return false;
	if (worker->worker.joinable())
	{
		lock.unlock();
		worker->worker.join();
		lock.lock();
	}
	worker->arguments = std::move(arguments);
	worker->error.clear();
	worker->started = true;
	worker->running = true;
	worker->worker = std::thread([worker]()
	{
		std::string workerError;
		if (!worker->context || worker->context->stopping.load(std::memory_order_acquire))
			workerError = "Love thread stopped because its runtime is closing";
		else
		{
			LoveRuntime runtime;
			ThreadFilesystemBackend filesystem(worker->context, worker->filesystem);
			ThreadImageBackend image(worker->context, worker->image);
			runtime._threadContext = worker->context;
			runtime._ownsThreadContext = false;
			runtime._preloadModules = worker->preloadModules;
			runtime.setFilesystemBackend(worker->filesystem ? &filesystem : nullptr);
			runtime.setImageBackend(worker->image ? &image : nullptr);
			if (runtime.open(workerError)
				&& (worker->sourceRoot.empty() || runtime.setSourceRoot(worker->sourceRoot, workerError))
				&& (worker->saveBaseRoot.empty() || runtime.setSaveBaseRoot(worker->saveBaseRoot, workerError))
				&& (worker->identity.empty() || runtime.setIdentity(worker->identity, workerError)))
			{
				lua_State *threadState = runtime._state;
				lua_pushlightuserdata(threadState, worker->context.get());
				lua_setfield(threadState, LUA_REGISTRYINDEX, ThreadContextRegistry);
				lua_sethook(threadState, threadCancellationHook, LUA_MASKCOUNT, 10000);
				lua_pushlightuserdata(threadState, &runtime);
				lua_pushcclosure(threadState, LoveRuntime::traceback, 1);
				const int errorHandler = lua_gettop(threadState);
				const std::string chunkName = runtime.prepareGeneratedChunk(
					worker->code, worker->chunkName);
				if (loadLoveChunk(threadState, worker->code, chunkName.c_str()) != LUA_OK)
				{
					runtime.rewriteGeneratedErrorOnStack(threadState);
					workerError = lua_tostring(threadState, -1);
				}
				else
				{
					for (const auto &argument : worker->arguments)
						pushThreadValue(threadState, argument);
					if (lua_pcall(threadState, static_cast<int>(worker->arguments.size()), 0,
						errorHandler) != LUA_OK)
						workerError = lua_tostring(threadState, -1);
				}
				lua_sethook(threadState, nullptr, 0, 0);
			}
			runtime.close();
		}
		const bool stopping = worker->context
			&& worker->context->stopping.load(std::memory_order_acquire);
		{
			std::lock_guard workerLock(worker->mutex);
			worker->error = stopping ? std::string{} : workerError;
			worker->running = false;
		}
		if (!workerError.empty() && !stopping && worker->context)
		{
			std::lock_guard errorLock(worker->context->errorMutex);
			worker->context->pendingErrors.emplace_back(worker, std::move(workerError));
		}
	});
	lock.unlock();
	return true;
}

void DoraLoveLuaThread::wait()
{
	if (!_worker) return;
	for (;;)
	{
		{
			std::lock_guard lock(_worker->mutex);
			if (!_worker->running) break;
		}
		if (_runtime) _runtime->drainThreadFilesystemRequests();
		std::this_thread::sleep_for(std::chrono::milliseconds(1));
	}
	std::unique_lock lock(_worker->mutex);
	if (_worker->worker.joinable())
	{
		lock.unlock();
		_worker->worker.join();
	}
}

bool DoraLoveLuaThread::isRunning() const
{
	if (!_worker) return false;
	std::lock_guard lock(_worker->mutex);
	return _worker->running;
}

const std::string &DoraLoveLuaThread::getError() const
{
	static const std::string empty;
	return _worker ? _worker->error : empty;
}

bool DoraLoveLuaThread::hasError() const
{
	if (!_worker) return false;
	std::lock_guard lock(_worker->mutex);
	return !_worker->error.empty();
}

::love::uint64 DoraLoveChannel::push(const ::love::Variant &variant)
{
	ThreadValue value;
	std::string error;
	if (!threadValueFromVariant(variant, value, error))
		throw ::love::Exception("%s", error.c_str());
	std::lock_guard lock(_channel->mutex);
	const std::uint64_t id = _channel->nextId++;
	_channel->values.push_back({id, std::move(value)});
	_channel->changed.notify_all();
	return id;
}

bool DoraLoveChannel::waitForRead(::love::uint64 id, std::optional<double> timeout)
{
	if (timeout && !std::isfinite(*timeout))
		throw ::love::Exception("timeout must be finite");
	if (timeout && *timeout < 0.0) return false;
	std::unique_lock lock(_channel->mutex);
	const auto consumed = [&]() {
		return _channel->lastReadId >= id || threadContextStopping(_channel);
	};
	const auto deadline = std::chrono::steady_clock::now()
		+ std::chrono::duration_cast<std::chrono::steady_clock::duration>(
			std::chrono::duration<double>(timeout.value_or(0.0)));
	while (!consumed())
	{
		lock.unlock();
		if (_runtime) _runtime->drainThreadFilesystemRequests();
		lock.lock();
		if (consumed()) break;
		if (timeout && std::chrono::steady_clock::now() >= deadline) return false;
		_channel->changed.wait_for(lock, std::chrono::milliseconds(1), consumed);
	}
	return _channel->lastReadId >= id;
}

bool DoraLoveChannel::supply(const ::love::Variant &variant)
{
	return waitForRead(push(variant), std::nullopt);
}

bool DoraLoveChannel::supply(const ::love::Variant &variant, double timeout)
{
	return waitForRead(push(variant), timeout);
}

bool DoraLoveChannel::pop(::love::Variant *variant)
{
	ThreadValue value;
	{
		std::lock_guard lock(_channel->mutex);
		if (_channel->values.empty()) return false;
		auto entry = std::move(_channel->values.front());
		_channel->values.pop_front();
		_channel->lastReadId = std::max(_channel->lastReadId, entry.id);
		_channel->changed.notify_all();
		value = std::move(entry.value);
	}
	*variant = threadValueToVariant(_runtime, value);
	return true;
}

bool DoraLoveChannel::waitForValue(::love::Variant *variant,
	std::optional<double> timeout)
{
	if (timeout && !std::isfinite(*timeout))
		throw ::love::Exception("timeout must be finite");
	if (timeout && *timeout < 0.0) return false;
	std::unique_lock lock(_channel->mutex);
	const auto available = [&]() {
		return !_channel->values.empty() || threadContextStopping(_channel);
	};
	const auto deadline = std::chrono::steady_clock::now()
		+ std::chrono::duration_cast<std::chrono::steady_clock::duration>(
			std::chrono::duration<double>(timeout.value_or(0.0)));
	while (!available())
	{
		lock.unlock();
		if (_runtime) _runtime->drainThreadFilesystemRequests();
		lock.lock();
		if (available()) break;
		if (timeout && std::chrono::steady_clock::now() >= deadline) return false;
		_channel->changed.wait_for(lock, std::chrono::milliseconds(1), available);
	}
	if (_channel->values.empty()) return false;
	auto entry = std::move(_channel->values.front());
	_channel->values.pop_front();
	_channel->lastReadId = std::max(_channel->lastReadId, entry.id);
	_channel->changed.notify_all();
	lock.unlock();
	*variant = threadValueToVariant(_runtime, entry.value);
	return true;
}

bool DoraLoveChannel::demand(::love::Variant *variant)
{
	return waitForValue(variant, std::nullopt);
}

bool DoraLoveChannel::demand(::love::Variant *variant, double timeout)
{
	return waitForValue(variant, timeout);
}

bool DoraLoveChannel::peek(::love::Variant *variant)
{
	ThreadValue value;
	{
		std::lock_guard lock(_channel->mutex);
		if (_channel->values.empty()) return false;
		value = _channel->values.front().value;
	}
	*variant = threadValueToVariant(_runtime, value);
	return true;
}

int DoraLoveChannel::getCount() const
{
	std::lock_guard lock(_channel->mutex);
	return static_cast<int>(_channel->values.size());
}

bool DoraLoveChannel::hasRead(::love::uint64 id) const
{
	std::lock_guard lock(_channel->mutex);
	return _channel->lastReadId >= id;
}

void DoraLoveChannel::clear()
{
	std::lock_guard lock(_channel->mutex);
	if (!_channel->values.empty())
	{
		_channel->lastReadId = std::max(_channel->lastReadId,
			_channel->values.back().id);
		_channel->values.clear();
		_channel->changed.notify_all();
	}
}

int LoveRuntime::openLovePhysicsModule(lua_State *state)
{
	lua_getglobal(state, "love");
	lua_getfield(state, -1, "physics");
	lua_remove(state, -2);
	return 1;
}

int LoveRuntime::physicsSetMeter(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float meter = static_cast<float>(luaL_checknumber(state, 1));
	luaL_argcheck(state, std::isfinite(meter) && meter > 0.0f, 1, "meter must be a finite positive number");
	runtime->_physicsMeter = meter;
	if (runtime->_physicsBackend) runtime->_physicsBackend->setMeter(meter);
	return 0;
}

int LoveRuntime::physicsGetMeter(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, runtime->_physicsMeter);
	return 1;
}

int LoveRuntime::physicsGetDistance(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *fixtureA = checkPhysicsFixture(state, 1);
	auto *fixtureB = checkPhysicsFixture(state, 2);
	luaL_argcheck(state, runtime && runtime->_physicsBackend, 1,
		"Love physics backend is unavailable");
	luaL_argcheck(state, fixtureA->runtime == runtime && fixtureA->handle != 0,
		1, "Fixture is destroyed or belongs to another Love state");
	luaL_argcheck(state, fixtureB->runtime == runtime && fixtureB->handle != 0,
		2, "Fixture is destroyed or belongs to another Love state");
	float distance = 0.0f;
	float pointAX = 0.0f, pointAY = 0.0f, pointBX = 0.0f, pointBY = 0.0f;
	std::string error;
	if (!runtime->_physicsBackend->getFixtureDistance(fixtureA->handle, fixtureB->handle,
		distance, pointAX, pointAY, pointBX, pointBY, error))
		return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, distance);
	lua_pushnumber(state, pointAX);
	lua_pushnumber(state, pointAY);
	lua_pushnumber(state, pointBX);
	lua_pushnumber(state, pointBY);
	return 5;
}

int LoveRuntime::physicsNewWorld(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_argcheck(state, runtime && runtime->_physicsBackend, 1, "Love physics backend is unavailable");
	const float gx = static_cast<float>(luaL_optnumber(state, 1, 0.0));
	const float gy = static_cast<float>(luaL_optnumber(state, 2, 0.0));
	const bool sleep = lua_isnoneornil(state, 3) ? true : lua_toboolean(state, 3);
	luaL_argcheck(state, std::isfinite(gx), 1, "gravity x must be finite");
	luaL_argcheck(state, std::isfinite(gy), 2, "gravity y must be finite");
	std::string error;
	const auto handle = runtime->_physicsBackend->newWorld(gx, gy, sleep, error);
	if (handle == 0) return luaL_error(state, "%s", error.empty() ? "failed to create physics World" : error.c_str());
	auto *world = new PhysicsWorldUserdata(runtime, handle);
	pushNewDoraHandleObject(state, ::love::physics::World::type, world);
	return 1;
}

int LoveRuntime::physicsNewBody(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *world = checkPhysicsWorld(state, 1);
	luaL_argcheck(state, world->runtime == runtime && world->handle != 0, 1, "World is destroyed or belongs to another Love state");
	const float x = static_cast<float>(luaL_optnumber(state, 2, 0.0));
	const float y = static_cast<float>(luaL_optnumber(state, 3, 0.0));
	const char *type = luaL_optstring(state, 4, "static");
	luaL_argcheck(state, std::string_view(type) == "static" || std::string_view(type) == "dynamic"
		|| std::string_view(type) == "kinematic", 4, "expected 'static', 'dynamic', or 'kinematic'");
	std::string error;
	const auto handle = runtime->_physicsBackend->newBody(world->handle, x, y, type, error);
	if (handle == 0) return luaL_error(state, "%s", error.empty() ? "failed to create physics Body" : error.c_str());
	auto *body = new PhysicsBodyUserdata(runtime, handle, world->handle, type);
	body->worldObject.set(world);
	runtime->trackPhysicsBodyObject(handle, body);
	pushNewDoraHandleObject(state, ::love::physics::Body::type, body);
	lua_getiuservalue(state, 1, 1);
	if (!lua_istable(state, -1))
	{
		lua_pop(state, 1);
		lua_newtable(state);
		lua_pushvalue(state, -1);
		lua_setiuservalue(state, 1, 1);
	}
	const auto bodyCount = static_cast<lua_Integer>(lua_rawlen(state, -1));
	lua_pushvalue(state, -2);
	lua_seti(state, -2, bodyCount + 1);
	lua_pop(state, 1);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	return 1;
}

int LoveRuntime::physicsNewCircleShape(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	float x = 0.0f, y = 0.0f, radius = 0.0f;
	if (lua_gettop(state) == 1) radius = static_cast<float>(luaL_checknumber(state, 1));
	else if (lua_gettop(state) == 3)
	{
		x = static_cast<float>(luaL_checknumber(state, 1));
		y = static_cast<float>(luaL_checknumber(state, 2));
		radius = static_cast<float>(luaL_checknumber(state, 3));
	}
	else return luaL_error(state, "newCircleShape expects radius or x, y, radius");
	luaL_argcheck(state, std::isfinite(radius) && radius > 0.0f, lua_gettop(state), "radius must be finite and positive");
	std::string error;
	const auto handle = runtime->_physicsBackend->newCircleShape(x, y, radius, error);
	if (handle == 0) return luaL_error(state, "%s", error.empty() ? "failed to create CircleShape" : error.c_str());
	auto *shape = new PhysicsShapeUserdata(runtime, handle, "circle", radius, {x, y});
	pushNewDoraHandleObject(state, ::love::physics::Shape::type, shape);
	return 1;
}

int LoveRuntime::physicsNewRectangleShape(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	float x = 0.0f, y = 0.0f, width = 0.0f, height = 0.0f, angle = 0.0f;
	const int count = lua_gettop(state);
	if (count == 2)
	{
		width = static_cast<float>(luaL_checknumber(state, 1));
		height = static_cast<float>(luaL_checknumber(state, 2));
	}
	else if (count == 4 || count == 5)
	{
		x = static_cast<float>(luaL_checknumber(state, 1));
		y = static_cast<float>(luaL_checknumber(state, 2));
		width = static_cast<float>(luaL_checknumber(state, 3));
		height = static_cast<float>(luaL_checknumber(state, 4));
		angle = static_cast<float>(luaL_optnumber(state, 5, 0.0));
	}
	else return luaL_error(state, "newRectangleShape expects width, height or x, y, width, height, angle");
	luaL_argcheck(state, std::isfinite(width) && width > 0.0f, count == 2 ? 1 : 3, "width must be finite and positive");
	luaL_argcheck(state, std::isfinite(height) && height > 0.0f, count == 2 ? 2 : 4, "height must be finite and positive");
	std::string error;
	const auto handle = runtime->_physicsBackend->newRectangleShape(x, y, width, height, angle, error);
	if (handle == 0) return luaL_error(state, "%s", error.empty() ? "failed to create PolygonShape" : error.c_str());
	const auto halfWidth = width * 0.5f;
	const auto halfHeight = height * 0.5f;
	const auto cosine = std::cos(angle);
	const auto sine = std::sin(angle);
	std::vector<float> points;
	points.reserve(8);
	for (const auto &[localX, localY] : std::array<std::pair<float, float>, 4>{
		std::pair{-halfWidth, -halfHeight}, std::pair{halfWidth, -halfHeight},
		std::pair{halfWidth, halfHeight}, std::pair{-halfWidth, halfHeight}})
	{
		points.push_back(x + localX * cosine - localY * sine);
		points.push_back(y + localX * sine + localY * cosine);
	}
	auto *shape = new PhysicsShapeUserdata(runtime, handle, "polygon", 0.0f, std::move(points));
	pushNewDoraHandleObject(state, ::love::physics::Shape::type, shape);
	return 1;
}

static std::vector<float> checkPhysicsShapePoints(lua_State *state, int firstArgument,
	const char *shapeName)
{
	const bool table = lua_istable(state, firstArgument);
	const int count = table ? static_cast<int>(lua_rawlen(state, firstArgument))
		: lua_gettop(state) - firstArgument + 1;
	if (count % 2 != 0)
		luaL_error(state, "%s vertex component count must be a multiple of two", shapeName);
	std::vector<float> points;
	points.reserve(static_cast<std::size_t>(count));
	for (int index = 0; index < count; ++index)
	{
		if (table) lua_rawgeti(state, firstArgument, index + 1);
		const float value = static_cast<float>(luaL_checknumber(state,
			table ? -1 : firstArgument + index));
		if (table) lua_pop(state, 1);
		if (!std::isfinite(value)) luaL_error(state, "%s vertices must be finite", shapeName);
		points.push_back(value);
	}
	return points;
}

int LoveRuntime::physicsNewPolygonShape(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto points = checkPhysicsShapePoints(state, 1, "PolygonShape");
	const auto vertexCount = points.size() / 2;
	luaL_argcheck(state, vertexCount >= 3, 1, "PolygonShape requires at least 3 vertices");
	luaL_argcheck(state, vertexCount <= 8, 1, "PolygonShape supports at most 8 vertices");
	std::string error;
	const auto handle = runtime->_physicsBackend->newPolygonShape(points, error);
	if (!handle) return luaL_error(state, "%s", error.empty() ? "failed to create PolygonShape" : error.c_str());
	auto *shape = new PhysicsShapeUserdata(runtime, handle, "polygon", 0.0f, std::move(points));
	pushNewDoraHandleObject(state, ::love::physics::Shape::type, shape);
	return 1;
}

int LoveRuntime::physicsNewEdgeShape(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float x1 = static_cast<float>(luaL_checknumber(state, 1));
	const float y1 = static_cast<float>(luaL_checknumber(state, 2));
	const float x2 = static_cast<float>(luaL_checknumber(state, 3));
	const float y2 = static_cast<float>(luaL_checknumber(state, 4));
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 1, "EdgeShape vertices must be finite");
	luaL_argcheck(state, x1 != x2 || y1 != y2, 1, "EdgeShape vertices must be distinct");
	std::string error;
	const auto handle = runtime->_physicsBackend->newEdgeShape(x1, y1, x2, y2, error);
	if (!handle) return luaL_error(state, "%s", error.empty() ? "failed to create EdgeShape" : error.c_str());
	auto *shape = new PhysicsShapeUserdata(runtime, handle, "edge", 0.0f, {x1, y1, x2, y2});
	pushNewDoraHandleObject(state, ::love::physics::Shape::type, shape);
	return 1;
}

int LoveRuntime::physicsNewChainShape(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	const bool loop = lua_toboolean(state, 1);
	auto points = checkPhysicsShapePoints(state, 2, "ChainShape");
	const auto vertexCount = points.size() / 2;
	luaL_argcheck(state, vertexCount >= (loop ? 3u : 2u), 2,
		loop ? "looping ChainShape requires at least 3 vertices"
			: "ChainShape requires at least 2 vertices");
	std::string error;
	const auto handle = runtime->_physicsBackend->newChainShape(loop, points, error);
	if (!handle) return luaL_error(state, "%s", error.empty() ? "failed to create ChainShape" : error.c_str());
	if (loop) { points.push_back(points[0]); points.push_back(points[1]); }
	auto *shape = new PhysicsShapeUserdata(runtime, handle, "chain", 0.0f, std::move(points));
	shape->loop = loop;
	if (loop)
	{
		shape->hasPreviousVertex = shape->hasNextVertex = true;
		shape->previousX = shape->points[shape->points.size() - 4];
		shape->previousY = shape->points[shape->points.size() - 3];
		shape->nextX = shape->points[2];
		shape->nextY = shape->points[3];
	}
	pushNewDoraHandleObject(state, ::love::physics::Shape::type, shape);
	return 1;
}

int LoveRuntime::physicsNewFixture(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *body = checkPhysicsBody(state, 1);
	auto *shape = checkPhysicsShape(state, 2);
	luaL_argcheck(state, body->runtime == runtime && shape->runtime == runtime
		&& body->handle != 0 && shape->handle != 0, 1, "Body and Shape must be live and belong to this Love state");
	const float density = static_cast<float>(luaL_optnumber(state, 3, 1.0));
	luaL_argcheck(state, std::isfinite(density) && density >= 0.0f, 3, "density must be finite and non-negative");
	std::string error;
	const auto handle = runtime->_physicsBackend->newFixture(body->handle, shape->handle, density, error);
	if (handle == 0) return luaL_error(state, "%s", error.empty() ? "failed to create Fixture" : error.c_str());
	auto *fixture = new PhysicsFixtureUserdata(runtime, handle, density);
	fixture->bodyObject.set(body);
	fixture->shapeObject.set(shape);
	pushNewDoraHandleObject(state, ::love::physics::Fixture::type, fixture);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	lua_pushvalue(state, -1);
	runtime->_physicsFixtureReferences[handle] = luaL_ref(state, LUA_REGISTRYINDEX);
	runtime->_physicsFixtureObjects[handle].set(fixture);
	return 1;
}

int LoveRuntime::physicsNewDistanceJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	const float x2 = static_cast<float>(luaL_checknumber(state, 5));
	const float y2 = static_cast<float>(luaL_checknumber(state, 6));
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 3, "anchor coordinates must be finite");
	bool collide = false;
	if (!lua_isnoneornil(state, 7))
	{
		luaL_checktype(state, 7, LUA_TBOOLEAN);
		collide = lua_toboolean(state, 7);
	}
	std::string error;
	const auto handle = runtime->_physicsBackend->newDistanceJoint(bodyA->handle, bodyB->handle,
		x1, y1, x2, y2, collide, error);
	if (handle == 0) return luaL_error(state, "%s", error.empty() ? "failed to create DistanceJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "distance");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	runtime->_physicsJointObjects[handle].set(joint);
	pushNewDoraHandleObject(state, ::love::physics::Joint::type, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	return 1;
}

int LoveRuntime::physicsNewRevoluteJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1), 3,
		"anchor coordinates must be finite");
	float x2 = x1;
	float y2 = y1;
	bool collide = false;
	bool hasReferenceAngle = false;
	float referenceAngle = 0.0f;
	const int argumentCount = lua_gettop(state);
	if (argumentCount >= 6)
	{
		x2 = static_cast<float>(luaL_checknumber(state, 5));
		y2 = static_cast<float>(luaL_checknumber(state, 6));
		luaL_argcheck(state, std::isfinite(x2) && std::isfinite(y2), 5,
			"anchor coordinates must be finite");
		if (argumentCount >= 7 && !lua_isnil(state, 7))
		{
			luaL_checktype(state, 7, LUA_TBOOLEAN);
			collide = lua_toboolean(state, 7);
		}
		if (argumentCount >= 8 && !lua_isnil(state, 8))
		{
			hasReferenceAngle = true;
			referenceAngle = static_cast<float>(luaL_checknumber(state, 8));
			luaL_argcheck(state, std::isfinite(referenceAngle), 8,
				"reference angle must be finite");
		}
	}
	else if (argumentCount >= 5 && !lua_isnil(state, 5))
	{
		luaL_checktype(state, 5, LUA_TBOOLEAN);
		collide = lua_toboolean(state, 5);
	}
	std::string error;
	const auto handle = runtime->_physicsBackend->newRevoluteJoint(bodyA->handle, bodyB->handle,
		x1, y1, x2, y2, collide, hasReferenceAngle, referenceAngle, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "failed to create RevoluteJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "revolute");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	runtime->_physicsJointObjects[handle].set(joint);
	pushNewDoraHandleObject(state, ::love::physics::Joint::type, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewPrismaticJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	float x2 = x1, y2 = y1, axisX = 0.0f, axisY = 0.0f;
	bool collide = false, hasReferenceAngle = false;
	float referenceAngle = 0.0f;
	const int argumentCount = lua_gettop(state);
	if (argumentCount >= 8)
	{
		x2 = static_cast<float>(luaL_checknumber(state, 5));
		y2 = static_cast<float>(luaL_checknumber(state, 6));
		axisX = static_cast<float>(luaL_checknumber(state, 7));
		axisY = static_cast<float>(luaL_checknumber(state, 8));
		if (argumentCount >= 9 && !lua_isnil(state, 9))
		{
			luaL_checktype(state, 9, LUA_TBOOLEAN);
			collide = lua_toboolean(state, 9);
		}
		if (argumentCount >= 10 && !lua_isnil(state, 10))
		{
			hasReferenceAngle = true;
			referenceAngle = static_cast<float>(luaL_checknumber(state, 10));
			luaL_argcheck(state, std::isfinite(referenceAngle), 10,
				"reference angle must be finite");
		}
	}
	else
	{
		axisX = static_cast<float>(luaL_checknumber(state, 5));
		axisY = static_cast<float>(luaL_checknumber(state, 6));
		if (argumentCount >= 7 && !lua_isnil(state, 7))
		{
			luaL_checktype(state, 7, LUA_TBOOLEAN);
			collide = lua_toboolean(state, 7);
		}
	}
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 3, "anchor coordinates must be finite");
	luaL_argcheck(state, std::isfinite(axisX) && std::isfinite(axisY)
		&& axisX * axisX + axisY * axisY > 0.0f, argumentCount >= 8 ? 7 : 5,
		"axis must be finite and non-zero");
	std::string error;
	const auto handle = runtime->_physicsBackend->newPrismaticJoint(
		bodyA->handle, bodyB->handle, x1, y1, x2, y2, axisX, axisY,
		collide, hasReferenceAngle, referenceAngle, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "failed to create PrismaticJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "prismatic");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	runtime->_physicsJointObjects[handle].set(joint);
	pushNewDoraHandleObject(state, ::love::physics::Joint::type, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewWeldJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	float x2 = x1, y2 = y1;
	bool collide = false, hasReferenceAngle = false;
	float referenceAngle = 0.0f;
	const int argumentCount = lua_gettop(state);
	if (argumentCount >= 6)
	{
		x2 = static_cast<float>(luaL_checknumber(state, 5));
		y2 = static_cast<float>(luaL_checknumber(state, 6));
		if (argumentCount >= 7 && !lua_isnil(state, 7))
		{
			luaL_checktype(state, 7, LUA_TBOOLEAN);
			collide = lua_toboolean(state, 7);
		}
		if (argumentCount >= 8 && !lua_isnil(state, 8))
		{
			hasReferenceAngle = true;
			referenceAngle = static_cast<float>(luaL_checknumber(state, 8));
			luaL_argcheck(state, std::isfinite(referenceAngle), 8,
				"reference angle must be finite");
		}
	}
	else if (argumentCount >= 5 && !lua_isnil(state, 5))
	{
		luaL_checktype(state, 5, LUA_TBOOLEAN);
		collide = lua_toboolean(state, 5);
	}
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 3, "anchor coordinates must be finite");
	std::string error;
	const auto handle = runtime->_physicsBackend->newWeldJoint(bodyA->handle, bodyB->handle,
		x1, y1, x2, y2, collide, hasReferenceAngle, referenceAngle, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "failed to create WeldJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "weld");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	runtime->_physicsJointObjects[handle].set(joint);
	pushNewDoraHandleObject(state, ::love::physics::Joint::type, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewFrictionJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	float x2 = x1, y2 = y1;
	bool collide = false;
	const int argumentCount = lua_gettop(state);
	if (argumentCount >= 6)
	{
		x2 = static_cast<float>(luaL_checknumber(state, 5));
		y2 = static_cast<float>(luaL_checknumber(state, 6));
		if (argumentCount >= 7 && !lua_isnil(state, 7))
		{
			luaL_checktype(state, 7, LUA_TBOOLEAN);
			collide = lua_toboolean(state, 7);
		}
	}
	else if (argumentCount >= 5 && !lua_isnil(state, 5))
	{
		luaL_checktype(state, 5, LUA_TBOOLEAN);
		collide = lua_toboolean(state, 5);
	}
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 3, "anchor coordinates must be finite");
	std::string error;
	const auto handle = runtime->_physicsBackend->newFrictionJoint(bodyA->handle, bodyB->handle,
		x1, y1, x2, y2, collide, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "failed to create FrictionJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "friction");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	runtime->_physicsJointObjects[handle].set(joint);
	pushNewDoraHandleObject(state, ::love::physics::Joint::type, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewRopeJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	const float x2 = static_cast<float>(luaL_checknumber(state, 5));
	const float y2 = static_cast<float>(luaL_checknumber(state, 6));
	const float maxLength = static_cast<float>(luaL_checknumber(state, 7));
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 3, "anchor coordinates must be finite");
	luaL_argcheck(state, std::isfinite(maxLength) && maxLength >= 0.0f, 7,
		"maximum length must be finite and non-negative");
	bool collide = false;
	if (!lua_isnoneornil(state, 8))
	{
		luaL_checktype(state, 8, LUA_TBOOLEAN);
		collide = lua_toboolean(state, 8);
	}
	std::string error;
	const auto handle = runtime->_physicsBackend->newRopeJoint(bodyA->handle, bodyB->handle,
		x1, y1, x2, y2, maxLength, collide, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "failed to create RopeJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "rope");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	runtime->_physicsJointObjects[handle].set(joint);
	pushNewDoraHandleObject(state, ::love::physics::Joint::type, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewPulleyJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1);
	auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	float values[9];
	for (int i = 0; i < 8; ++i)
	{
		values[i] = static_cast<float>(luaL_checknumber(state, i + 3));
		luaL_argcheck(state, std::isfinite(values[i]), i + 3,
			"anchor coordinates must be finite");
	}
	values[8] = static_cast<float>(luaL_optnumber(state, 11, 1.0));
	luaL_argcheck(state, std::isfinite(values[8]) && values[8] > 0.0f, 11,
		"ratio must be finite and positive");
	bool collide = true;
	if (!lua_isnoneornil(state, 12))
	{
		luaL_checktype(state, 12, LUA_TBOOLEAN);
		collide = lua_toboolean(state, 12);
	}
	std::string error;
	const auto handle = runtime->_physicsBackend->newPulleyJoint(bodyA->handle, bodyB->handle,
		values[0], values[1], values[2], values[3], values[4], values[5],
		values[6], values[7], values[8], collide, error);
	if (handle == 0)
		return luaL_error(state, "%s", error.empty() ? "failed to create PulleyJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "pulley");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	runtime->_physicsJointObjects[handle].set(joint);
	pushNewDoraHandleObject(state, ::love::physics::Joint::type, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewWheelJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1); auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	const float x1 = static_cast<float>(luaL_checknumber(state, 3));
	const float y1 = static_cast<float>(luaL_checknumber(state, 4));
	float x2 = x1, y2 = y1, axisX = 0, axisY = 0; bool collide = false;
	if (lua_gettop(state) >= 8)
	{
		x2 = static_cast<float>(luaL_checknumber(state, 5));
		y2 = static_cast<float>(luaL_checknumber(state, 6));
		axisX = static_cast<float>(luaL_checknumber(state, 7));
		axisY = static_cast<float>(luaL_checknumber(state, 8));
		if (!lua_isnoneornil(state, 9)) { luaL_checktype(state, 9, LUA_TBOOLEAN); collide = lua_toboolean(state, 9); }
	}
	else
	{
		axisX = static_cast<float>(luaL_checknumber(state, 5));
		axisY = static_cast<float>(luaL_checknumber(state, 6));
		if (!lua_isnoneornil(state, 7)) { luaL_checktype(state, 7, LUA_TBOOLEAN); collide = lua_toboolean(state, 7); }
	}
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 3, "anchor coordinates must be finite");
	luaL_argcheck(state, std::isfinite(axisX) && std::isfinite(axisY)
		&& axisX * axisX + axisY * axisY > 0.0f, 5, "axis must be finite and non-zero");
	std::string error;
	const auto handle = runtime->_physicsBackend->newWheelJoint(bodyA->handle, bodyB->handle,
		x1, y1, x2, y2, axisX, axisY, collide, error);
	if (!handle) return luaL_error(state, "%s", error.empty() ? "failed to create WheelJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "wheel");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	runtime->_physicsJointObjects[handle].set(joint);
	pushNewDoraHandleObject(state, ::love::physics::Joint::type, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1); lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3); return 1;
}

int LoveRuntime::physicsNewMouseJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *body = checkPhysicsBody(state, 1);
	luaL_argcheck(state, body->runtime == runtime && body->handle != 0,
		1, "Body must be live and belong to this Love state");
	luaL_argcheck(state, body->type != "kinematic", 1,
		"Cannot create a MouseJoint for a kinematic Body");
	const float x = static_cast<float>(luaL_checknumber(state, 2));
	const float y = static_cast<float>(luaL_checknumber(state, 3));
	luaL_argcheck(state, std::isfinite(x) && std::isfinite(y), 2,
		"target coordinates must be finite");
	std::string error;
	const auto handle = runtime->_physicsBackend->newMouseJoint(body->handle, x, y, error);
	if (!handle) return luaL_error(state, "%s",
		error.empty() ? "failed to create MouseJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "mouse");
	joint->bodyAObject.set(body);
	runtime->_physicsJointObjects[handle].set(joint);
	pushNewDoraHandleObject(state, ::love::physics::Joint::type, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushnil(state); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewMotorJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *bodyA = checkPhysicsBody(state, 1); auto *bodyB = checkPhysicsBody(state, 2);
	luaL_argcheck(state, bodyA->runtime == runtime && bodyB->runtime == runtime
		&& bodyA->handle != 0 && bodyB->handle != 0 && bodyA->world == bodyB->world,
		1, "Bodies must be live and belong to the same World and Love state");
	float correctionFactor = 0.3f; bool collideConnected = false;
	if (!lua_isnoneornil(state, 3))
	{
		correctionFactor = static_cast<float>(luaL_checknumber(state, 3));
		luaL_argcheck(state, std::isfinite(correctionFactor)
			&& correctionFactor >= 0.0f && correctionFactor <= 1.0f, 3,
			"correction factor must be finite and between 0 and 1");
		if (!lua_isnoneornil(state, 4))
		{
			luaL_checktype(state, 4, LUA_TBOOLEAN);
			collideConnected = lua_toboolean(state, 4);
		}
	}
	std::string error;
	const auto handle = runtime->_physicsBackend->newMotorJoint(bodyA->handle, bodyB->handle,
		correctionFactor, collideConnected, error);
	if (!handle) return luaL_error(state, "%s",
		error.empty() ? "failed to create MotorJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "motor");
	joint->bodyAObject.set(bodyA); joint->bodyBObject.set(bodyB);
	runtime->_physicsJointObjects[handle].set(joint);
	pushNewDoraHandleObject(state, ::love::physics::Joint::type, joint);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 1);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	return 1;
}

int LoveRuntime::physicsNewGearJoint(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	auto *jointA = checkPhysicsJoint(state, 1); auto *jointB = checkPhysicsJoint(state, 2);
	luaL_argcheck(state, jointA->runtime == runtime && jointB->runtime == runtime
		&& jointA->handle != 0 && jointB->handle != 0
		&& runtime->_physicsBackend->isJointValid(jointA->handle)
		&& runtime->_physicsBackend->isJointValid(jointB->handle), 1,
		"Joints must be live and belong to this Love state");
	luaL_argcheck(state, jointA->handle != jointB->handle, 2,
		"GearJoint requires two distinct source Joints");
	luaL_argcheck(state, jointA->type == "revolute" || jointA->type == "prismatic", 1,
		"GearJoint source must be a RevoluteJoint or PrismaticJoint");
	luaL_argcheck(state, jointB->type == "revolute" || jointB->type == "prismatic", 2,
		"GearJoint source must be a RevoluteJoint or PrismaticJoint");
	const float ratio = static_cast<float>(luaL_optnumber(state, 3, 1.0));
	luaL_argcheck(state, std::isfinite(ratio), 3, "ratio must be finite");
	bool collideConnected = false;
	if (!lua_isnoneornil(state, 4))
	{
		luaL_checktype(state, 4, LUA_TBOOLEAN);
		collideConnected = lua_toboolean(state, 4);
	}
	std::string error;
	const auto handle = runtime->_physicsBackend->newGearJoint(jointA->handle, jointB->handle,
		ratio, collideConnected, error);
	if (!handle) return luaL_error(state, "%s",
		error.empty() ? "failed to create GearJoint" : error.c_str());
	auto *joint = new PhysicsJointUserdata(runtime, handle, "gear");
	joint->jointAObject.set(jointA); joint->jointBObject.set(jointB);
	joint->bodyAObject = jointA->bodyBObject; joint->bodyBObject = jointB->bodyBObject;
	runtime->_physicsJointObjects[handle].set(joint);
	pushNewDoraHandleObject(state, ::love::physics::Joint::type, joint);
	lua_getiuservalue(state, 1, 2); lua_setiuservalue(state, -2, 1);
	lua_getiuservalue(state, 2, 2); lua_setiuservalue(state, -2, 2);
	lua_pushnil(state); lua_setiuservalue(state, -2, 3);
	lua_pushvalue(state, 1); lua_setiuservalue(state, -2, 4);
	lua_pushvalue(state, 2); lua_setiuservalue(state, -2, 5);
	return 1;
}

int LoveRuntime::physicsWorldDestroy(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	if (world->runtime && world->handle)
	{
		const auto callbacks = world->runtime->_physicsWorldCallbacks.find(world->handle);
		if (callbacks != world->runtime->_physicsWorldCallbacks.end())
		{
			for (const int reference : {callbacks->second.begin, callbacks->second.end,
				callbacks->second.preSolve, callbacks->second.postSolve})
				if (reference != LUA_NOREF) luaL_unref(state, LUA_REGISTRYINDEX, reference);
			world->runtime->_physicsWorldCallbacks.erase(callbacks);
		}
		for (auto contact = world->runtime->_physicsContactReferences.begin();
			contact != world->runtime->_physicsContactReferences.end();)
		{
			auto object = world->runtime->_physicsContactObjects.find(contact->first);
			auto *userdata = object == world->runtime->_physicsContactObjects.end() ? nullptr
				: static_cast<PhysicsContactUserdata *>(object->second.get());
			const bool belongs = userdata && userdata->world == world->handle;
			if (belongs) userdata->handle = 0;
			if (belongs)
			{
				luaL_unref(state, LUA_REGISTRYINDEX, contact->second);
				world->runtime->_physicsContactObjects.erase(contact->first);
				contact = world->runtime->_physicsContactReferences.erase(contact);
			}
			else ++contact;
		}
	}
	if (world->runtime && world->runtime->_physicsBackend && world->handle)
	{
		world->releaseDoraHandle();
		for (auto fixture = world->runtime->_physicsFixtureReferences.begin();
			fixture != world->runtime->_physicsFixtureReferences.end();)
		{
			if (world->runtime->_physicsBackend->isFixtureValid(fixture->first)) { ++fixture; continue; }
			if (auto object = world->runtime->_physicsFixtureObjects.find(fixture->first);
				object != world->runtime->_physicsFixtureObjects.end())
				static_cast<PhysicsFixtureUserdata *>(object->second.get())->invalidateDoraHandle();
			luaL_unref(state, LUA_REGISTRYINDEX, fixture->second);
			world->runtime->_physicsFixtureObjects.erase(fixture->first);
			fixture = world->runtime->_physicsFixtureReferences.erase(fixture);
		}
	}
	world->invalidateDoraHandle();
	return 0;
}

int LoveRuntime::physicsWorldIsDestroyed(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	lua_pushboolean(state, !world->runtime || !world->runtime->_physicsBackend || !world->handle
		|| !world->runtime->_physicsBackend->isWorldValid(world->handle));
	return 1;
}

int LoveRuntime::physicsWorldUpdate(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	const float dt = static_cast<float>(luaL_checknumber(state, 2));
	const int velocity = static_cast<int>(luaL_optinteger(state, 3, 8));
	const int position = static_cast<int>(luaL_optinteger(state, 4, 3));
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle, 1, "World is destroyed");
	luaL_argcheck(state, std::isfinite(dt) && dt >= 0.0f, 2, "delta time must be finite and non-negative");
	luaL_argcheck(state, velocity > 0, 3, "velocity iterations must be positive");
	luaL_argcheck(state, position > 0, 4, "position iterations must be positive");
	std::string error;
	auto *runtime = world->runtime;
	const auto worldHandle = world->handle;
	const bool updated = runtime->_physicsBackend->updateWorld(worldHandle, dt, velocity, position, error);
	for (auto fixture = runtime->_physicsFixtureReferences.begin();
		fixture != runtime->_physicsFixtureReferences.end();)
	{
		if (runtime->_physicsBackend->isFixtureValid(fixture->first)) { ++fixture; continue; }
		if (auto object = runtime->_physicsFixtureObjects.find(fixture->first);
			object != runtime->_physicsFixtureObjects.end())
			static_cast<PhysicsFixtureUserdata *>(object->second.get())->invalidateDoraHandle();
		luaL_unref(state, LUA_REGISTRYINDEX, fixture->second);
		runtime->_physicsFixtureObjects.erase(fixture->first);
		fixture = runtime->_physicsFixtureReferences.erase(fixture);
	}
	if (!runtime->_physicsBackend->isWorldValid(worldHandle)) world->invalidateDoraHandle();
	if (!updated)
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsWorldSetGravity(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1); float x = static_cast<float>(luaL_checknumber(state, 2));
	float y = static_cast<float>(luaL_checknumber(state, 3)); std::string error;
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle, 1, "World is destroyed");
	if (!world->runtime->_physicsBackend->setWorldGravity(world->handle, x, y, error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsWorldGetGravity(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1); float x = 0.0f, y = 0.0f; std::string error;
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle, 1, "World is destroyed");
	if (!world->runtime->_physicsBackend->getWorldGravity(world->handle, x, y, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushnumber(state, x); lua_pushnumber(state, y); return 2;
}

int LoveRuntime::physicsWorldSetSleepingAllowed(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1); std::string error;
	if (!world->runtime || !world->runtime->_physicsBackend || !world->handle) return luaL_error(state, "World is destroyed");
	if (!world->runtime->_physicsBackend->setWorldSleepingAllowed(world->handle, lua_toboolean(state, 2), error)) return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsWorldIsSleepingAllowed(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1); bool value = false; std::string error;
	if (!world->runtime || !world->runtime->_physicsBackend || !world->handle) return luaL_error(state, "World is destroyed");
	if (!world->runtime->_physicsBackend->isWorldSleepingAllowed(world->handle, value, error)) return luaL_error(state, "%s", error.c_str());
	lua_pushboolean(state, value); return 1;
}

int LoveRuntime::physicsWorldQueryBoundingBox(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	luaL_checktype(state, 6, LUA_TFUNCTION);
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle, 1, "World is destroyed");
	const float x1 = static_cast<float>(luaL_checknumber(state, 2));
	const float y1 = static_cast<float>(luaL_checknumber(state, 3));
	const float x2 = static_cast<float>(luaL_checknumber(state, 4));
	const float y2 = static_cast<float>(luaL_checknumber(state, 5));
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 2, "query bounds must be finite");
	std::vector<PhysicsBackend::FixtureHandle> fixtures;
	std::string error;
	if (!world->runtime->_physicsBackend->queryWorld(world->handle, x1, y1, x2, y2, fixtures, error))
		return luaL_error(state, "%s", error.c_str());
	for (const auto handle : fixtures)
	{
		const auto found = world->runtime->_physicsFixtureReferences.find(handle);
		const auto object = world->runtime->_physicsFixtureObjects.find(handle);
		if (found == world->runtime->_physicsFixtureReferences.end()
			|| object == world->runtime->_physicsFixtureObjects.end()) continue;
		lua_pushvalue(state, 6);
		::love::luax_pushtype(state, ::love::physics::Fixture::type,
			static_cast<PhysicsFixtureUserdata *>(object->second.get()));
		if (lua_pcall(state, 1, 1, 0) != LUA_OK) return lua_error(state);
		const bool keepGoing = lua_toboolean(state, -1);
		lua_pop(state, 1);
		if (!keepGoing) break;
	}
	return 0;
}

int LoveRuntime::physicsWorldRayCast(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	luaL_checktype(state, 6, LUA_TFUNCTION);
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle, 1, "World is destroyed");
	const float x1 = static_cast<float>(luaL_checknumber(state, 2));
	const float y1 = static_cast<float>(luaL_checknumber(state, 3));
	const float x2 = static_cast<float>(luaL_checknumber(state, 4));
	const float y2 = static_cast<float>(luaL_checknumber(state, 5));
	luaL_argcheck(state, std::isfinite(x1) && std::isfinite(y1)
		&& std::isfinite(x2) && std::isfinite(y2), 2, "ray endpoints must be finite");
	std::vector<PhysicsBackend::RayHit> hits;
	std::string error;
	if (!world->runtime->_physicsBackend->raycastWorld(world->handle, x1, y1, x2, y2, hits, error))
		return luaL_error(state, "%s", error.c_str());
	float maximumFraction = 1.0f;
	for (const auto &hit : hits)
	{
		if (hit.fraction > maximumFraction) continue;
		const auto found = world->runtime->_physicsFixtureReferences.find(hit.fixture);
		const auto object = world->runtime->_physicsFixtureObjects.find(hit.fixture);
		if (found == world->runtime->_physicsFixtureReferences.end()
			|| object == world->runtime->_physicsFixtureObjects.end()) continue;
		lua_pushvalue(state, 6);
		::love::luax_pushtype(state, ::love::physics::Fixture::type,
			static_cast<PhysicsFixtureUserdata *>(object->second.get()));
		lua_pushnumber(state, hit.x); lua_pushnumber(state, hit.y);
		lua_pushnumber(state, hit.normalX); lua_pushnumber(state, hit.normalY);
		lua_pushnumber(state, hit.fraction);
		if (lua_pcall(state, 6, 1, 0) != LUA_OK) return lua_error(state);
		const float result = static_cast<float>(luaL_checknumber(state, -1));
		lua_pop(state, 1);
		if (!std::isfinite(result) || result < -1.0f || result > 1.0f)
			return luaL_error(state, "rayCast callback must return a finite value between -1 and 1");
		if (result == 0.0f) break;
		if (result > 0.0f) maximumFraction = std::min(maximumFraction, result);
	}
	return 0;
}

int LoveRuntime::physicsWorldSetCallbacks(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle,
		1, "World is destroyed");
	for (int index = 2; index <= 5; ++index)
		if (!lua_isnoneornil(state, index)) luaL_checktype(state, index, LUA_TFUNCTION);
	auto *runtime = world->runtime;
	auto &callbacks = runtime->_physicsWorldCallbacks[world->handle];
	for (int *reference : {&callbacks.begin, &callbacks.end, &callbacks.preSolve, &callbacks.postSolve})
	{
		if (*reference != LUA_NOREF) luaL_unref(state, LUA_REGISTRYINDEX, *reference);
		*reference = LUA_NOREF;
	}
	int *references[] = {&callbacks.begin, &callbacks.end, &callbacks.preSolve, &callbacks.postSolve};
	for (int index = 0; index < 4; ++index)
	{
		if (lua_isnoneornil(state, index + 2)) continue;
		lua_pushvalue(state, index + 2);
		*references[index] = luaL_ref(state, LUA_REGISTRYINDEX);
	}
	const auto worldHandle = world->handle;
	std::string error;
	if (!runtime->_physicsBackend->setWorldContactCallback(worldHandle,
		[runtime, worldHandle](const PhysicsBackend::ContactEvent &event, std::string &callbackError) {
			auto callbacksFound = runtime->_physicsWorldCallbacks.find(worldHandle);
			if (callbacksFound == runtime->_physicsWorldCallbacks.end() || !runtime->_state)
			{
				callbackError = "Love physics World callback state is closed";
				return false;
			}
			auto invalidateContact = [&]() {
				const auto contactFound = runtime->_physicsContactReferences.find(event.contact);
				if (contactFound == runtime->_physicsContactReferences.end()) return;
				if (auto object = runtime->_physicsContactObjects.find(event.contact);
					object != runtime->_physicsContactObjects.end())
					static_cast<PhysicsContactUserdata *>(object->second.get())->handle = 0;
				luaL_unref(runtime->_state, LUA_REGISTRYINDEX, contactFound->second);
				runtime->_physicsContactReferences.erase(contactFound);
				runtime->_physicsContactObjects.erase(event.contact);
			};
			const auto &callbacks = callbacksFound->second;
			const int reference = event.phase == PhysicsBackend::ContactPhase::Begin ? callbacks.begin
				: event.phase == PhysicsBackend::ContactPhase::End ? callbacks.end
				: event.phase == PhysicsBackend::ContactPhase::PreSolve ? callbacks.preSolve
				: callbacks.postSolve;
			if (reference == LUA_NOREF)
			{
				if (event.phase == PhysicsBackend::ContactPhase::End) invalidateContact();
				return true;
			}
			const auto fixtureA = runtime->_physicsFixtureReferences.find(event.fixtureA);
			const auto fixtureB = runtime->_physicsFixtureReferences.find(event.fixtureB);
			const auto fixtureAObject = runtime->_physicsFixtureObjects.find(event.fixtureA);
			const auto fixtureBObject = runtime->_physicsFixtureObjects.find(event.fixtureB);
			if (fixtureA == runtime->_physicsFixtureReferences.end()
				|| fixtureB == runtime->_physicsFixtureReferences.end()
				|| fixtureAObject == runtime->_physicsFixtureObjects.end()
				|| fixtureBObject == runtime->_physicsFixtureObjects.end())
			{
				callbackError = "Love physics contact references a closed Fixture";
				if (event.phase == PhysicsBackend::ContactPhase::End) invalidateContact();
				return false;
			}
			lua_rawgeti(runtime->_state, LUA_REGISTRYINDEX, reference);
			::love::luax_pushtype(runtime->_state, ::love::physics::Fixture::type,
				static_cast<PhysicsFixtureUserdata *>(fixtureAObject->second.get()));
			::love::luax_pushtype(runtime->_state, ::love::physics::Fixture::type,
				static_cast<PhysicsFixtureUserdata *>(fixtureBObject->second.get()));
			auto contactFound = runtime->_physicsContactReferences.find(event.contact);
			if (contactFound == runtime->_physicsContactReferences.end())
			{
				auto *contact = new PhysicsContactUserdata(runtime, event.contact, worldHandle,
					event.fixtureA, event.fixtureB, event.childA, event.childB);
				contact->fixtureAObject.set(static_cast<PhysicsFixtureUserdata *>(
					fixtureAObject->second.get()));
				contact->fixtureBObject.set(static_cast<PhysicsFixtureUserdata *>(
					fixtureBObject->second.get()));
				::love::luax_pushtype(runtime->_state, ::love::physics::Contact::type, contact);
				contact->release();
				lua_pushvalue(runtime->_state, -1);
				const int contactReference = luaL_ref(runtime->_state, LUA_REGISTRYINDEX);
				runtime->_physicsContactReferences.emplace(event.contact, contactReference);
				runtime->_physicsContactObjects[event.contact].set(contact);
			}
			else
			{
				if (auto object = runtime->_physicsContactObjects.find(event.contact);
					object != runtime->_physicsContactObjects.end())
				{
					auto *contact = static_cast<PhysicsContactUserdata *>(object->second.get());
					contact->fixtureA = event.fixtureA;
					contact->fixtureB = event.fixtureB;
					contact->childA = event.childA;
					contact->childB = event.childB;
					::love::luax_pushtype(runtime->_state, ::love::physics::Contact::type, contact);
				}
			}
			for (const float impulse : event.impulses) lua_pushnumber(runtime->_state, impulse);
			const int argumentCount = 3 + static_cast<int>(event.impulses.size());
			if (lua_pcall(runtime->_state, argumentCount, 0, 0) != LUA_OK)
			{
				const char *message = lua_tostring(runtime->_state, -1);
				callbackError = message ? message : "Love physics contact callback failed";
				lua_pop(runtime->_state, 1);
				if (event.phase == PhysicsBackend::ContactPhase::End) invalidateContact();
				return false;
			}
			if (event.phase == PhysicsBackend::ContactPhase::End) invalidateContact();
			callbackError.clear();
			return true;
		}, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::physicsWorldGetCallbacks(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	luaL_argcheck(state, world->runtime && world->handle, 1, "World is destroyed");
	const auto found = world->runtime->_physicsWorldCallbacks.find(world->handle);
	const PhysicsWorldCallbacks empty;
	const auto &callbacks = found == world->runtime->_physicsWorldCallbacks.end() ? empty : found->second;
	for (const int reference : {callbacks.begin, callbacks.end, callbacks.preSolve, callbacks.postSolve})
	{
		if (reference == LUA_NOREF) lua_pushnil(state);
		else lua_rawgeti(state, LUA_REGISTRYINDEX, reference);
	}
	return 4;
}

int LoveRuntime::physicsWorldGetBodies(lua_State *state)
{
	auto *world = checkPhysicsWorld(state, 1);
	luaL_argcheck(state, world->runtime && world->runtime->_physicsBackend && world->handle,
		1, "World is destroyed");
	lua_getiuservalue(state, 1, 1);
	if (!lua_istable(state, -1))
	{
		lua_pop(state, 1);
		lua_newtable(state);
		return 1;
	}
	lua_newtable(state);
	int output = 1;
	const auto count = static_cast<lua_Integer>(lua_rawlen(state, -2));
	for (lua_Integer index = 1; index <= count; ++index)
	{
		lua_geti(state, -2, index);
		auto *body = luaL_testudata(state, -1, ::love::physics::Body::type.getName())
			? ::love::luax_checktype<PhysicsBodyUserdata>(state, -1, ::love::physics::Body::type) : nullptr;
		if (body && body->runtime == world->runtime && body->world == world->handle
			&& body->handle && world->runtime->_physicsBackend->isBodyValid(body->handle))
			lua_seti(state, -2, output++);
		else lua_pop(state, 1);
	}
	lua_remove(state, -2);
	return 1;
}

static void requirePhysicsResult(bool result, const std::string &error);

bool PhysicsWorldUserdata::isDestroyed() const
{
	auto *backend = runtime ? runtime->getPhysicsBackend() : nullptr;
	return !backend || !handle || !backend->isWorldValid(handle);
}

void PhysicsWorldUserdata::update(float dt) { update(dt, 8, 3); }
void PhysicsWorldUserdata::update(float dt, int velocityIterations, int positionIterations)
{
	if (!std::isfinite(dt) || dt < 0.0f) throw ::love::Exception("delta time must be finite and non-negative");
	if (velocityIterations <= 0 || positionIterations <= 0)
		throw ::love::Exception("physics iteration counts must be positive");
	auto *backend = runtime ? runtime->getPhysicsBackend() : nullptr;
	if (!backend || !handle || !backend->isWorldValid(handle)) throw ::love::Exception("World is destroyed");
	const auto worldHandle = handle;
	std::string error;
	updating = true;
	bool updated = false;
	try
	{
		updated = backend->updateWorld(worldHandle, dt, velocityIterations, positionIterations, error);
	}
	catch (...)
	{
		updating = false;
		throw;
	}
	updating = false;
	runtime->cleanupInvalidPhysicsFixtures(runtime->getState());
	runtime->cleanupInvalidPhysicsJoints();
	runtime->cleanupInvalidPhysicsBodies();
	if (!backend->isWorldValid(worldHandle)) invalidateDoraHandle();
	if (!updated) throw ::love::Exception("%s", error.c_str());
}

int PhysicsWorldUserdata::setCallbacks(lua_State *L)
{
	return runtime->callPhysicsWorldCallbacks(this, L, true);
}
int PhysicsWorldUserdata::getCallbacks(lua_State *L)
{
	return runtime->callPhysicsWorldCallbacks(this, L, false);
}
void PhysicsWorldUserdata::setGravity(float x, float y)
{
	if (!std::isfinite(x) || !std::isfinite(y)) throw ::love::Exception("gravity must be finite");
	std::string error;
	requirePhysicsResult(runtime && runtime->getPhysicsBackend() && handle
		&& runtime->getPhysicsBackend()->setWorldGravity(handle, x, y, error), error);
}
int PhysicsWorldUserdata::getGravity(lua_State *L)
{
	float x = 0.0f, y = 0.0f; std::string error;
	requirePhysicsResult(runtime && runtime->getPhysicsBackend() && handle
		&& runtime->getPhysicsBackend()->getWorldGravity(handle, x, y, error), error);
	lua_pushnumber(L, x); lua_pushnumber(L, y); return 2;
}
void PhysicsWorldUserdata::translateOrigin(float x, float y)
{
	if (!std::isfinite(x) || !std::isfinite(y)) throw ::love::Exception("origin offset must be finite");
	if (isDestroyed()) throw ::love::Exception("World is destroyed");
	runtime->translatePhysicsWorldOrigin(handle, x, y);
}
void PhysicsWorldUserdata::setSleepingAllowed(bool allow)
{
	std::string error;
	requirePhysicsResult(runtime && runtime->getPhysicsBackend() && handle
		&& runtime->getPhysicsBackend()->setWorldSleepingAllowed(handle, allow, error), error);
}
bool PhysicsWorldUserdata::isSleepingAllowed() const
{
	bool result = false; std::string error;
	requirePhysicsResult(runtime && runtime->getPhysicsBackend() && handle
		&& runtime->getPhysicsBackend()->isWorldSleepingAllowed(handle, result, error), error);
	return result;
}
int PhysicsWorldUserdata::getBodyCount() const
{
	return runtime->countPhysicsWorldBodies(handle);
}
int PhysicsWorldUserdata::getJointCount() const
{
	return runtime->countPhysicsWorldJoints(handle);
}
int PhysicsWorldUserdata::getContactCount() const
{
	return runtime->countPhysicsWorldContacts(handle);
}
int PhysicsWorldUserdata::getBodies(lua_State *L) const
{
	return runtime->pushPhysicsWorldBodies(handle, L);
}
int PhysicsWorldUserdata::getJoints(lua_State *L) const
{
	return runtime->pushPhysicsWorldJoints(handle, L);
}
int PhysicsWorldUserdata::getContacts(lua_State *L)
{
	return runtime->pushPhysicsWorldContacts(handle, L);
}
int PhysicsWorldUserdata::queryBoundingBox(lua_State *L)
{
	return runtime->callPhysicsWorldQuery(this, L, false);
}
int PhysicsWorldUserdata::rayCast(lua_State *L)
{
	return runtime->callPhysicsWorldQuery(this, L, true);
}
void PhysicsWorldUserdata::destroy()
{
	runtime->destroyPhysicsWorldObject(runtime->getState());
}

static PhysicsBackend *requirePhysicsBodyBackend(const PhysicsBodyUserdata *body)
{
	auto *backend = body && body->runtime ? body->runtime->getPhysicsBackend() : nullptr;
	if (!backend || !body->handle || !backend->isBodyValid(body->handle))
		throw ::love::Exception("Body is destroyed");
	return backend;
}

static void requirePhysicsResult(bool result, const std::string &error)
{
	if (!result) throw ::love::Exception("%s", error.empty() ? "Dora physics backend rejected the operation" : error.c_str());
}

bool PhysicsBodyUserdata::isDestroyed() const
{
	auto *backend = runtime ? runtime->getPhysicsBackend() : nullptr;
	return !backend || !handle || !backend->isBodyValid(handle);
}

void PhysicsBodyUserdata::getPosition(float &x, float &y)
{
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->getBodyPosition(handle, x, y, error), error);
}
float PhysicsBodyUserdata::getX() { float x, y; getPosition(x, y); return x; }
float PhysicsBodyUserdata::getY() { float x, y; getPosition(x, y); return y; }
float PhysicsBodyUserdata::getAngle()
{
	float value = 0.0f; std::string error;
	requirePhysicsResult(requirePhysicsBodyBackend(this)->getBodyAngle(handle, value, error), error); return value;
}
void PhysicsBodyUserdata::getLinearVelocity(float &x, float &y)
{
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->getBodyLinearVelocity(handle, x, y, error), error);
}
void PhysicsBodyUserdata::getWorldCenter(float &x, float &y)
{
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->getBodyCenter(handle, true, x, y, error), error);
}
void PhysicsBodyUserdata::getLocalCenter(float &x, float &y)
{
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->getBodyCenter(handle, false, x, y, error), error);
}

#define DORA_LOVE_BODY_GET_SCALAR(Method, BackendMethod) \
	float PhysicsBodyUserdata::Method() const { float value = 0.0f; std::string error; \
		requirePhysicsResult(requirePhysicsBodyBackend(this)->BackendMethod(handle, value, error), error); return value; }
DORA_LOVE_BODY_GET_SCALAR(getAngularVelocity, getBodyAngularVelocity)
DORA_LOVE_BODY_GET_SCALAR(getMass, getBodyMass)
DORA_LOVE_BODY_GET_SCALAR(getInertia, getBodyInertia)
DORA_LOVE_BODY_GET_SCALAR(getAngularDamping, getBodyAngularDamping)
DORA_LOVE_BODY_GET_SCALAR(getLinearDamping, getBodyLinearDamping)
DORA_LOVE_BODY_GET_SCALAR(getGravityScale, getBodyGravityScale)
#undef DORA_LOVE_BODY_GET_SCALAR

#define DORA_LOVE_BODY_SET_SCALAR(Method, BackendMethod) \
	void PhysicsBodyUserdata::Method(float value) { if (!std::isfinite(value)) throw ::love::Exception("Body value must be finite"); \
		std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->BackendMethod(handle, value, error), error); }
DORA_LOVE_BODY_SET_SCALAR(setAngle, setBodyAngle)
DORA_LOVE_BODY_SET_SCALAR(setAngularVelocity, setBodyAngularVelocity)
DORA_LOVE_BODY_SET_SCALAR(setMass, setBodyMass)
DORA_LOVE_BODY_SET_SCALAR(setInertia, setBodyInertia)
DORA_LOVE_BODY_SET_SCALAR(setAngularDamping, setBodyAngularDamping)
DORA_LOVE_BODY_SET_SCALAR(setLinearDamping, setBodyLinearDamping)
DORA_LOVE_BODY_SET_SCALAR(setGravityScale, setBodyGravityScale)
#undef DORA_LOVE_BODY_SET_SCALAR

void PhysicsBodyUserdata::setPosition(float x, float y)
{
	if (!std::isfinite(x) || !std::isfinite(y)) throw ::love::Exception("Body position must be finite");
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->setBodyPosition(handle, x, y, error), error);
}
void PhysicsBodyUserdata::setX(float x) { float oldX, y; getPosition(oldX, y); setPosition(x, y); }
void PhysicsBodyUserdata::setY(float y) { float x, oldY; getPosition(x, oldY); setPosition(x, y); }
void PhysicsBodyUserdata::setLinearVelocity(float x, float y)
{
	if (!std::isfinite(x) || !std::isfinite(y)) throw ::love::Exception("Body velocity must be finite");
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->setBodyLinearVelocity(handle, x, y, error), error);
}

int PhysicsBodyUserdata::getMassData(lua_State *L)
{
	float x = 0.0f, y = 0.0f, mass = 0.0f, inertia = 0.0f; std::string error;
	requirePhysicsResult(requirePhysicsBodyBackend(this)->getBodyMassData(handle, x, y, mass, inertia, error), error);
	lua_pushnumber(L, x); lua_pushnumber(L, y); lua_pushnumber(L, mass); lua_pushnumber(L, inertia); return 4;
}
void PhysicsBodyUserdata::setMassData(float x, float y, float mass, float inertia)
{
	if (!std::isfinite(x) || !std::isfinite(y) || !std::isfinite(mass) || !std::isfinite(inertia))
		throw ::love::Exception("Body mass data must be finite");
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->setBodyMassData(handle, x, y, mass, inertia, error), error);
}
void PhysicsBodyUserdata::resetMassData()
{
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->resetBodyMassData(handle, error), error);
}

::love::physics::Body::Type PhysicsBodyUserdata::getType() const
{
	Type result = BODY_INVALID; ::love::physics::Body::getConstant(type.c_str(), result); return result;
}
void PhysicsBodyUserdata::setType(Type value)
{
	const char *name = nullptr;
	if (!::love::physics::Body::getConstant(value, name)) throw ::love::Exception("Invalid Body type");
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->setBodyType(handle, name, error), error); type = name;
}

void PhysicsBodyUserdata::applyLinearImpulse(float x, float y, bool)
{
	float px, py; getPosition(px, py); applyLinearImpulse(x, y, px, py, true);
}
void PhysicsBodyUserdata::applyLinearImpulse(float x, float y, float px, float py, bool)
{
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->applyBodyLinearImpulse(handle, x, y, px, py, error), error);
}
void PhysicsBodyUserdata::applyAngularImpulse(float impulse, bool)
{
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->applyBodyAngularImpulse(handle, impulse, error), error);
}
void PhysicsBodyUserdata::applyTorque(float torque, bool)
{
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->applyBodyTorque(handle, torque, error), error);
}
void PhysicsBodyUserdata::applyForce(float x, float y, bool)
{
	float px, py; getWorldCenter(px, py); applyForce(x, y, px, py, true);
}
void PhysicsBodyUserdata::applyForce(float x, float y, float px, float py, bool)
{
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->applyBodyForce(handle, x, y, px, py, error), error);
}

static void transformPhysicsBodyValue(PhysicsBodyUserdata *body, bool toWorld, bool vector,
	float x, float y, float &outX, float &outY)
{
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(body)->transformBodyPoint(
		body->handle, toWorld, vector, x, y, outX, outY, error), error);
}
void PhysicsBodyUserdata::getWorldPoint(float x, float y, float &outX, float &outY) { transformPhysicsBodyValue(this, true, false, x, y, outX, outY); }
void PhysicsBodyUserdata::getWorldVector(float x, float y, float &outX, float &outY) { transformPhysicsBodyValue(this, true, true, x, y, outX, outY); }
void PhysicsBodyUserdata::getLocalPoint(float x, float y, float &outX, float &outY) { transformPhysicsBodyValue(this, false, false, x, y, outX, outY); }
void PhysicsBodyUserdata::getLocalVector(float x, float y, float &outX, float &outY) { transformPhysicsBodyValue(this, false, true, x, y, outX, outY); }
static int transformPhysicsBodyStack(PhysicsBodyUserdata *body, lua_State *L, bool toWorld)
{
	const int count = lua_gettop(L);
	if (count < 2 || count % 2 != 0)
		return luaL_error(L, "Expected one or more x, y pairs");
	for (int index = 0; index < count; index += 2)
	{
		const float x = static_cast<float>(luaL_checknumber(L, 1));
		const float y = static_cast<float>(luaL_checknumber(L, 2));
		lua_remove(L, 1); lua_remove(L, 1);
		float outX, outY; transformPhysicsBodyValue(body, toWorld, false, x, y, outX, outY);
		lua_pushnumber(L, outX); lua_pushnumber(L, outY);
	}
	return count;
}
int PhysicsBodyUserdata::getWorldPoints(lua_State *L) { return transformPhysicsBodyStack(this, L, true); }
int PhysicsBodyUserdata::getLocalPoints(lua_State *L) { return transformPhysicsBodyStack(this, L, false); }
void PhysicsBodyUserdata::getLinearVelocityFromWorldPoint(float x, float y, float &outX, float &outY)
{
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->getBodyPointVelocity(handle, false, x, y, outX, outY, error), error);
}
void PhysicsBodyUserdata::getLinearVelocityFromLocalPoint(float x, float y, float &outX, float &outY)
{
	std::string error; requirePhysicsResult(requirePhysicsBodyBackend(this)->getBodyPointVelocity(handle, true, x, y, outX, outY, error), error);
}

#define DORA_LOVE_BODY_GET_BOOL(Method, BackendMethod) \
	bool PhysicsBodyUserdata::Method() const { bool value = false; std::string error; \
		requirePhysicsResult(requirePhysicsBodyBackend(this)->BackendMethod(handle, value, error), error); return value; }
DORA_LOVE_BODY_GET_BOOL(isBullet, isBodyBullet)
DORA_LOVE_BODY_GET_BOOL(isActive, isBodyActive)
DORA_LOVE_BODY_GET_BOOL(isAwake, isBodyAwake)
DORA_LOVE_BODY_GET_BOOL(isSleepingAllowed, isBodySleepingAllowed)
DORA_LOVE_BODY_GET_BOOL(isFixedRotation, isBodyFixedRotation)
#undef DORA_LOVE_BODY_GET_BOOL
#define DORA_LOVE_BODY_SET_BOOL(Method, BackendMethod) \
	void PhysicsBodyUserdata::Method(bool value) { std::string error; \
		requirePhysicsResult(requirePhysicsBodyBackend(this)->BackendMethod(handle, value, error), error); }
DORA_LOVE_BODY_SET_BOOL(setBullet, setBodyBullet)
DORA_LOVE_BODY_SET_BOOL(setActive, setBodyActive)
DORA_LOVE_BODY_SET_BOOL(setAwake, setBodyAwake)
DORA_LOVE_BODY_SET_BOOL(setSleepingAllowed, setBodySleepingAllowed)
DORA_LOVE_BODY_SET_BOOL(setFixedRotation, setBodyFixedRotation)
#undef DORA_LOVE_BODY_SET_BOOL

::love::physics::World *PhysicsBodyUserdata::getWorld() const { return worldObject.get(); }
int PhysicsBodyUserdata::getFixtures(lua_State *L) const { return runtime->pushPhysicsBodyFixtures(handle, L); }
int PhysicsBodyUserdata::getJoints(lua_State *L) const { return runtime->pushPhysicsBodyJoints(handle, L); }
int PhysicsBodyUserdata::getContacts(lua_State *L) const { return runtime->pushPhysicsBodyContacts(handle, L); }
bool PhysicsBodyUserdata::isTouching(::love::physics::Body *other) const
{
	auto *body = dynamic_cast<PhysicsBodyUserdata *>(other);
	return body && body->runtime == runtime && runtime && runtime->arePhysicsBodiesTouching(handle, body->handle);
}
void PhysicsBodyUserdata::destroy()
{
	const auto oldHandle = handle;
	if (runtime && handle)
	{
		releaseDoraHandle();
		runtime->cleanupInvalidPhysicsFixtures(runtime->getState());
		runtime->cleanupInvalidPhysicsJoints();
	}
	if (runtime && oldHandle) runtime->untrackPhysicsBodyObject(oldHandle);
	invalidateDoraHandle(); userData.unref();
}
int PhysicsBodyUserdata::setUserData(lua_State *L) { ::love::luax_assert_argc(L, 1, 1); userData.ref(L); return 0; }
int PhysicsBodyUserdata::getUserData(lua_State *L) { userData.push(L); return 1; }

int LoveRuntime::pushPhysicsBodyFixtures(PhysicsBackend::BodyHandle body, lua_State *state) const
{
	lua_newtable(state); int output = 1;
	for (const auto &[handle, object] : _physicsFixtureObjects)
	{
		auto *fixture = static_cast<PhysicsFixtureUserdata *>(object.get());
		if (!fixture || !fixture->bodyObject || fixture->bodyObject->handle != body || !fixture->handle
			|| !_physicsBackend || !_physicsBackend->isFixtureValid(handle)) continue;
		::love::luax_pushtype(state, ::love::physics::Fixture::type, fixture); lua_seti(state, -2, output++);
	}
	return 1;
}

int LoveRuntime::pushPhysicsBodyJoints(PhysicsBackend::BodyHandle body, lua_State *state) const
{
	lua_newtable(state); int output = 1;
	for (const auto &[handle, object] : _physicsJointObjects)
	{
		auto *joint = static_cast<PhysicsJointUserdata *>(object.get());
		if (!joint || !joint->handle || !_physicsBackend || !_physicsBackend->isJointValid(handle)
			|| ((!joint->bodyAObject || joint->bodyAObject->handle != body)
				&& (!joint->bodyBObject || joint->bodyBObject->handle != body))) continue;
		::love::luax_pushtype(state, ::love::physics::Joint::type, joint); lua_seti(state, -2, output++);
	}
	return 1;
}

int LoveRuntime::pushPhysicsBodyContacts(PhysicsBackend::BodyHandle body, lua_State *state) const
{
	lua_newtable(state); int output = 1;
	for (const auto &[handle, object] : _physicsContactObjects)
	{
		auto *contact = static_cast<PhysicsContactUserdata *>(object.get());
		if (!contact || !contact->handle || !_physicsBackend || !_physicsBackend->isContactValid(handle)) continue;
		const bool matches = (contact->fixtureAObject && contact->fixtureAObject->bodyObject
			&& contact->fixtureAObject->bodyObject->handle == body)
			|| (contact->fixtureBObject && contact->fixtureBObject->bodyObject
				&& contact->fixtureBObject->bodyObject->handle == body);
		if (!matches) continue;
		::love::luax_pushtype(state, ::love::physics::Contact::type, contact); lua_seti(state, -2, output++);
	}
	return 1;
}

bool LoveRuntime::arePhysicsBodiesTouching(PhysicsBackend::BodyHandle first,
	PhysicsBackend::BodyHandle second) const
{
	if (!_physicsBackend) return false;
	for (const auto &[handle, object] : _physicsContactObjects)
	{
		auto *contact = static_cast<PhysicsContactUserdata *>(object.get());
		if (!contact || !_physicsBackend->isContactValid(handle)) continue;
		auto bodyA = contact->fixtureAObject && contact->fixtureAObject->bodyObject
			? contact->fixtureAObject->bodyObject->handle : 0;
		auto bodyB = contact->fixtureBObject && contact->fixtureBObject->bodyObject
			? contact->fixtureBObject->bodyObject->handle : 0;
		if (!((bodyA == first && bodyB == second) || (bodyA == second && bodyB == first))) continue;
		bool touching = false; std::string error;
		if (_physicsBackend->isContactTouching(handle, touching, error) && touching) return true;
	}
	return false;
}

void LoveRuntime::trackPhysicsBodyObject(PhysicsBackend::BodyHandle handle, ::love::Object *body)
{
	_physicsBodyObjects[handle].set(body);
}

void LoveRuntime::untrackPhysicsBodyObject(PhysicsBackend::BodyHandle handle)
{
	_physicsBodyObjects.erase(handle);
}

int LoveRuntime::callPhysicsWorldCallbacks(::love::Object *world, lua_State *state, bool set)
{
	::love::luax_pushtype(state, ::love::physics::World::type, world);
	lua_insert(state, 1);
	return set ? physicsWorldSetCallbacks(state) : physicsWorldGetCallbacks(state);
}

int LoveRuntime::callPhysicsWorldQuery(::love::Object *world, lua_State *state, bool raycast)
{
	::love::luax_pushtype(state, ::love::physics::World::type, world);
	lua_insert(state, 1);
	return raycast ? physicsWorldRayCast(state) : physicsWorldQueryBoundingBox(state);
}

void LoveRuntime::destroyPhysicsWorldObject(lua_State *state)
{
	physicsWorldDestroy(state);
}

void LoveRuntime::translatePhysicsWorldOrigin(PhysicsBackend::WorldHandle world, float x, float y)
{
	for (const auto &[bodyHandle, object] : _physicsBodyObjects)
	{
		auto *body = static_cast<PhysicsBodyUserdata *>(object.get());
		if (!body || body->world != world || !body->handle
			|| !_physicsBackend->isBodyValid(bodyHandle)) continue;
		float oldX = 0.0f, oldY = 0.0f; std::string error;
		requirePhysicsResult(_physicsBackend->getBodyPosition(bodyHandle, oldX, oldY, error), error);
		requirePhysicsResult(_physicsBackend->setBodyPosition(bodyHandle, oldX - x, oldY - y, error), error);
	}
}

int LoveRuntime::countPhysicsWorldBodies(PhysicsBackend::WorldHandle world) const
{
	int count = 0;
	for (const auto &[bodyHandle, object] : _physicsBodyObjects)
	{
		auto *body = static_cast<PhysicsBodyUserdata *>(object.get());
		if (body && body->world == world && body->handle
			&& _physicsBackend->isBodyValid(bodyHandle)) ++count;
	}
	return count;
}

int LoveRuntime::countPhysicsWorldJoints(PhysicsBackend::WorldHandle world) const
{
	int count = 0;
	for (const auto &[jointHandle, object] : _physicsJointObjects)
	{
		auto *joint = static_cast<PhysicsJointUserdata *>(object.get());
		if (joint && joint->handle && _physicsBackend->isJointValid(jointHandle)
			&& joint->bodyAObject && joint->bodyAObject->world == world) ++count;
	}
	return count;
}

int LoveRuntime::countPhysicsWorldContacts(PhysicsBackend::WorldHandle world) const
{
	int count = 0;
	for (const auto &[contactHandle, object] : _physicsContactObjects)
	{
		auto *contact = static_cast<PhysicsContactUserdata *>(object.get());
		if (contact && contact->world == world && contact->handle
			&& _physicsBackend->isContactValid(contactHandle)) ++count;
	}
	return count;
}

int LoveRuntime::pushPhysicsWorldBodies(PhysicsBackend::WorldHandle world, lua_State *state) const
{
	lua_newtable(state); int output = 1;
	for (const auto &[bodyHandle, object] : _physicsBodyObjects)
	{
		auto *body = static_cast<PhysicsBodyUserdata *>(object.get());
		if (!body || body->world != world || !body->handle || !_physicsBackend->isBodyValid(bodyHandle)) continue;
		::love::luax_pushtype(state, ::love::physics::Body::type, body); lua_seti(state, -2, output++);
	}
	return 1;
}

int LoveRuntime::pushPhysicsWorldJoints(PhysicsBackend::WorldHandle world, lua_State *state) const
{
	lua_newtable(state); int output = 1;
	for (const auto &[jointHandle, object] : _physicsJointObjects)
	{
		auto *joint = static_cast<PhysicsJointUserdata *>(object.get());
		if (!joint || !joint->handle || !_physicsBackend->isJointValid(jointHandle)
			|| !joint->bodyAObject || joint->bodyAObject->world != world) continue;
		::love::luax_pushtype(state, ::love::physics::Joint::type, joint); lua_seti(state, -2, output++);
	}
	return 1;
}

int LoveRuntime::pushPhysicsWorldContacts(PhysicsBackend::WorldHandle world, lua_State *state) const
{
	lua_newtable(state); int output = 1;
	for (const auto &[contactHandle, object] : _physicsContactObjects)
	{
		auto *contact = static_cast<PhysicsContactUserdata *>(object.get());
		if (!contact || contact->world != world || !contact->handle
			|| !_physicsBackend->isContactValid(contactHandle)) continue;
		::love::luax_pushtype(state, ::love::physics::Contact::type, contact); lua_seti(state, -2, output++);
	}
	return 1;
}

void LoveRuntime::cleanupInvalidPhysicsFixtures(lua_State *state)
{
	if (!_physicsBackend) return;
	for (auto fixture = _physicsFixtureReferences.begin(); fixture != _physicsFixtureReferences.end();)
	{
		if (_physicsBackend->isFixtureValid(fixture->first)) { ++fixture; continue; }
		if (auto object = _physicsFixtureObjects.find(fixture->first); object != _physicsFixtureObjects.end())
			static_cast<PhysicsFixtureUserdata *>(object->second.get())->invalidateDoraHandle();
		luaL_unref(state, LUA_REGISTRYINDEX, fixture->second);
		_physicsFixtureObjects.erase(fixture->first);
		fixture = _physicsFixtureReferences.erase(fixture);
	}
}

void LoveRuntime::cleanupInvalidPhysicsJoints()
{
	if (!_physicsBackend) return;
	for (auto joint = _physicsJointObjects.begin(); joint != _physicsJointObjects.end();)
	{
		if (_physicsBackend->isJointValid(joint->first)) { ++joint; continue; }
		static_cast<PhysicsJointUserdata *>(joint->second.get())->invalidateDoraHandle();
		joint = _physicsJointObjects.erase(joint);
	}
}

void LoveRuntime::cleanupInvalidPhysicsBodies()
{
	if (!_physicsBackend) return;
	for (auto body = _physicsBodyObjects.begin(); body != _physicsBodyObjects.end();)
	{
		if (_physicsBackend->isBodyValid(body->first)) { ++body; continue; }
		static_cast<PhysicsBodyUserdata *>(body->second.get())->invalidateDoraHandle();
		body = _physicsBodyObjects.erase(body);
	}
}

static PhysicsBackend *requirePhysicsShapeBackend(const PhysicsShapeUserdata *shape)
{
	auto *backend = shape && shape->runtime ? shape->runtime->getPhysicsBackend() : nullptr;
	if (!backend || !shape->handle) throw ::love::Exception("Shape is closed");
	return backend;
}

::love::physics::Shape::Type PhysicsShapeUserdata::getType() const
{
	::love::physics::Shape::Type value = ::love::physics::Shape::SHAPE_INVALID;
	if (!::love::physics::Shape::getConstant(type.c_str(), value))
		throw ::love::Exception("Shape has an invalid type");
	return value;
}
float PhysicsShapeUserdata::getRadius() const { requirePhysicsShapeBackend(this); return radius; }
void PhysicsShapeUserdata::setRadius(float value)
{
	if (type != "circle") throw ::love::Exception("expected CircleShape");
	if (!std::isfinite(value) || value <= 0.0f) throw ::love::Exception("radius must be finite and positive");
	std::string error; requirePhysicsResult(requirePhysicsShapeBackend(this)->setCircleShape(handle,
		points[0], points[1], value, error), error); radius = value;
}
void PhysicsShapeUserdata::getPoint(float &x, float &y) const
{
	if (type != "circle") throw ::love::Exception("expected CircleShape");
	requirePhysicsShapeBackend(this); x = points[0]; y = points[1];
}
void PhysicsShapeUserdata::setPoint(float x, float y)
{
	if (type != "circle") throw ::love::Exception("expected CircleShape");
	if (!std::isfinite(x) || !std::isfinite(y)) throw ::love::Exception("circle point must be finite");
	std::string error; requirePhysicsResult(requirePhysicsShapeBackend(this)->setCircleShape(handle,
		x, y, radius, error), error); points[0] = x; points[1] = y;
}
int PhysicsShapeUserdata::getPoints(lua_State *L) const
{
	if (type == "circle") throw ::love::Exception("expected PolygonShape, EdgeShape, or ChainShape");
	requirePhysicsShapeBackend(this); for (float value : points) lua_pushnumber(L, value);
	return static_cast<int>(points.size());
}
bool PhysicsShapeUserdata::validate() const
{
	if (type != "polygon") throw ::love::Exception("expected PolygonShape");
	requirePhysicsShapeBackend(this); return true;
}
int PhysicsShapeUserdata::getChildCount() const
{
	int count = 0; std::string error;
	requirePhysicsResult(requirePhysicsShapeBackend(this)->getShapeChildCount(handle, count, error), error); return count;
}
int PhysicsShapeUserdata::getVertexCount() const
{
	if (type != "chain") throw ::love::Exception("expected ChainShape");
	requirePhysicsShapeBackend(this); return static_cast<int>(points.size() / 2);
}
void PhysicsShapeUserdata::getPoint(int index, float &x, float &y) const
{
	if (type != "chain") throw ::love::Exception("expected ChainShape");
	if (index < 0 || static_cast<std::size_t>(index) >= points.size() / 2)
		throw ::love::Exception("ChainShape point index is out of bounds");
	requirePhysicsShapeBackend(this); x = points[static_cast<std::size_t>(index) * 2];
	y = points[static_cast<std::size_t>(index) * 2 + 1];
}
::love::physics::Shape *PhysicsShapeUserdata::getChildEdge(int index) const
{
	if (type != "chain") throw ::love::Exception("expected ChainShape");
	const int childCount = static_cast<int>(points.size() / 2) - 1;
	if (index < 0 || index >= childCount) throw ::love::Exception("ChainShape child edge index is out of bounds");
	const auto first = static_cast<std::size_t>(index) * 2;
	const float x1=points[first], y1=points[first+1], x2=points[first+2], y2=points[first+3];
	std::string error; const auto newHandle = requirePhysicsShapeBackend(this)->newEdgeShape(x1,y1,x2,y2,error);
	if (!newHandle) throw ::love::Exception("%s", error.empty() ? "failed to create ChainShape child EdgeShape" : error.c_str());
	auto *edge = new PhysicsShapeUserdata(runtime, newHandle, "edge", 0.0f, {x1,y1,x2,y2});
	if (index > 0) { edge->hasPreviousVertex=true; edge->previousX=points[first-2]; edge->previousY=points[first-1]; }
	else if (loop) { edge->hasPreviousVertex=true; edge->previousX=points[points.size()-4]; edge->previousY=points[points.size()-3]; }
	else if (hasPreviousVertex) { edge->hasPreviousVertex=true; edge->previousX=previousX; edge->previousY=previousY; }
	if (index + 2 < static_cast<int>(points.size()/2)) { edge->hasNextVertex=true; edge->nextX=points[first+4]; edge->nextY=points[first+5]; }
	else if (loop) { edge->hasNextVertex=true; edge->nextX=points[2]; edge->nextY=points[3]; }
	else if (hasNextVertex) { edge->hasNextVertex=true; edge->nextX=nextX; edge->nextY=nextY; }
	try
	{
		if (edge->hasPreviousVertex) requirePhysicsResult(runtime->getPhysicsBackend()->setShapePreviousVertex(newHandle,true,edge->previousX,edge->previousY,error),error);
		if (edge->hasNextVertex) requirePhysicsResult(runtime->getPhysicsBackend()->setShapeNextVertex(newHandle,true,edge->nextX,edge->nextY,error),error);
	}
	catch (...)
	{
		edge->release();
		throw;
	}
	return edge;
}
void PhysicsShapeUserdata::setNextVertex() { setNextVertex(std::numeric_limits<float>::quiet_NaN(), 0.0f); }
void PhysicsShapeUserdata::setNextVertex(float x, float y)
{
	if (type != "edge" && type != "chain") throw ::love::Exception("expected EdgeShape or ChainShape");
	const bool has = std::isfinite(x); if (has && !std::isfinite(y)) throw ::love::Exception("next vertex must be finite");
	std::string error; requirePhysicsResult(requirePhysicsShapeBackend(this)->setShapeNextVertex(handle,has,has?x:0,has?y:0,error),error);
	hasNextVertex=has; nextX=has?x:0; nextY=has?y:0;
}
void PhysicsShapeUserdata::setPreviousVertex() { setPreviousVertex(std::numeric_limits<float>::quiet_NaN(), 0.0f); }
void PhysicsShapeUserdata::setPreviousVertex(float x, float y)
{
	if (type != "edge" && type != "chain") throw ::love::Exception("expected EdgeShape or ChainShape");
	const bool has = std::isfinite(x); if (has && !std::isfinite(y)) throw ::love::Exception("previous vertex must be finite");
	std::string error; requirePhysicsResult(requirePhysicsShapeBackend(this)->setShapePreviousVertex(handle,has,has?x:0,has?y:0,error),error);
	hasPreviousVertex=has; previousX=has?x:0; previousY=has?y:0;
}
bool PhysicsShapeUserdata::getNextVertex(float &x, float &y) const { requirePhysicsShapeBackend(this); x=nextX; y=nextY; return hasNextVertex; }
bool PhysicsShapeUserdata::getPreviousVertex(float &x, float &y) const { requirePhysicsShapeBackend(this); x=previousX; y=previousY; return hasPreviousVertex; }
bool PhysicsShapeUserdata::testPoint(float x,float y,float angle,float px,float py) const
{
	bool value=false; std::string error; requirePhysicsResult(requirePhysicsShapeBackend(this)->testShapePoint(handle,x,y,angle,px,py,value,error),error); return value;
}
int PhysicsShapeUserdata::rayCast(lua_State *L) const
{
	const float x1=(float)luaL_checknumber(L,1),y1=(float)luaL_checknumber(L,2),x2=(float)luaL_checknumber(L,3),y2=(float)luaL_checknumber(L,4);
	const float maximum=(float)luaL_checknumber(L,5),x=(float)luaL_checknumber(L,6),y=(float)luaL_checknumber(L,7),angle=(float)luaL_checknumber(L,8);
	const lua_Integer child=luaL_optinteger(L,9,1); if(child<1||child>65536) throw ::love::Exception("child index is out of range");
	bool hit=false; float nx=0,ny=0,fraction=0; std::string error;
	requirePhysicsResult(requirePhysicsShapeBackend(this)->rayCastShape(handle,x1,y1,x2,y2,maximum,x,y,angle,static_cast<std::uint16_t>(child-1),hit,nx,ny,fraction,error),error);
	if(!hit)return 0; lua_pushnumber(L,nx);lua_pushnumber(L,ny);lua_pushnumber(L,fraction);return 3;
}
int PhysicsShapeUserdata::computeAABB(lua_State *L) const
{
	const float x=(float)luaL_checknumber(L,1),y=(float)luaL_checknumber(L,2),angle=(float)luaL_checknumber(L,3); const lua_Integer child=luaL_optinteger(L,4,1);
	if(child<1||child>65536) throw ::love::Exception("child index is out of range"); float x1=0,y1=0,x2=0,y2=0; std::string error;
	requirePhysicsResult(requirePhysicsShapeBackend(this)->getShapeBoundingBox(handle,x,y,angle,static_cast<std::uint16_t>(child-1),x1,y1,x2,y2,error),error);
	lua_pushnumber(L,x1);lua_pushnumber(L,y1);lua_pushnumber(L,x2);lua_pushnumber(L,y2);return 4;
}
int PhysicsShapeUserdata::computeMass(lua_State *L) const
{
	const float density=(float)luaL_checknumber(L,1); if(!std::isfinite(density)||density<0) throw ::love::Exception("density must be finite and non-negative");
	float x=0,y=0,mass=0,inertia=0; std::string error; requirePhysicsResult(requirePhysicsShapeBackend(this)->getShapeMassData(handle,density,x,y,mass,inertia,error),error);
	lua_pushnumber(L,x);lua_pushnumber(L,y);lua_pushnumber(L,mass);lua_pushnumber(L,inertia);return 4;
}

namespace
{
std::uint16_t fixtureBitsFromLua(lua_State *state, int first)
{
	std::uint16_t bits = 0;
	const bool table = lua_istable(state, first);
	const lua_Integer count = table ? static_cast<lua_Integer>(lua_rawlen(state, first))
		: static_cast<lua_Integer>(lua_gettop(state) - first + 1);
	for (lua_Integer index = 1; index <= count; ++index)
	{
		lua_Integer category = 0;
		if (table)
		{
			lua_rawgeti(state, first, index);
			if (!lua_isinteger(state, -1))
				return static_cast<std::uint16_t>(luaL_error(state,
					"Fixture category values must be integers in range 1-16"));
			category = lua_tointeger(state, -1);
			lua_pop(state, 1);
		}
		else category = luaL_checkinteger(state, first + static_cast<int>(index) - 1);
		if (category < 1 || category > 16)
			return static_cast<std::uint16_t>(luaL_error(state,
				"Fixture category values must be integers in range 1-16"));
		bits |= static_cast<std::uint16_t>(1u << (category - 1));
	}
	return bits;
}

int pushFixtureBits(lua_State *state, std::uint16_t bits)
{
	int count = 0;
	for (int index = 0; index < 16; ++index)
		if ((bits & static_cast<std::uint16_t>(1u << index)) != 0)
		{ lua_pushinteger(state, index + 1); ++count; }
	return count;
}
}

static PhysicsBackend *requirePhysicsFixtureBackend(const PhysicsFixtureUserdata *fixture)
{
	auto *backend = fixture && fixture->runtime ? fixture->runtime->getPhysicsBackend() : nullptr;
	if (!backend || !fixture->handle || !backend->isFixtureValid(fixture->handle))
		throw ::love::Exception("Fixture is destroyed");
	return backend;
}

::love::physics::Shape::Type PhysicsFixtureUserdata::getType()
{
	::love::physics::Shape::Type value = ::love::physics::Shape::SHAPE_INVALID;
	if (!shapeObject || !::love::physics::Shape::getConstant(shapeObject->type.c_str(), value))
		throw ::love::Exception("Fixture has an invalid Shape");
	return value;
}
::love::physics::Shape *PhysicsFixtureUserdata::getShape() { requirePhysicsFixtureBackend(this); return shapeObject.get(); }
bool PhysicsFixtureUserdata::isValid() const
{
	auto *backend = runtime ? runtime->getPhysicsBackend() : nullptr;
	return backend && handle && backend->isFixtureValid(handle);
}
bool PhysicsFixtureUserdata::isSensor() const { requirePhysicsFixtureBackend(this); return sensor; }
void PhysicsFixtureUserdata::setSensor(bool value)
{
	std::string error; requirePhysicsResult(requirePhysicsFixtureBackend(this)->setFixtureSensor(handle, value, error), error); sensor = value;
}
::love::physics::Body *PhysicsFixtureUserdata::getBody() const { requirePhysicsFixtureBackend(this); return bodyObject.get(); }
void PhysicsFixtureUserdata::setFilterData(int *values)
{
	if (values[2] < -32768 || values[2] > 32767) throw ::love::Exception("group index must be in signed 16-bit range");
	std::string error; requirePhysicsResult(requirePhysicsFixtureBackend(this)->setFixtureFilterData(handle,
		static_cast<std::uint16_t>(values[0]), static_cast<std::uint16_t>(values[1]),
		static_cast<std::int16_t>(values[2]), error), error);
}
void PhysicsFixtureUserdata::getFilterData(int *values)
{
	std::uint16_t category = 0, mask = 0; std::int16_t group = 0; std::string error;
	requirePhysicsResult(requirePhysicsFixtureBackend(this)->getFixtureFilterData(handle, category, mask, group, error), error);
	values[0] = category; values[1] = mask; values[2] = group;
}
int PhysicsFixtureUserdata::setUserData(lua_State *L) { ::love::luax_assert_argc(L, 1, 1); userData.ref(L); return 0; }
int PhysicsFixtureUserdata::getUserData(lua_State *L) { userData.push(L); return 1; }
void PhysicsFixtureUserdata::setFriction(float value)
{
	if (!std::isfinite(value) || value < 0.0f) throw ::love::Exception("friction must be finite and non-negative");
	std::string error; requirePhysicsResult(requirePhysicsFixtureBackend(this)->setFixtureFriction(handle, value, error), error); friction = value;
}
void PhysicsFixtureUserdata::setRestitution(float value)
{
	if (!std::isfinite(value) || value < 0.0f) throw ::love::Exception("restitution must be finite and non-negative");
	std::string error; requirePhysicsResult(requirePhysicsFixtureBackend(this)->setFixtureRestitution(handle, value, error), error); restitution = value;
}
void PhysicsFixtureUserdata::setDensity(float value)
{
	if (!std::isfinite(value) || value < 0.0f) throw ::love::Exception("density must be finite and non-negative");
	std::string error; requirePhysicsResult(requirePhysicsFixtureBackend(this)->setFixtureDensity(handle, value, error), error); density = value;
}
float PhysicsFixtureUserdata::getFriction() const { requirePhysicsFixtureBackend(this); return friction; }
float PhysicsFixtureUserdata::getRestitution() const { requirePhysicsFixtureBackend(this); return restitution; }
float PhysicsFixtureUserdata::getDensity() const { requirePhysicsFixtureBackend(this); return density; }
bool PhysicsFixtureUserdata::testPoint(float x, float y) const
{
	if (!std::isfinite(x) || !std::isfinite(y)) throw ::love::Exception("point must be finite");
	bool value = false; std::string error;
	requirePhysicsResult(requirePhysicsFixtureBackend(this)->testFixturePoint(handle, x, y, value, error), error); return value;
}
int PhysicsFixtureUserdata::rayCast(lua_State *L) const
{
	const float x1 = (float) luaL_checknumber(L, 1), y1 = (float) luaL_checknumber(L, 2);
	const float x2 = (float) luaL_checknumber(L, 3), y2 = (float) luaL_checknumber(L, 4);
	const float maximum = (float) luaL_checknumber(L, 5); const lua_Integer child = luaL_optinteger(L, 6, 1);
	if (!std::isfinite(x1) || !std::isfinite(y1) || !std::isfinite(x2) || !std::isfinite(y2)) throw ::love::Exception("ray points must be finite");
	if (!std::isfinite(maximum) || maximum < 0.0f || maximum > 1.0f) throw ::love::Exception("maximum fraction must be in range 0-1");
	if (child < 1 || child > 65536) throw ::love::Exception("child index must be a positive integer");
	bool hit = false; float nx = 0, ny = 0, fraction = 0; std::string error;
	requirePhysicsResult(requirePhysicsFixtureBackend(this)->rayCastFixture(handle, x1, y1, x2, y2, maximum,
		static_cast<std::uint16_t>(child - 1), hit, nx, ny, fraction, error), error);
	if (!hit) return 0; lua_pushnumber(L, nx); lua_pushnumber(L, ny); lua_pushnumber(L, fraction); return 3;
}
void PhysicsFixtureUserdata::setGroupIndex(int index)
{
	if (index < -32768 || index > 32767) throw ::love::Exception("group index must be in signed 16-bit range");
	int values[3]; getFilterData(values); values[2] = index; setFilterData(values);
}
int PhysicsFixtureUserdata::getGroupIndex() const
{
	int values[3]; const_cast<PhysicsFixtureUserdata *>(this)->getFilterData(values); return values[2];
}
int PhysicsFixtureUserdata::setCategory(lua_State *L)
{
	const auto category = fixtureBitsFromLua(L, 1); int values[3]; getFilterData(values); values[0] = category; setFilterData(values); return 0;
}
int PhysicsFixtureUserdata::setMask(lua_State *L)
{
	const auto excluded = fixtureBitsFromLua(L, 1); int values[3]; getFilterData(values); values[1] = static_cast<std::uint16_t>(~excluded); setFilterData(values); return 0;
}
int PhysicsFixtureUserdata::getCategory(lua_State *L) { int values[3]; getFilterData(values); return pushFixtureBits(L, static_cast<std::uint16_t>(values[0])); }
int PhysicsFixtureUserdata::getMask(lua_State *L) { int values[3]; getFilterData(values); return pushFixtureBits(L, static_cast<std::uint16_t>(~values[1])); }
int PhysicsFixtureUserdata::getBoundingBox(lua_State *L) const
{
	const lua_Integer child = luaL_optinteger(L, 1, 1); if (child < 1 || child > 65536) throw ::love::Exception("child index must be a positive integer");
	float x1 = 0, y1 = 0, x2 = 0, y2 = 0; std::string error;
	requirePhysicsResult(requirePhysicsFixtureBackend(this)->getFixtureBoundingBox(handle, static_cast<std::uint16_t>(child - 1), x1, y1, x2, y2, error), error);
	lua_pushnumber(L, x1); lua_pushnumber(L, y1); lua_pushnumber(L, x2); lua_pushnumber(L, y2); return 4;
}
int PhysicsFixtureUserdata::getMassData(lua_State *L) const
{
	float x = 0, y = 0, mass = 0, inertia = 0; std::string error;
	requirePhysicsResult(requirePhysicsFixtureBackend(this)->getFixtureMassData(handle, x, y, mass, inertia, error), error);
	lua_pushnumber(L, x); lua_pushnumber(L, y); lua_pushnumber(L, mass); lua_pushnumber(L, inertia); return 4;
}
void PhysicsFixtureUserdata::destroy()
{
	if (runtime) runtime->destroyPhysicsFixtureObject(this);
}

void LoveRuntime::destroyPhysicsFixtureObject(::love::Object *object)
{
	auto *fixture = static_cast<PhysicsFixtureUserdata *>(object);
	if (!fixture || !fixture->handle) return;
	const auto oldHandle = fixture->handle;
	if (_physicsBackend) fixture->releaseDoraHandle();
	if (!_physicsBackend || !_physicsBackend->isFixtureValid(oldHandle))
	{
		auto reference = _physicsFixtureReferences.find(oldHandle);
		if (reference != _physicsFixtureReferences.end())
		{
			luaL_unref(_state, LUA_REGISTRYINDEX, reference->second);
			_physicsFixtureReferences.erase(reference); _physicsFixtureObjects.erase(oldHandle);
		}
	}
	fixture->invalidateDoraHandle();
}

static PhysicsBackend *requirePhysicsJointBackend(const PhysicsJointUserdata *joint)
{
	auto *backend = joint && joint->runtime ? joint->runtime->getPhysicsBackend() : nullptr;
	if (!backend || !joint->handle || !backend->isJointValid(joint->handle))
		throw ::love::Exception("Attempt to use destroyed joint.");
	return backend;
}

::love::physics::Joint::Type PhysicsJointUserdata::getType() const
{
	requirePhysicsJointBackend(this);
	::love::physics::Joint::Type value = ::love::physics::Joint::JOINT_INVALID;
	if (!::love::physics::Joint::getConstant(type.c_str(), value))
		throw ::love::Exception("unknown Joint type");
	return value;
}

bool PhysicsJointUserdata::isValid() const
{
	auto *backend = runtime ? runtime->getPhysicsBackend() : nullptr;
	return backend && handle && backend->isJointValid(handle);
}

::love::physics::Body *PhysicsJointUserdata::getBodyA() const
{
	requirePhysicsJointBackend(this);
	return bodyAObject.get();
}

::love::physics::Body *PhysicsJointUserdata::getBodyB() const
{
	requirePhysicsJointBackend(this);
	return bodyBObject.get();
}

int PhysicsJointUserdata::getAnchors(lua_State *L) const
{
	float x1 = 0.0f, y1 = 0.0f, x2 = 0.0f, y2 = 0.0f;
	std::string error;
	requirePhysicsResult(requirePhysicsJointBackend(this)->getJointAnchors(
		handle, x1, y1, x2, y2, error), error);
	lua_pushnumber(L, x1);
	lua_pushnumber(L, y1);
	lua_pushnumber(L, x2);
	lua_pushnumber(L, y2);
	return 4;
}

int PhysicsJointUserdata::getReactionForce(lua_State *L) const
{
	const float inverseDeltaTime = static_cast<float>(luaL_checknumber(L, 1));
	if (!std::isfinite(inverseDeltaTime) || inverseDeltaTime < 0.0f)
		throw ::love::Exception("inverse delta time must be finite and non-negative");
	float x = 0.0f, y = 0.0f;
	std::string error;
	requirePhysicsResult(requirePhysicsJointBackend(this)->getJointReactionForce(
		handle, inverseDeltaTime, x, y, error), error);
	lua_pushnumber(L, x);
	lua_pushnumber(L, y);
	return 2;
}

float PhysicsJointUserdata::getReactionTorque(float inverseDeltaTime) const
{
	if (!std::isfinite(inverseDeltaTime) || inverseDeltaTime < 0.0f)
		throw ::love::Exception("inverse delta time must be finite and non-negative");
	float value = 0.0f;
	std::string error;
	requirePhysicsResult(requirePhysicsJointBackend(this)->getJointReactionTorque(
		handle, inverseDeltaTime, value, error), error);
	return value;
}

bool PhysicsJointUserdata::getCollideConnected() const
{
	bool value = false;
	std::string error;
	requirePhysicsResult(requirePhysicsJointBackend(this)->getJointCollideConnected(
		handle, value, error), error);
	return value;
}

int PhysicsJointUserdata::setUserData(lua_State *L)
{
	::love::luax_assert_argc(L, 1, 1);
	requirePhysicsJointBackend(this);
	userData.ref(L);
	return 0;
}

int PhysicsJointUserdata::getUserData(lua_State *L)
{
	requirePhysicsJointBackend(this);
	userData.push(L);
	return 1;
}

void PhysicsJointUserdata::destroyJoint()
{
	if (runtime) runtime->destroyPhysicsJointObject(this);
}

void LoveRuntime::destroyPhysicsJointObject(::love::Object *object)
{
	auto *joint = static_cast<PhysicsJointUserdata *>(object);
	if (!joint || !joint->handle) return;
	const auto oldHandle = joint->handle;
	joint->releaseDoraHandle();
	_physicsJointObjects.erase(oldHandle);
	joint->invalidateDoraHandle();
}

float PhysicsJointUserdata::getScalar(::love::physics::Joint::ScalarProperty property,
	float argument) const
{
	using Property = ::love::physics::Joint::ScalarProperty;
	auto *backend = requirePhysicsJointBackend(this);
	float value = 0.0f;
	std::string error;
	bool success = false;
	switch (property)
	{
		case Property::Length:
			success = type == "distance" && backend->getDistanceJointLength(handle, value, error); break;
		case Property::Frequency:
			if (type == "distance") success = backend->getDistanceJointFrequency(handle, value, error);
			else if (type == "weld") success = backend->getWeldJointFrequency(handle, value, error);
			else if (type == "mouse") success = backend->getMouseJointFrequency(handle, value, error);
			break;
		case Property::DampingRatio:
			if (type == "distance") success = backend->getDistanceJointDampingRatio(handle, value, error);
			else if (type == "weld") success = backend->getWeldJointDampingRatio(handle, value, error);
			else if (type == "mouse") success = backend->getMouseJointDampingRatio(handle, value, error);
			break;
		case Property::JointAngle:
			success = type == "revolute" && backend->getRevoluteJointAngle(handle, value, error); break;
		case Property::JointSpeed:
			if (type == "revolute") success = backend->getRevoluteJointSpeed(handle, value, error);
			else if (type == "prismatic") success = backend->getPrismaticJointSpeed(handle, value, error);
			else if (type == "wheel") success = backend->getWheelJointSpeed(handle, value, error);
			break;
		case Property::MaxMotorTorque:
			if (type == "revolute") success = backend->getRevoluteJointMaxMotorTorque(handle, value, error);
			else if (type == "wheel") success = backend->getWheelJointMaxMotorTorque(handle, value, error);
			break;
		case Property::MotorSpeed:
			if (type == "revolute") success = backend->getRevoluteJointMotorSpeed(handle, value, error);
			else if (type == "prismatic") success = backend->getPrismaticJointMotorSpeed(handle, value, error);
			else if (type == "wheel") success = backend->getWheelJointMotorSpeed(handle, value, error);
			break;
		case Property::MotorTorque:
			if (type == "revolute") success = backend->getRevoluteJointMotorTorque(handle, argument, value, error);
			else if (type == "wheel") success = backend->getWheelJointMotorTorque(handle, argument, value, error);
			break;
		case Property::LowerLimit:
		case Property::UpperLimit:
		{
			float lower = 0.0f, upper = 0.0f;
			getLimits(lower, upper);
			return property == Property::LowerLimit ? lower : upper;
		}
		case Property::ReferenceAngle:
			if (type == "revolute") success = backend->getRevoluteJointReferenceAngle(handle, value, error);
			else if (type == "prismatic") success = backend->getPrismaticJointReferenceAngle(handle, value, error);
			else if (type == "weld") success = backend->getWeldJointReferenceAngle(handle, value, error);
			break;
		case Property::JointTranslation:
			if (type == "prismatic") success = backend->getPrismaticJointTranslation(handle, value, error);
			else if (type == "wheel") success = backend->getWheelJointTranslation(handle, value, error);
			break;
		case Property::MaxMotorForce:
			success = type == "prismatic" && backend->getPrismaticJointMaxMotorForce(handle, value, error); break;
		case Property::MotorForce:
			success = type == "prismatic" && backend->getPrismaticJointMotorForce(handle, argument, value, error); break;
		case Property::MaxForce:
			if (type == "friction") success = backend->getFrictionJointMaxForce(handle, value, error);
			else if (type == "mouse") success = backend->getMouseJointMaxForce(handle, value, error);
			else if (type == "motor") success = backend->getMotorJointMaxForce(handle, value, error);
			break;
		case Property::MaxTorque:
			if (type == "friction") success = backend->getFrictionJointMaxTorque(handle, value, error);
			else if (type == "motor") success = backend->getMotorJointMaxTorque(handle, value, error);
			break;
		case Property::MaxLength:
			success = type == "rope" && backend->getRopeJointMaxLength(handle, value, error); break;
		case Property::LengthA:
			success = type == "pulley" && backend->getPulleyJointLengthA(handle, value, error); break;
		case Property::LengthB:
			success = type == "pulley" && backend->getPulleyJointLengthB(handle, value, error); break;
		case Property::Ratio:
			if (type == "pulley") success = backend->getPulleyJointRatio(handle, value, error);
			else if (type == "gear") success = backend->getGearJointRatio(handle, value, error);
			break;
		case Property::SpringFrequency:
			success = type == "wheel" && backend->getWheelJointSpringFrequency(handle, value, error); break;
		case Property::SpringDampingRatio:
			success = type == "wheel" && backend->getWheelJointSpringDampingRatio(handle, value, error); break;
		case Property::AngularOffset:
			success = type == "motor" && backend->getMotorJointAngularOffset(handle, value, error); break;
		case Property::CorrectionFactor:
			success = type == "motor" && backend->getMotorJointCorrectionFactor(handle, value, error); break;
	}
	if (!success && error.empty()) error = "method is not supported by this Joint type";
	requirePhysicsResult(success, error);
	return value;
}

void PhysicsJointUserdata::setScalar(::love::physics::Joint::ScalarProperty property, float value)
{
	using Property = ::love::physics::Joint::ScalarProperty;
	auto *backend = requirePhysicsJointBackend(this);
	std::string error;
	bool success = false;
	switch (property)
	{
		case Property::Length:
			success = type == "distance" && backend->setDistanceJointLength(handle, value, error); break;
		case Property::Frequency:
			if (type == "distance") success = backend->setDistanceJointFrequency(handle, value, error);
			else if (type == "weld") success = backend->setWeldJointFrequency(handle, value, error);
			else if (type == "mouse") success = backend->setMouseJointFrequency(handle, value, error);
			break;
		case Property::DampingRatio:
			if (type == "distance") success = backend->setDistanceJointDampingRatio(handle, value, error);
			else if (type == "weld") success = backend->setWeldJointDampingRatio(handle, value, error);
			else if (type == "mouse") success = backend->setMouseJointDampingRatio(handle, value, error);
			break;
		case Property::MaxMotorTorque:
			if (type == "revolute") success = backend->setRevoluteJointMaxMotorTorque(handle, value, error);
			else if (type == "wheel") success = backend->setWheelJointMaxMotorTorque(handle, value, error);
			break;
		case Property::MotorSpeed:
			if (type == "revolute") success = backend->setRevoluteJointMotorSpeed(handle, value, error);
			else if (type == "prismatic") success = backend->setPrismaticJointMotorSpeed(handle, value, error);
			else if (type == "wheel") success = backend->setWheelJointMotorSpeed(handle, value, error);
			break;
		case Property::LowerLimit:
		case Property::UpperLimit:
		{
			float lower = 0.0f, upper = 0.0f;
			getLimits(lower, upper);
			if (property == Property::LowerLimit) lower = value; else upper = value;
			setLimits(lower, upper);
			return;
		}
		case Property::MaxMotorForce:
			success = type == "prismatic" && backend->setPrismaticJointMaxMotorForce(handle, value, error); break;
		case Property::MaxForce:
			if (type == "friction") success = backend->setFrictionJointMaxForce(handle, value, error);
			else if (type == "mouse") success = backend->setMouseJointMaxForce(handle, value, error);
			else if (type == "motor") success = backend->setMotorJointMaxForce(handle, value, error);
			break;
		case Property::MaxTorque:
			if (type == "friction") success = backend->setFrictionJointMaxTorque(handle, value, error);
			else if (type == "motor") success = backend->setMotorJointMaxTorque(handle, value, error);
			break;
		case Property::MaxLength:
			success = type == "rope" && backend->setRopeJointMaxLength(handle, value, error); break;
		case Property::Ratio:
			success = type == "gear" && backend->setGearJointRatio(handle, value, error); break;
		case Property::SpringFrequency:
			success = type == "wheel" && backend->setWheelJointSpringFrequency(handle, value, error); break;
		case Property::SpringDampingRatio:
			success = type == "wheel" && backend->setWheelJointSpringDampingRatio(handle, value, error); break;
		case Property::AngularOffset:
			success = type == "motor" && backend->setMotorJointAngularOffset(handle, value, error); break;
		case Property::CorrectionFactor:
			success = type == "motor" && backend->setMotorJointCorrectionFactor(handle, value, error); break;
		default: break;
	}
	if (!success && error.empty()) error = "method is not supported by this Joint type";
	requirePhysicsResult(success, error);
}

bool PhysicsJointUserdata::getBoolean(::love::physics::Joint::BooleanProperty property) const
{
	using Property = ::love::physics::Joint::BooleanProperty;
	auto *backend = requirePhysicsJointBackend(this);
	bool value = false;
	std::string error;
	bool success = false;
	if (property == Property::MotorEnabled)
	{
		if (type == "revolute") success = backend->isRevoluteJointMotorEnabled(handle, value, error);
		else if (type == "prismatic") success = backend->isPrismaticJointMotorEnabled(handle, value, error);
		else if (type == "wheel") success = backend->isWheelJointMotorEnabled(handle, value, error);
	}
	else
	{
		if (type == "revolute") success = backend->areRevoluteJointLimitsEnabled(handle, value, error);
		else if (type == "prismatic") success = backend->arePrismaticJointLimitsEnabled(handle, value, error);
	}
	if (!success && error.empty()) error = "method is not supported by this Joint type";
	requirePhysicsResult(success, error);
	return value;
}

void PhysicsJointUserdata::setBoolean(::love::physics::Joint::BooleanProperty property, bool value)
{
	using Property = ::love::physics::Joint::BooleanProperty;
	auto *backend = requirePhysicsJointBackend(this);
	std::string error;
	bool success = false;
	if (property == Property::MotorEnabled)
	{
		if (type == "revolute") success = backend->setRevoluteJointMotorEnabled(handle, value, error);
		else if (type == "prismatic") success = backend->setPrismaticJointMotorEnabled(handle, value, error);
		else if (type == "wheel") success = backend->setWheelJointMotorEnabled(handle, value, error);
	}
	else
	{
		if (type == "revolute") success = backend->setRevoluteJointLimitsEnabled(handle, value, error);
		else if (type == "prismatic") success = backend->setPrismaticJointLimitsEnabled(handle, value, error);
	}
	if (!success && error.empty()) error = "method is not supported by this Joint type";
	requirePhysicsResult(success, error);
}

void PhysicsJointUserdata::getVector(::love::physics::Joint::VectorProperty property,
	float &x, float &y) const
{
	using Property = ::love::physics::Joint::VectorProperty;
	auto *backend = requirePhysicsJointBackend(this);
	std::string error;
	bool success = false;
	if (property == Property::Axis)
	{
		if (type == "prismatic") success = backend->getPrismaticJointAxis(handle, x, y, error);
		else if (type == "wheel") success = backend->getWheelJointAxis(handle, x, y, error);
	}
	else if (property == Property::Target)
		success = type == "mouse" && backend->getMouseJointTarget(handle, x, y, error);
	else
		success = type == "motor" && backend->getMotorJointLinearOffset(handle, x, y, error);
	if (!success && error.empty()) error = "method is not supported by this Joint type";
	requirePhysicsResult(success, error);
}

void PhysicsJointUserdata::setVector(::love::physics::Joint::VectorProperty property,
	float x, float y)
{
	using Property = ::love::physics::Joint::VectorProperty;
	auto *backend = requirePhysicsJointBackend(this);
	std::string error;
	bool success = property == Property::Target
		? type == "mouse" && backend->setMouseJointTarget(handle, x, y, error)
		: property == Property::LinearOffset
			? type == "motor" && backend->setMotorJointLinearOffset(handle, x, y, error)
			: false;
	if (!success && error.empty()) error = "method is not supported by this Joint type";
	requirePhysicsResult(success, error);
}

void PhysicsJointUserdata::getLimits(float &lower, float &upper) const
{
	auto *backend = requirePhysicsJointBackend(this);
	std::string error;
	const bool success = type == "revolute"
		? backend->getRevoluteJointLimits(handle, lower, upper, error)
		: type == "prismatic"
			? backend->getPrismaticJointLimits(handle, lower, upper, error) : false;
	if (!success && error.empty()) error = "method is not supported by this Joint type";
	requirePhysicsResult(success, error);
}

void PhysicsJointUserdata::setLimits(float lower, float upper)
{
	auto *backend = requirePhysicsJointBackend(this);
	std::string error;
	const bool success = type == "revolute"
		? backend->setRevoluteJointLimits(handle, lower, upper, error)
		: type == "prismatic"
			? backend->setPrismaticJointLimits(handle, lower, upper, error) : false;
	if (!success && error.empty()) error = "method is not supported by this Joint type";
	requirePhysicsResult(success, error);
}

int PhysicsJointUserdata::getGroundAnchors(lua_State *L) const
{
	if (type != "pulley") throw ::love::Exception("PulleyJoint expected");
	float x1 = 0.0f, y1 = 0.0f, x2 = 0.0f, y2 = 0.0f;
	std::string error;
	requirePhysicsResult(requirePhysicsJointBackend(this)->getPulleyJointGroundAnchors(
		handle, x1, y1, x2, y2, error), error);
	lua_pushnumber(L, x1); lua_pushnumber(L, y1);
	lua_pushnumber(L, x2); lua_pushnumber(L, y2);
	return 4;
}

void PhysicsJointUserdata::getJoints(::love::physics::Joint *&jointA,
	::love::physics::Joint *&jointB) const
{
	if (type != "gear") throw ::love::Exception("GearJoint expected");
	requirePhysicsJointBackend(this);
	jointA = jointAObject.get();
	jointB = jointBObject.get();
}


static PhysicsBackend *requirePhysicsContactBackend(const PhysicsContactUserdata *contact)
{
	auto *backend = contact && contact->runtime ? contact->runtime->getPhysicsBackend() : nullptr;
	if (!backend || !contact->handle || !backend->isContactValid(contact->handle))
		throw ::love::Exception("Contact is invalid");
	return backend;
}

bool PhysicsContactUserdata::isValid() const
{
	auto *backend = runtime ? runtime->getPhysicsBackend() : nullptr;
	return backend && handle && backend->isContactValid(handle);
}
int PhysicsContactUserdata::getPositions(lua_State *L)
{
	std::vector<float> values; std::string error;
	requirePhysicsResult(requirePhysicsContactBackend(this)->getContactPositions(handle, values, error), error);
	for (float value : values) lua_pushnumber(L, value); return static_cast<int>(values.size());
}
int PhysicsContactUserdata::getNormal(lua_State *L)
{
	float x = 0, y = 0; std::string error;
	requirePhysicsResult(requirePhysicsContactBackend(this)->getContactNormal(handle, x, y, error), error);
	lua_pushnumber(L, x); lua_pushnumber(L, y); return 2;
}
float PhysicsContactUserdata::getFriction() const
{
	float value = 0; std::string error; requirePhysicsResult(requirePhysicsContactBackend(this)->getContactFriction(handle, value, error), error); return value;
}
float PhysicsContactUserdata::getRestitution() const
{
	float value = 0; std::string error; requirePhysicsResult(requirePhysicsContactBackend(this)->getContactRestitution(handle, value, error), error); return value;
}
bool PhysicsContactUserdata::isEnabled() const
{
	bool value = false; std::string error; requirePhysicsResult(requirePhysicsContactBackend(this)->isContactEnabled(handle, value, error), error); return value;
}
bool PhysicsContactUserdata::isTouching() const
{
	bool value = false; std::string error; requirePhysicsResult(requirePhysicsContactBackend(this)->isContactTouching(handle, value, error), error); return value;
}
void PhysicsContactUserdata::setFriction(float value)
{
	if (!std::isfinite(value) || value < 0.0f) throw ::love::Exception("friction must be finite and non-negative");
	std::string error; requirePhysicsResult(requirePhysicsContactBackend(this)->setContactFriction(handle, value, error), error);
}
void PhysicsContactUserdata::setRestitution(float value)
{
	if (!std::isfinite(value)) throw ::love::Exception("restitution must be finite");
	std::string error; requirePhysicsResult(requirePhysicsContactBackend(this)->setContactRestitution(handle, value, error), error);
}
void PhysicsContactUserdata::setEnabled(bool value)
{
	std::string error; requirePhysicsResult(requirePhysicsContactBackend(this)->setContactEnabled(handle, value, error), error);
}
void PhysicsContactUserdata::resetFriction()
{
	std::string error; requirePhysicsResult(requirePhysicsContactBackend(this)->resetContactFriction(handle, error), error);
}
void PhysicsContactUserdata::resetRestitution()
{
	std::string error; requirePhysicsResult(requirePhysicsContactBackend(this)->resetContactRestitution(handle, error), error);
}
void PhysicsContactUserdata::setTangentSpeed(float value)
{
	if (!std::isfinite(value)) throw ::love::Exception("tangent speed must be finite");
	std::string error; requirePhysicsResult(requirePhysicsContactBackend(this)->setContactTangentSpeed(handle, value, error), error);
}
float PhysicsContactUserdata::getTangentSpeed() const
{
	float value = 0; std::string error; requirePhysicsResult(requirePhysicsContactBackend(this)->getContactTangentSpeed(handle, value, error), error); return value;
}
void PhysicsContactUserdata::getChildren(int &a, int &b)
{
	requirePhysicsContactBackend(this); a = childA; b = childB;
}
void PhysicsContactUserdata::getFixtures(::love::physics::Fixture *&a, ::love::physics::Fixture *&b)
{
	requirePhysicsContactBackend(this);
	if (!fixtureAObject || !fixtureBObject) throw ::love::Exception("Contact references a closed Fixture");
	a = fixtureAObject.get(); b = fixtureBObject.get();
}

double DoraLoveTimer::step()
{
	return _runtime ? _runtime->_timerDelta : 0.0;
}

double DoraLoveTimer::getDelta() const
{
	return _runtime ? _runtime->_timerDelta : 0.0;
}

int DoraLoveTimer::getFPS() const
{
	return _runtime ? _runtime->_timerFPS : 0;
}

double DoraLoveTimer::getAverageDelta() const
{
	return _runtime ? _runtime->_timerAverageDelta : 0.0;
}

void DoraLoveTimer::sleep(double seconds) const
{
	if (!std::isfinite(seconds))
		throw ::love::Exception("sleep duration must be finite");
	if (seconds > 0.0)
		std::this_thread::sleep_for(std::chrono::duration<double>(seconds));
}

double DoraLoveTimer::getTime() const
{
	return _runtime ? steadySeconds() - _runtime->_timerOrigin : 0.0;
}

int LoveRuntime::audioNewSource(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	if (auto *soundData = testSoundData(state, 1))
	{
		if (runtime == nullptr || runtime->_audioBackend == nullptr)
			return luaL_error(state, "Love audio is not attached to Dora SoLoud");
		std::string error;
		const auto handle = runtime->_audioBackend->newSourceFromSoundData(
			{static_cast<const char *>(soundData->getData()), soundData->getSize()},
			soundData->getSampleRate(), soundData->getBitDepth(),
			soundData->getChannelCount(), error);
		if (handle == 0)
			return luaL_error(state, "Love audio Source from SoundData creation failed: %s",
				error.empty() ? "failed to create Dora SoLoud source" : error.c_str());
		pushAudioSource(state, runtime, handle, false);
		return 1;
	}
	const std::string filename = luaL_checkstring(state, 1);
	const std::string_view sourceType = luaL_optstring(state, 2, "static");
	if (sourceType != "static" && sourceType != "stream")
		return luaL_argerror(state, 2, "expected 'static' or 'stream'");
	if (runtime == nullptr || runtime->_audioBackend == nullptr)
		return luaL_error(state, "Love audio is not attached to Dora SoLoud");
	std::string resolvedPath;
	std::string error;
	if (!runtime->resolveReadPath(filename, resolvedPath, error))
		return luaL_error(state, "Love audio Source '%s' (%s) resolution failed: %s",
			filename.c_str(), std::string(sourceType).c_str(), error.c_str());
	const auto handle = runtime->_audioBackend->newSource(resolvedPath, sourceType, error);
	if (handle == 0)
		return luaL_error(state, "Love audio Source '%s' (%s) creation failed: %s",
			filename.c_str(), std::string(sourceType).c_str(),
			error.empty() ? "failed to create Dora SoLoud source" : error.c_str());
	pushAudioSource(state, runtime, handle, sourceType == "stream");
	return 1;
}

int LoveRuntime::audioNewQueueableSource(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const lua_Integer sampleRate = luaL_checkinteger(state, 1);
	const lua_Integer bitDepth = luaL_checkinteger(state, 2);
	const lua_Integer channels = luaL_checkinteger(state, 3);
	const lua_Integer buffers = luaL_optinteger(state, 4, 0);
	luaL_argcheck(state, sampleRate > 0 && sampleRate <= std::numeric_limits<int>::max(), 1,
		"sample rate must be a positive integer");
	luaL_argcheck(state, bitDepth == 8 || bitDepth == 16, 2,
		"bit depth must be 8 or 16");
	luaL_argcheck(state, channels == 1 || channels == 2, 3,
		"channel count must be 1 or 2");
	luaL_argcheck(state, buffers >= std::numeric_limits<int>::min()
		&& buffers <= std::numeric_limits<int>::max(), 4, "buffer count is out of range");
	if (runtime == nullptr || runtime->_audioBackend == nullptr)
		return luaL_error(state, "Love audio is not attached to Dora SoLoud");
	std::string error;
	const auto handle = runtime->_audioBackend->newQueueableSource(
		static_cast<int>(sampleRate), static_cast<int>(bitDepth),
		static_cast<int>(channels), static_cast<int>(buffers), error);
	if (handle == 0)
		return luaL_error(state, "Love queueable Source creation failed: %s",
			error.empty() ? "failed to create Dora SoLoud PCM queue" : error.c_str());
	pushAudioSource(state, runtime, handle, false, true);
	return 1;
}

int LoveRuntime::audioPlay(lua_State *state)
{
	const int count = lua_gettop(state);
	luaL_argcheck(state, count > 0, 1, "expected at least one Source");
	bool played = true;
	const bool tableInput = lua_istable(state, 1);
	const int sourceCount = tableInput ? static_cast<int>(lua_rawlen(state, 1)) : count;
	for (int index = 1; index <= sourceCount; ++index)
	{
		if (tableInput) lua_rawgeti(state, 1, index);
		auto *source = checkAudioSource(state, tableInput ? -1 : index);
		luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
			&& source->runtime->_audioHandles.contains(source->handle),
			tableInput ? 1 : index, "closed Source");
		played = source->runtime->_audioBackend->playSource(source->handle) && played;
		if (tableInput) lua_pop(state, 1);
	}
	lua_pushboolean(state, played);
	return 1;
}

int LoveRuntime::audioPause(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const int count = lua_gettop(state);
	if (count == 0)
	{
		lua_createtable(state, runtime ? static_cast<int>(runtime->_audioHandles.size()) : 0, 0);
		int pausedCount = 0;
		if (runtime && runtime->_audioBackend)
		{
			for (const auto handle : runtime->_audioHandles)
			{
				if (!runtime->_audioBackend->isSourcePlaying(handle)) continue;
				runtime->_audioBackend->pauseSource(handle, true);
				if (pushAudioSourceByHandle(state, handle))
					lua_rawseti(state, -2, ++pausedCount);
			}
		}
		return 1;
	}
	const bool tableInput = lua_istable(state, 1);
	const int sourceCount = tableInput ? static_cast<int>(lua_rawlen(state, 1)) : count;
	for (int index = 1; index <= sourceCount; ++index)
	{
		if (tableInput) lua_rawgeti(state, 1, index);
		auto *source = checkAudioSource(state, tableInput ? -1 : index);
		luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
			&& source->runtime->_audioHandles.contains(source->handle),
			tableInput ? 1 : index, "closed Source");
		source->runtime->_audioBackend->pauseSource(source->handle, true);
		if (tableInput) lua_pop(state, 1);
	}
	return 0;
}

int LoveRuntime::audioStop(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const int count = lua_gettop(state);
	if (count == 0)
	{
		if (runtime && runtime->_audioBackend)
			for (const auto handle : runtime->_audioHandles)
				runtime->_audioBackend->stopSource(handle);
		return 0;
	}
	const bool tableInput = lua_istable(state, 1);
	const int sourceCount = tableInput ? static_cast<int>(lua_rawlen(state, 1)) : count;
	for (int index = 1; index <= sourceCount; ++index)
	{
		if (tableInput) lua_rawgeti(state, 1, index);
		auto *source = checkAudioSource(state, tableInput ? -1 : index);
		luaL_argcheck(state, source->runtime && source->runtime->_audioBackend
			&& source->runtime->_audioHandles.contains(source->handle),
			tableInput ? 1 : index, "closed Source");
		source->runtime->_audioBackend->stopSource(source->handle);
		if (tableInput) lua_pop(state, 1);
	}
	return 0;
}

int LoveRuntime::audioSetVolume(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float volume = static_cast<float>(luaL_checknumber(state, 1));
	luaL_argcheck(state, std::isfinite(volume) && volume >= 0.0f && volume <= 1.0f, 1,
		"volume must be between 0 and 1");
	runtime->_audioVolume = volume;
	if (runtime->_audioBackend)
		runtime->_audioBackend->setInstanceVolume(volume);
	return 0;
}

int LoveRuntime::audioGetActiveSourceCount(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_Integer count = 0;
	if (runtime && runtime->_audioBackend)
	{
		for (const auto handle : runtime->_audioHandles)
		{
			if (runtime->_audioBackend->isSourcePlaying(handle)
				|| runtime->_audioBackend->isSourcePaused(handle))
				++count;
		}
	}
	lua_pushinteger(state, count);
	return 1;
}

int LoveRuntime::audioGetVolume(lua_State *state)
{
	lua_pushnumber(state, runtimeFromUpvalue(state)->_audioVolume);
	return 1;
}

int LoveRuntime::audioSetMixWithSystem(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	luaL_checktype(state, 1, LUA_TBOOLEAN);
	lua_pushboolean(state, runtime && runtime->_audioBackend
		&& runtime->_audioBackend->setMixWithSystem(lua_toboolean(state, 1) != 0));
	return 1;
}

int LoveRuntime::audioSetPosition(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float x = static_cast<float>(luaL_checknumber(state, 1));
	const float y = static_cast<float>(luaL_checknumber(state, 2));
	const float z = static_cast<float>(luaL_optnumber(state, 3, 0.0));
	luaL_argcheck(state, std::isfinite(x), 1, "listener x must be finite");
	luaL_argcheck(state, std::isfinite(y), 2, "listener y must be finite");
	luaL_argcheck(state, std::isfinite(z), 3, "listener z must be finite");
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->setListenerPosition(x, y, z);
	return 0;
}

int LoveRuntime::audioGetPosition(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	float x = 0.0f, y = 0.0f, z = 0.0f;
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->getListenerPosition(x, y, z);
	lua_pushnumber(state, x);
	lua_pushnumber(state, y);
	lua_pushnumber(state, z);
	return 3;
}

int LoveRuntime::audioSetOrientation(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	float values[6];
	for (int index = 0; index < 6; ++index)
	{
		values[index] = static_cast<float>(luaL_checknumber(state, index + 1));
		luaL_argcheck(state, std::isfinite(values[index]), index + 1,
			"listener orientation values must be finite");
	}
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->setListenerOrientation(values[0], values[1], values[2],
			values[3], values[4], values[5]);
	return 0;
}

int LoveRuntime::audioGetOrientation(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	float forwardX = 0.0f, forwardY = 0.0f, forwardZ = 1.0f;
	float upX = 0.0f, upY = 1.0f, upZ = 0.0f;
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->getListenerOrientation(forwardX, forwardY, forwardZ,
			upX, upY, upZ);
	lua_pushnumber(state, forwardX);
	lua_pushnumber(state, forwardY);
	lua_pushnumber(state, forwardZ);
	lua_pushnumber(state, upX);
	lua_pushnumber(state, upY);
	lua_pushnumber(state, upZ);
	return 6;
}

int LoveRuntime::audioSetVelocity(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float x = static_cast<float>(luaL_checknumber(state, 1));
	const float y = static_cast<float>(luaL_checknumber(state, 2));
	const float z = static_cast<float>(luaL_optnumber(state, 3, 0.0));
	luaL_argcheck(state, std::isfinite(x), 1, "listener velocity x must be finite");
	luaL_argcheck(state, std::isfinite(y), 2, "listener velocity y must be finite");
	luaL_argcheck(state, std::isfinite(z), 3, "listener velocity z must be finite");
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->setListenerVelocity(x, y, z);
	return 0;
}

int LoveRuntime::audioGetVelocity(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	float x = 0.0f, y = 0.0f, z = 0.0f;
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->getListenerVelocity(x, y, z);
	lua_pushnumber(state, x);
	lua_pushnumber(state, y);
	lua_pushnumber(state, z);
	return 3;
}

int LoveRuntime::audioSetDopplerScale(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const float scale = static_cast<float>(luaL_checknumber(state, 1));
	// Love's OpenAL backend silently ignores values below zero. Keep that
	// observable behavior and also reject non-finite values at the backend edge.
	if (runtime && runtime->_audioBackend && std::isfinite(scale) && scale >= 0.0f)
		runtime->_audioBackend->setDopplerScale(scale);
	return 0;
}

int LoveRuntime::audioGetDopplerScale(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, runtime && runtime->_audioBackend
		? runtime->_audioBackend->getDopplerScale() : 1.0f);
	return 1;
}

int LoveRuntime::audioSetDistanceModel(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string_view model = luaL_checkstring(state, 1);
	if (model != "none" && model != "inverse" && model != "inverseclamped"
		&& model != "linear" && model != "linearclamped"
		&& model != "exponent" && model != "exponentclamped")
	{
		return luaL_argerror(state, 1,
			"expected 'none', 'inverse', 'inverseclamped', 'linear', "
			"'linearclamped', 'exponent', or 'exponentclamped'");
	}
	if (runtime && runtime->_audioBackend)
		runtime->_audioBackend->setDistanceModel(model);
	return 0;
}

int LoveRuntime::audioGetDistanceModel(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string model = runtime && runtime->_audioBackend
		? runtime->_audioBackend->getDistanceModel() : "inverseclamped";
	lua_pushlstring(state, model.data(), model.size());
	return 1;
}

namespace
{
enum class AudioParameterKind { Invalid, Number, Boolean, Waveform };

bool hasAudioParameter(std::string_view key, std::initializer_list<std::string_view> parameters)
{
	return std::find(parameters.begin(), parameters.end(), key) != parameters.end();
}

AudioParameterKind effectParameterKind(std::string_view type, std::string_view key)
{
	if (key == "volume") return AudioParameterKind::Number;
	if ((type == "reverb" && hasAudioParameter(key, {"gain", "highgain", "density", "diffusion",
		"decaytime", "decayhighratio", "earlygain", "earlydelay", "lategain", "latedelay",
		"roomrolloff", "airabsorption"}))
		|| ((type == "chorus" || type == "flanger") && hasAudioParameter(key,
			{"phase", "rate", "depth", "feedback", "delay"}))
		|| (type == "distortion" && hasAudioParameter(key,
			{"gain", "edge", "lowcut", "center", "bandwidth"}))
		|| (type == "echo" && hasAudioParameter(key,
			{"delay", "tapdelay", "damping", "feedback", "spread"}))
		|| (type == "ringmodulator" && hasAudioParameter(key, {"frequency", "highcut"}))
		|| (type == "equalizer" && hasAudioParameter(key,
			{"lowgain", "lowcut", "lowmidgain", "lowmidfrequency", "lowmidbandwidth",
				"highmidgain", "highmidfrequency", "highmidbandwidth", "highgain", "highcut"})))
		return AudioParameterKind::Number;
	if ((type == "reverb" && key == "highlimit") || (type == "compressor" && key == "enable"))
		return AudioParameterKind::Boolean;
	if ((type == "chorus" || type == "flanger" || type == "ringmodulator") && key == "waveform")
		return AudioParameterKind::Waveform;
	return AudioParameterKind::Invalid;
}

bool validEffectType(std::string_view type)
{
	return hasAudioParameter(type, {"reverb", "chorus", "distortion", "echo", "flanger",
		"ringmodulator", "compressor", "equalizer"});
}

AudioParameterKind filterParameterKind(std::string_view type, std::string_view key)
{
	if (key == "volume") return AudioParameterKind::Number;
	if ((type == "lowpass" && key == "highgain") || (type == "highpass" && key == "lowgain")
		|| (type == "bandpass" && (key == "lowgain" || key == "highgain")))
		return AudioParameterKind::Number;
	return AudioParameterKind::Invalid;
}

float waveformValue(lua_State *state, int index)
{
	const std::string_view waveform = luaL_checkstring(state, index);
	if (waveform == "sine") return 0.0f;
	if (waveform == "triangle") return 1.0f;
	if (waveform == "sawtooth") return 2.0f;
	if (waveform == "square") return 3.0f;
	luaL_error(state, "invalid audio effect waveform '%s'", std::string(waveform).c_str());
	return 0.0f;
}

const char *waveformName(float value)
{
	switch (static_cast<int>(value))
	{
		case 1: return "triangle";
		case 2: return "sawtooth";
		case 3: return "square";
		default: return "sine";
	}
}

template <class Settings, class ParameterKind>
Settings readAudioSettings(lua_State *state, int index, bool effect, ParameterKind parameterKind)
{
	index = lua_absindex(state, index);
	luaL_checktype(state, index, LUA_TTABLE);
	lua_getfield(state, index, "type");
	if (!lua_isstring(state, -1)) luaL_error(state, "%s type not specified", effect ? "Effect" : "Filter");
	Settings settings;
	settings.type = lua_tostring(state, -1);
	lua_pop(state, 1);
	if ((effect && !validEffectType(settings.type))
		|| (!effect && settings.type != "lowpass" && settings.type != "highpass" && settings.type != "bandpass"))
		luaL_error(state, "invalid %s type '%s'", effect ? "effect" : "filter", settings.type.c_str());
	lua_pushnil(state);
	while (lua_next(state, index) != 0)
	{
		if (!lua_isstring(state, -2)) luaL_error(state, "%s parameter names must be strings",
			effect ? "Effect" : "Filter");
		const std::string key = lua_tostring(state, -2);
		if (key != "type")
		{
			const AudioParameterKind kind = parameterKind(settings.type, key);
			if (kind == AudioParameterKind::Invalid)
				luaL_error(state, "invalid '%s' %s parameter: %s", settings.type.c_str(),
					effect ? "Effect" : "Filter", key.c_str());
			float value = 0.0f;
			if (kind == AudioParameterKind::Number)
			{
				value = static_cast<float>(luaL_checknumber(state, -1));
				if (!std::isfinite(value)) luaL_error(state, "%s parameter '%s' must be finite",
					effect ? "Effect" : "Filter", key.c_str());
			}
			else if (kind == AudioParameterKind::Boolean)
			{
				if (!lua_isboolean(state, -1)) luaL_error(state, "%s parameter '%s' must be boolean",
					effect ? "Effect" : "Filter", key.c_str());
				value = lua_toboolean(state, -1) ? 1.0f : 0.0f;
			}
			else value = waveformValue(state, -1);
			settings.parameters[key] = value;
		}
		lua_pop(state, 1);
	}
	return settings;
}

void pushAudioSettings(lua_State *state, int target,
	const std::string &type, const std::map<std::string, float> &parameters, bool effect)
{
	if (target > 0 && lua_istable(state, target)) lua_pushvalue(state, target);
	else lua_createtable(state, 0, static_cast<int>(parameters.size() + 1));
	lua_pushlstring(state, type.data(), type.size());
	lua_setfield(state, -2, "type");
	for (const auto &[key, value] : parameters)
	{
		const auto kind = effect ? effectParameterKind(type, key) : filterParameterKind(type, key);
		if (kind == AudioParameterKind::Boolean) lua_pushboolean(state, value > 0.5f);
		else if (kind == AudioParameterKind::Waveform) lua_pushstring(state, waveformName(value));
		else lua_pushnumber(state, value);
		lua_setfield(state, -2, key.c_str());
	}
}
}

int LoveRuntime::audioSetEffect(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string name = luaL_checkstring(state, 1);
	const bool remove = lua_isnoneornil(state, 2)
		|| (lua_isboolean(state, 2) && lua_toboolean(state, 2) == 0);
	std::string error;
	if (!runtime || !runtime->_audioBackend)
	{
		lua_pushboolean(state, false);
		return 1;
	}
	if (remove)
	{
		const bool existed = runtime->_audioEffects.erase(name) != 0;
		for (auto &[_, effects] : runtime->_audioSourceEffects) effects.erase(name);
		if (!runtime->_audioBackend->setEffect(name, nullptr, error) && !error.empty())
			return luaL_error(state, "%s", error.c_str());
		lua_pushboolean(state, existed);
		return 1;
	}
	auto settings = readAudioSettings<AudioBackend::EffectSettings>(state, 2, true, effectParameterKind);
	if (!runtime->_audioBackend->setEffect(name, &settings, error))
	{
		if (!error.empty()) return luaL_error(state, "%s", error.c_str());
		lua_pushboolean(state, false);
		return 1;
	}
	runtime->_audioEffects[name] = std::move(settings);
	lua_pushboolean(state, true);
	return 1;
}

int LoveRuntime::audioGetEffect(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string name = luaL_checkstring(state, 1);
	if (!runtime) return 0;
	const auto found = runtime->_audioEffects.find(name);
	if (found == runtime->_audioEffects.end()) return 0;
	pushAudioSettings(state, 2, found->second.type, found->second.parameters, true);
	return 1;
}

int LoveRuntime::audioGetActiveEffects(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_createtable(state, runtime ? static_cast<int>(runtime->_audioEffects.size()) : 0, 0);
	int index = 1;
	if (runtime) for (const auto &[name, _] : runtime->_audioEffects)
	{
		lua_pushlstring(state, name.data(), name.size());
		lua_rawseti(state, -2, index++);
	}
	return 1;
}

int LoveRuntime::audioGetMaxSceneEffects(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, runtime && runtime->_audioBackend
		? runtime->_audioBackend->getMaxSceneEffects() : 0);
	return 1;
}

int LoveRuntime::audioGetMaxSourceEffects(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushnumber(state, runtime && runtime->_audioBackend
		? runtime->_audioBackend->getMaxSourceEffects() : 0);
	return 1;
}

int LoveRuntime::audioGetRecordingDevices(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_newtable(state);
	if (!runtime || !runtime->_audioBackend) return 1;
	const auto names = runtime->_audioBackend->getRecordingDeviceNames();
	int index = 1;
	for (const auto &name : names)
	{
		pushRecordingDevice(state, runtime, name);
		lua_rawseti(state, -2, index++);
	}
	return 1;
}

int LoveRuntime::recordingDeviceEqual(lua_State *state)
{
	lua_pushboolean(state, checkRecordingDevice(state, 1) == checkRecordingDevice(state, 2));
	return 1;
}

int LoveRuntime::recordingDeviceStart(lua_State *state)
{
	auto *device = checkRecordingDevice(state, 1);
	auto *backend = device->runtime ? device->runtime->_audioBackend : nullptr;
	if (!backend)
	{
		lua_pushboolean(state, false);
		return 1;
	}

	int maxSamples = device->maxSamples;
	int sampleRate = device->sampleRate;
	int bitDepth = device->bitDepth;
	int channels = device->channels;
	if (lua_gettop(state) > 1)
	{
		const lua_Integer requestedSamples = luaL_checkinteger(state, 2);
		const lua_Integer requestedRate = luaL_optinteger(state, 3, 8000);
		const lua_Integer requestedDepth = luaL_optinteger(state, 4, 16);
		const lua_Integer requestedChannels = luaL_optinteger(state, 5, 1);
		luaL_argcheck(state, requestedSamples > 0 && requestedSamples <= std::numeric_limits<int>::max(),
			2, "number of samples must be a positive 32-bit integer");
		luaL_argcheck(state, requestedRate > 0 && requestedRate <= std::numeric_limits<int>::max(),
			3, "sample rate must be a positive 32-bit integer");
		luaL_argcheck(state, requestedDepth == 8 || requestedDepth == 16, 4,
			"bit depth must be 8 or 16");
		luaL_argcheck(state, requestedChannels == 1 || requestedChannels == 2, 5,
			"channel count must be 1 or 2");
		maxSamples = static_cast<int>(requestedSamples);
		sampleRate = static_cast<int>(requestedRate);
		bitDepth = static_cast<int>(requestedDepth);
		channels = static_cast<int>(requestedChannels);
		const std::size_t bytesPerFrame = static_cast<std::size_t>(bitDepth / 8 * channels);
		luaL_argcheck(state, static_cast<std::size_t>(maxSamples) <= MaximumSoundDataBytes / bytesPerFrame,
			2, "recording buffer cannot exceed 256 MiB");
	}

	if (device->handle != 0) device->releaseDoraHandle();
	std::string error;
	const auto handle = backend->startRecording(device->name, maxSamples,
		sampleRate, bitDepth, channels, error);
	if (!error.empty()) return luaL_error(state, "Love RecordingDevice start failed: %s", error.c_str());
	if (handle != 0)
	{
		device->replaceDoraHandle(handle);
		device->maxSamples = maxSamples;
		device->sampleRate = sampleRate;
		device->bitDepth = bitDepth;
		device->channels = channels;
	}
	lua_pushboolean(state, handle != 0);
	return 1;
}

int LoveRuntime::recordingDeviceGetData(lua_State *state)
{
	auto *device = checkRecordingDevice(state, 1);
	auto *backend = device->runtime ? device->runtime->_audioBackend : nullptr;
	if (!backend || device->handle == 0)
	{
		lua_pushnil(state);
		return 1;
	}
	std::vector<std::uint8_t> pcm;
	std::string error;
	if (!backend->getRecordingData(device->handle, pcm, error))
		return luaL_error(state, "Love RecordingDevice read failed: %s", error.c_str());
	if (pcm.empty())
	{
		lua_pushnil(state);
		return 1;
	}
	const std::size_t bytesPerFrame = static_cast<std::size_t>(device->bitDepth / 8 * device->channels);
	pushSoundData(state, device->sampleRate, device->bitDepth, device->channels,
		static_cast<int>(pcm.size() / bytesPerFrame), std::move(pcm));
	return 1;
}

int LoveRuntime::recordingDeviceStop(lua_State *state)
{
	auto *device = checkRecordingDevice(state, 1);
	recordingDeviceGetData(state);
	if (device->handle != 0 && device->runtime && device->runtime->_audioBackend)
		device->releaseDoraHandle();
	device->invalidateDoraHandle();
	return 1;
}

int LoveRuntime::recordingDeviceGetSampleCount(lua_State *state)
{
	auto *device = checkRecordingDevice(state, 1);
	const int count = device->handle != 0 && device->runtime && device->runtime->_audioBackend
		? device->runtime->_audioBackend->getRecordingSampleCount(device->handle) : 0;
	lua_pushinteger(state, count);
	return 1;
}

int LoveRuntime::recordingDeviceGetSampleRate(lua_State *state)
{
	lua_pushinteger(state, checkRecordingDevice(state, 1)->sampleRate);
	return 1;
}

int LoveRuntime::recordingDeviceGetBitDepth(lua_State *state)
{
	lua_pushinteger(state, checkRecordingDevice(state, 1)->bitDepth);
	return 1;
}

int LoveRuntime::recordingDeviceGetChannelCount(lua_State *state)
{
	lua_pushinteger(state, checkRecordingDevice(state, 1)->channels);
	return 1;
}

int LoveRuntime::recordingDeviceGetName(lua_State *state)
{
	const auto &name = checkRecordingDevice(state, 1)->name;
	lua_pushlstring(state, name.data(), name.size());
	return 1;
}

int LoveRuntime::recordingDeviceIsRecording(lua_State *state)
{
	lua_pushboolean(state, checkRecordingDevice(state, 1)->handle != 0);
	return 1;
}

int LoveRuntime::audioIsEffectsSupported(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	lua_pushboolean(state, runtime && runtime->_audioBackend
		&& runtime->_audioBackend->isEffectsSupported());
	return 1;
}

int LoveRuntime::audioSourceEqual(lua_State *state)
{
	auto *left = testAudioSource(state, 1);
	auto *right = testAudioSource(state, 2);
	lua_pushboolean(state, left && right && left->runtime == right->runtime && left->handle == right->handle);
	return 1;
}

void DoraLoveEvent::pump()
{
	if (!_runtime) throw ::love::Exception("Love runtime is unavailable");
	_runtime->drainThreadErrors();
}

bool DoraLoveEvent::poll(::love::event::Message *&message)
{
	message = nullptr;
	if (!_runtime || !_state) return false;
	const int base = lua_gettop(_state);
	const int count = _runtime->pollQueuedEvent(_state);
	if (count == 0) return false;
	try
	{
		message = ::love::event::Message::fromLua(_state, base + 1);
		lua_settop(_state, base);
		return message != nullptr;
	}
	catch (...)
	{
		lua_settop(_state, base);
		throw;
	}
}

::love::event::Message *DoraLoveEvent::wait()
{
	pump();
	::love::event::Message *message = nullptr;
	poll(message);
	return message;
}

void DoraLoveEvent::push(::love::event::Message *message)
{
	if (!_runtime || !_state || !message)
		throw ::love::Exception("Love runtime is unavailable");
	if (message->name.find('\0') != std::string::npos)
		throw ::love::Exception("event name cannot contain NUL bytes");
	const int base = lua_gettop(_state);
	message->toLua(_state);
	const int argumentCount = (int) message->args.size();
	lua_createtable(_state, argumentCount, 0);
	const int arguments = lua_gettop(_state);
	for (int index = 0; index < argumentCount; ++index)
	{
		lua_pushvalue(_state, base + index + 2);
		lua_rawseti(_state, arguments, index + 1);
	}
	LoveRuntime::QueuedEvent event{LoveRuntime::QueuedEventType::Custom};
	event.first = message->name;
	event.presses = argumentCount;
	event.registryReference = luaL_ref(_state, LUA_REGISTRYINDEX);
	_runtime->_eventQueue.push_back(std::move(event));
	lua_settop(_state, base);
}

void DoraLoveEvent::clear()
{
	if (_runtime) _runtime->clearQueuedEvents();
}

void DoraLoveWindow::checkDisplay(int displayIndex) const
{
	if (displayIndex != 0)
		throw ::love::Exception("embedded LoveNode exposes only virtual display 1");
}

bool DoraLoveWindow::setWindow(int width, int height, ::love::window::WindowSettings *settings)
{
	if (!_runtime || !_runtime->_graphicsBackend || width < 1 || height < 1
		|| width > MaximumWindowDimension || height > MaximumWindowDimension)
		return false;
	auto next = settings ? *settings : ::love::window::WindowSettings {};
	if (next.fullscreen || next.highdpi || next.display != 0)
		return false;
	std::string error;
	if (!_runtime->_graphicsBackend->setMode(width, height, error))
		return false;
	_settings = next;
	_runtime->_configuredWidth = width;
	_runtime->_configuredHeight = height;
	_runtime->_windowResizable = next.resizable;
	_runtime->_windowVSync = next.vsync;
	_open = true;
	return true;
}

void DoraLoveWindow::getWindow(int &width, int &height, ::love::window::WindowSettings &settings)
{
	width = getWidth();
	height = getHeight();
	_settings.resizable = _runtime && _runtime->_windowResizable;
	_settings.vsync = _runtime ? _runtime->_windowVSync : 1;
	settings = _settings;
}

bool DoraLoveWindow::setFullscreen(bool fullscreen, FullscreenType type)
{
	if (type != FULLSCREEN_DESKTOP && type != FULLSCREEN_EXCLUSIVE)
		throw ::love::Exception("invalid fullscreen type");
	if (fullscreen)
		return false;
	_settings.fullscreen = false;
	_settings.fstype = type;
	return true;
}

const char *DoraLoveWindow::getDisplayName(int displayIndex) const
{
	checkDisplay(displayIndex);
	return "Dora LoveNode";
}

DoraLoveWindow::DisplayOrientation DoraLoveWindow::getDisplayOrientation(int displayIndex) const
{
	checkDisplay(displayIndex);
	if (getWidth() > getHeight()) return ORIENTATION_LANDSCAPE;
	if (getHeight() > getWidth()) return ORIENTATION_PORTRAIT;
	return ORIENTATION_UNKNOWN;
}

std::vector<DoraLoveWindow::WindowSize> DoraLoveWindow::getFullscreenSizes(int displayIndex) const
{
	checkDisplay(displayIndex);
	return {};
}

void DoraLoveWindow::getDesktopDimensions(int displayIndex, int &width, int &height) const
{
	checkDisplay(displayIndex);
	width = getWidth();
	height = getHeight();
}

void DoraLoveWindow::setPosition(int x, int y, int displayIndex)
{
	checkDisplay(displayIndex);
	_settings.x = x;
	_settings.y = y;
	_settings.display = displayIndex;
	_settings.useposition = true;
}

void DoraLoveWindow::getPosition(int &x, int &y, int &displayIndex)
{
	x = _settings.x;
	y = _settings.y;
	displayIndex = 0;
}

::love::Rect DoraLoveWindow::getSafeArea() const
{
	return {0, 0, getWidth(), getHeight()};
}

bool DoraLoveWindow::isOpen() const
{
	return _open && _runtime && _runtime->_graphicsBackend
		&& _runtime->_status != LoveRuntime::Status::Closed
		&& _runtime->_status != LoveRuntime::Status::Faulted
		&& _runtime->_status != LoveRuntime::Status::Stopped;
}

void DoraLoveWindow::setWindowTitle(const std::string &title)
{
	if (_runtime) _runtime->_windowTitle = title;
}

const std::string &DoraLoveWindow::getWindowTitle() const
{
	static const std::string empty;
	return _runtime ? _runtime->_windowTitle : empty;
}

bool DoraLoveWindow::setIcon(::love::image::ImageData *image)
{
	if (!image || image->getWidth() <= 0 || image->getHeight() <= 0)
		throw ::love::Exception("window icon ImageData must have positive dimensions");
	_icon.set(image);
	return true;
}

void DoraLoveWindow::setVSync(int vsync)
{
	if (vsync < -1 || vsync > 1)
		throw ::love::Exception("virtual VSync mode must be -1, 0, or 1");
	if (_runtime) _runtime->_windowVSync = vsync;
	_settings.vsync = vsync;
}

int DoraLoveWindow::getVSync() const
{
	return _runtime ? _runtime->_windowVSync : 1;
}

void DoraLoveWindow::setDisplaySleepEnabled(bool enable)
{
	if (_runtime) _runtime->_windowDisplaySleepEnabled = enable;
}

bool DoraLoveWindow::isDisplaySleepEnabled() const
{
	return _runtime && _runtime->_windowDisplaySleepEnabled;
}

bool DoraLoveWindow::hasFocus() const
{
	return _runtime && _runtime->_graphicsBackend
		&& _runtime->_graphicsBackend->hasWindowFocus();
}

bool DoraLoveWindow::hasMouseFocus() const
{
	return _runtime && _runtime->_graphicsBackend
		&& _runtime->_graphicsBackend->hasWindowMouseFocus();
}

bool DoraLoveWindow::isVisible() const
{
	return _runtime && _runtime->_graphicsBackend
		&& _runtime->_graphicsBackend->isWindowVisible();
}

void DoraLoveWindow::setMouseGrab(bool grab)
{
	if (_runtime) _runtime->_mouseGrabbed = grab;
}

bool DoraLoveWindow::isMouseGrabbed() const
{
	return _runtime && _runtime->_mouseGrabbed;
}

int DoraLoveWindow::getWidth() const
{
	return _runtime && _runtime->_graphicsBackend
		? _runtime->_graphicsBackend->getPixelWidth()
		: (_runtime ? _runtime->_configuredWidth : 0);
}

int DoraLoveWindow::getHeight() const
{
	return _runtime && _runtime->_graphicsBackend
		? _runtime->_graphicsBackend->getPixelHeight()
		: (_runtime ? _runtime->_configuredHeight : 0);
}

void DoraLoveWindow::clampPositionInWindow(double *x, double *y) const
{
	if (x) *x = std::clamp(*x, 0.0, static_cast<double>(getWidth()));
	if (y) *y = std::clamp(*y, 0.0, static_cast<double>(getHeight()));
}

void DoraLoveKeyboard::setKeyRepeat(bool enable) { if (_runtime) _runtime->_keyRepeatEnabled = enable; }
bool DoraLoveKeyboard::hasKeyRepeat() const { return _runtime && _runtime->_keyRepeatEnabled; }

bool DoraLoveKeyboard::isDown(const std::vector<Key> &keys) const
{
	if (!_runtime) return false;
	for (auto key : keys)
	{
		const char *name = nullptr;
		if (Keyboard::getConstant(key, name) && _runtime->_pressedKeys.contains(name)) return true;
	}
	return false;
}

bool DoraLoveKeyboard::isScancodeDown(const std::vector<Scancode> &scancodes) const
{
	if (!_runtime) return false;
	for (auto scancode : scancodes)
	{
		const char *name = nullptr;
		if (Keyboard::getConstant(scancode, name) && _runtime->_pressedScancodes.contains(name)) return true;
	}
	return false;
}

DoraLoveKeyboard::Key DoraLoveKeyboard::getKeyFromScancode(Scancode scancode) const
{
	const char *name = nullptr;
	if (!Keyboard::getConstant(scancode, name) || !_runtime || !_runtime->_keyboardBackend) return KEY_UNKNOWN;
	const std::string mapped = _runtime->_keyboardBackend->getKeyFromScancode(name);
	Key result = KEY_UNKNOWN;
	Keyboard::getConstant(mapped.c_str(), result);
	return result;
}

DoraLoveKeyboard::Scancode DoraLoveKeyboard::getScancodeFromKey(Key key) const
{
	const char *name = nullptr;
	if (!Keyboard::getConstant(key, name) || !_runtime || !_runtime->_keyboardBackend) return SCANCODE_UNKNOWN;
	const std::string mapped = _runtime->_keyboardBackend->getScancodeFromKey(name);
	Scancode result = SCANCODE_UNKNOWN;
	Keyboard::getConstant(mapped.c_str(), result);
	return result;
}

void DoraLoveKeyboard::setTextInput(bool enable)
{
	if (!_runtime) return;
	_runtime->_textInputEnabled = enable;
	if (_runtime->_keyboardBackend) _runtime->_keyboardBackend->setTextInput(enable, false, 0, 0, 0, 0);
}

void DoraLoveKeyboard::setTextInput(bool enable, double x, double y, double w, double h)
{
	if (!std::isfinite(x) || !std::isfinite(y) || !std::isfinite(w) || !std::isfinite(h)
		|| w < 0.0 || h < 0.0)
		throw ::love::Exception("text input rectangle must contain finite values and non-negative dimensions");
	if (!_runtime) return;
	_runtime->_textInputEnabled = enable;
	if (_runtime->_keyboardBackend) _runtime->_keyboardBackend->setTextInput(enable, true,
		static_cast<float>(x), static_cast<float>(y), static_cast<float>(w), static_cast<float>(h));
}

bool DoraLoveKeyboard::hasTextInput() const { return _runtime && _runtime->_textInputEnabled; }
bool DoraLoveKeyboard::hasScreenKeyboard() const
{
	return _runtime && _runtime->_keyboardBackend && _runtime->_keyboardBackend->hasScreenKeyboard();
}

::love::mouse::Cursor *DoraLoveMouse::newCursor(::love::image::ImageData *data, int hotx, int hoty)
{
	if (!_runtime || !_runtime->_mouseBackend || !data)
		throw ::love::Exception("mouse cursor images are not supported");
	auto *doraData = dynamic_cast<ImageDataUserdata *>(data);
	if (!doraData || doraData->getRuntime() != _runtime)
		throw ::love::Exception("ImageData belongs to another LoveRuntime");
	if (hotx < 0 || hoty < 0 || hotx >= data->getWidth() || hoty >= data->getHeight())
		throw ::love::Exception("Cursor hotspot is outside the image");
	std::string error;
	std::vector<std::uint8_t> rgba8;
	imageDataToRGBA8(*doraData, rgba8);
	const auto handle = _runtime->_mouseBackend->createImageCursor(data->getWidth(), data->getHeight(),
		rgba8, hotx, hoty, error);
	if (handle == 0) throw ::love::Exception("%s", error.c_str());
	return new CursorUserdata(_runtime, handle, ::love::mouse::Cursor::CURSORTYPE_IMAGE);
}

::love::mouse::Cursor *DoraLoveMouse::getSystemCursor(::love::mouse::Cursor::SystemCursor type)
{
	if (auto found = _systemCursors.find(type); found != _systemCursors.end()) return found->second.get();
	if (!_runtime || !_runtime->_mouseBackend) throw ::love::Exception("system cursors are not supported");
	const char *name = nullptr;
	::love::mouse::Cursor::getConstant(type, name);
	std::string error;
	const auto handle = _runtime->_mouseBackend->createSystemCursor(name, error);
	if (handle == 0) throw ::love::Exception("%s", error.c_str());
	auto *cursor = new CursorUserdata(_runtime, handle, ::love::mouse::Cursor::CURSORTYPE_SYSTEM, type);
	_systemCursors.emplace(type, ::love::StrongRef<::love::mouse::Cursor>(cursor, ::love::Acquire::NORETAIN));
	return cursor;
}

void DoraLoveMouse::setCursor(::love::mouse::Cursor *cursor)
{
	auto *dora = dynamic_cast<CursorUserdata *>(cursor);
	if (!dora || dora->runtime != _runtime || dora->handle == 0)
		throw ::love::Exception("Cursor belongs to another or closed LoveRuntime");
	_cursor.set(cursor);
	_runtime->_mouseCursor = dora->handle;
	if (_runtime && _runtime->_mouseBackend) _runtime->_mouseBackend->setMouseCursor(dora->handle);
}

void DoraLoveMouse::setCursor()
{
	_cursor.set(nullptr);
	if (_runtime) _runtime->_mouseCursor = 0;
	if (_runtime && _runtime->_mouseBackend) _runtime->_mouseBackend->setMouseCursor(0);
}

bool DoraLoveMouse::isCursorSupported() const
{
	return _runtime && _runtime->_mouseBackend && _runtime->_mouseBackend->isMouseCursorSupported();
}

double DoraLoveMouse::getX() const { return _runtime ? _runtime->_mouseX : 0.0; }
double DoraLoveMouse::getY() const { return _runtime ? _runtime->_mouseY : 0.0; }
void DoraLoveMouse::getPosition(double &x, double &y) const { x = getX(); y = getY(); }
void DoraLoveMouse::setX(double x) { setPosition(x, getY()); }
void DoraLoveMouse::setY(double y) { setPosition(getX(), y); }
void DoraLoveMouse::setPosition(double x, double y)
{
	if (!std::isfinite(x) || !std::isfinite(y)) throw ::love::Exception("mouse position must be finite");
	if (!_runtime) return;
	_runtime->_mouseX = static_cast<float>(x); _runtime->_mouseY = static_cast<float>(y);
	if (_runtime->_mouseBackend) _runtime->_mouseBackend->setMousePosition(_runtime->_mouseX, _runtime->_mouseY);
}
void DoraLoveMouse::setVisible(bool visible)
{
	if (!_runtime) return; _runtime->_mouseVisible = visible;
	if (_runtime->_mouseBackend) _runtime->_mouseBackend->setMouseVisible(visible);
}
bool DoraLoveMouse::isDown(const std::vector<int> &buttons) const
{
	if (!_runtime) return false;
	for (int button : buttons) if (_runtime->_pressedMouseButtons.contains(button)) return true;
	return false;
}
bool DoraLoveMouse::isVisible() const { return !_runtime || _runtime->_mouseVisible; }
void DoraLoveMouse::setGrabbed(bool grabbed)
{
	if (!_runtime) return; _runtime->_mouseGrabbed = grabbed;
	if (_runtime->_mouseBackend) _runtime->_mouseBackend->setMouseGrabbed(grabbed);
}
bool DoraLoveMouse::isGrabbed() const { return _runtime && _runtime->_mouseGrabbed; }
bool DoraLoveMouse::setRelativeMode(bool relative)
{
	if (!_runtime) return false;
	if (_runtime->_mouseBackend && !_runtime->_mouseBackend->setMouseRelativeMode(relative)) return false;
	_runtime->_mouseRelativeMode = relative; return true;
}
bool DoraLoveMouse::getRelativeMode() const { return _runtime && _runtime->_mouseRelativeMode; }

const std::vector<::love::touch::Touch::TouchInfo> &DoraLoveTouch::getTouches() const
{
	_activeTouches.clear();
	if (!_runtime) return _activeTouches;
	_activeTouches.reserve(_runtime->_touches.size());
	for (const auto &[id, touch] : _runtime->_touches)
	{
		_activeTouches.push_back({static_cast<::love::int64>(id), touch.x, touch.y,
			0.0, 0.0, touch.pressure});
	}
	return _activeTouches;
}

const ::love::touch::Touch::TouchInfo &DoraLoveTouch::getTouch(::love::int64 id) const
{
	if (!_runtime)
		throw ::love::Exception("Invalid active touch ID: %lld", static_cast<long long>(id));
	const auto key = static_cast<std::uintptr_t>(id);
	const auto found = _runtime->_touches.find(key);
	if (found == _runtime->_touches.end())
		throw ::love::Exception("Invalid active touch ID: %lld", static_cast<long long>(id));
	_selectedTouch = {id, found->second.x, found->second.y, 0.0, 0.0, found->second.pressure};
	return _selectedTouch;
}

bool JoystickUserdata::open(int deviceindex)
{
	id = deviceindex;
	return isConnected();
}

void JoystickUserdata::close() { }

bool JoystickUserdata::isConnected() const
{
	const auto found = runtime ? runtime->_joysticks.find(id) : decltype(runtime->_joysticks)::const_iterator{};
	return runtime && found != runtime->_joysticks.end() && found->second.connected;
}

const char *JoystickUserdata::getName() const
{
	if (!runtime) return "";
	const auto found = runtime->_joysticks.find(id);
	return found == runtime->_joysticks.end() ? "" : found->second.name.c_str();
}

int JoystickUserdata::getAxisCount() const
{
	const auto found = runtime ? runtime->_joysticks.find(id) : decltype(runtime->_joysticks)::const_iterator{};
	return runtime && found != runtime->_joysticks.end() ? found->second.info.axisCount : 0;
}

int JoystickUserdata::getButtonCount() const
{
	const auto found = runtime ? runtime->_joysticks.find(id) : decltype(runtime->_joysticks)::const_iterator{};
	return runtime && found != runtime->_joysticks.end() ? found->second.info.buttonCount : 0;
}

int JoystickUserdata::getHatCount() const
{
	const auto found = runtime ? runtime->_joysticks.find(id) : decltype(runtime->_joysticks)::const_iterator{};
	return runtime && found != runtime->_joysticks.end() ? found->second.info.hatCount : 0;
}

float JoystickUserdata::getAxis(int axisindex) const
{
	if (!runtime) return 0.0f;
	const auto found = runtime->_joysticks.find(id);
	if (found == runtime->_joysticks.end() || !found->second.connected
		|| axisindex < 0 || axisindex >= found->second.info.axisCount) return 0.0f;
	if (runtime->_joystickBackend) return runtime->_joystickBackend->getJoystickAxis(id, axisindex);
	static constexpr std::array<std::string_view, 6> axes = {
		"leftx", "lefty", "rightx", "righty", "triggerleft", "triggerright"};
	if (axisindex >= static_cast<int>(axes.size())) return 0.0f;
	const auto value = found->second.axes.find(std::string(axes[axisindex]));
	return value == found->second.axes.end() ? 0.0f : value->second;
}

std::vector<float> JoystickUserdata::getAxes() const
{
	std::vector<float> axes(static_cast<std::size_t>(std::max(0, getAxisCount())));
	for (std::size_t index = 0; index < axes.size(); ++index)
		axes[index] = getAxis(static_cast<int>(index));
	return axes;
}

::love::joystick::Joystick::Hat JoystickUserdata::getHat(int hatindex) const
{
	if (!runtime) return HAT_CENTERED;
	const auto found = runtime->_joysticks.find(id);
	if (found == runtime->_joysticks.end() || !found->second.connected || !runtime->_joystickBackend
		|| hatindex < 0 || hatindex >= found->second.info.hatCount) return HAT_CENTERED;
	switch (runtime->_joystickBackend->getJoystickHat(id, hatindex))
	{
		case 1: return HAT_UP;
		case 2: return HAT_RIGHT;
		case 4: return HAT_DOWN;
		case 8: return HAT_LEFT;
		case 3: return HAT_RIGHTUP;
		case 6: return HAT_RIGHTDOWN;
		case 9: return HAT_LEFTUP;
		case 12: return HAT_LEFTDOWN;
		default: return HAT_CENTERED;
	}
}

bool JoystickUserdata::isDown(const std::vector<int> &buttons) const
{
	if (!runtime) return false;
	const auto found = runtime->_joysticks.find(id);
	if (found == runtime->_joysticks.end() || !found->second.connected) return false;
	static constexpr std::array<std::string_view, 15> names = {
		"a", "b", "x", "y", "back", "guide", "start", "leftstick", "rightstick",
		"leftshoulder", "rightshoulder", "dpup", "dpdown", "dpleft", "dpright"};
	for (int button : buttons)
	{
		if (button < 0 || button >= found->second.info.buttonCount) continue;
		if (runtime->_joystickBackend && runtime->_joystickBackend->isJoystickButtonDown(id, button)) return true;
		if (!runtime->_joystickBackend && button < static_cast<int>(names.size())
			&& found->second.buttons.contains(std::string(names[button]))) return true;
	}
	return false;
}

float JoystickUserdata::getGamepadAxis(GamepadAxis axis) const
{
	const char *name = nullptr;
	if (!getConstant(axis, name) || !runtime) return 0.0f;
	const auto found = runtime->_joysticks.find(id);
	if (found == runtime->_joysticks.end()) return 0.0f;
	const auto value = found->second.axes.find(name);
	return value == found->second.axes.end() ? 0.0f : value->second;
}

bool JoystickUserdata::isGamepadDown(const std::vector<GamepadButton> &buttons) const
{
	if (!runtime) return false;
	const auto found = runtime->_joysticks.find(id);
	if (found == runtime->_joysticks.end() || !found->second.connected) return false;
	for (auto button : buttons)
	{
		const char *name = nullptr;
		if (getConstant(button, name) && found->second.buttons.contains(name)) return true;
	}
	return false;
}

::love::joystick::Joystick::JoystickInput JoystickUserdata::getGamepadMapping(
	const GamepadInput &input) const
{
	JoystickInput result{};
	result.type = INPUT_TYPE_MAX_ENUM;
	if (!runtime || !runtime->_joystickBackend || !isConnected()) return result;
	const char *name = nullptr;
	const bool valid = input.type == INPUT_TYPE_AXIS ? getConstant(input.axis, name)
		: input.type == INPUT_TYPE_BUTTON && getConstant(input.button, name);
	if (!valid) return result;
	const auto mapping = runtime->_joystickBackend->getJoystickGamepadMapping(id, name);
	if (!mapping || !getConstant(mapping->inputType.c_str(), result.type))
		return result;
	if (result.type == INPUT_TYPE_AXIS) result.axis = mapping->index;
	else if (result.type == INPUT_TYPE_BUTTON) result.button = mapping->index;
	else
	{
		result.hat.index = mapping->index;
		if (!getConstant(mapping->hat.c_str(), result.hat.value)) result.type = INPUT_TYPE_MAX_ENUM;
	}
	return result;
}

std::string JoystickUserdata::getGamepadMappingString() const
{
	return runtime && runtime->_joystickBackend && isConnected()
		? runtime->_joystickBackend->getJoystickGamepadMappingString(id) : std::string{};
}

std::string JoystickUserdata::getGUID() const
{
	if (!runtime) return {};
	const auto found = runtime->_joysticks.find(id);
	return found == runtime->_joysticks.end() ? std::string{} : found->second.info.guid;
}

int JoystickUserdata::getInstanceID() const
{
	if (!runtime) return -1;
	const auto found = runtime->_joysticks.find(id);
	return found != runtime->_joysticks.end() && found->second.connected
		? found->second.info.instanceId : -1;
}

void JoystickUserdata::getDeviceInfo(int &vendorID, int &productID, int &productVersion) const
{
	vendorID = productID = productVersion = 0;
	if (!runtime) return;
	const auto found = runtime->_joysticks.find(id);
	if (found == runtime->_joysticks.end()) return;
	vendorID = found->second.info.vendorId;
	productID = found->second.info.productId;
	productVersion = found->second.info.productVersion;
}

bool JoystickUserdata::isVibrationSupported()
{
	if (!runtime) return false;
	const auto found = runtime->_joysticks.find(id);
	return found != runtime->_joysticks.end() && found->second.connected
		&& found->second.info.vibrationSupported;
}

bool JoystickUserdata::setVibration(float left, float right, float duration)
{
	if (!std::isfinite(left) || !std::isfinite(right) || !std::isfinite(duration))
		throw ::love::Exception("vibration strength and duration must be finite");
	if (!runtime) return false;
	auto found = runtime->_joysticks.find(id);
	if (found == runtime->_joysticks.end() || !found->second.connected
		|| !found->second.info.vibrationSupported || !runtime->_joystickBackend) return false;
	left = std::clamp(left, 0.0f, 1.0f);
	right = std::clamp(right, 0.0f, 1.0f);
	if (!runtime->_joystickBackend->setJoystickVibration(id, left, right, duration)) return false;
	found->second.vibrationLeft = left;
	found->second.vibrationRight = right;
	found->second.vibrationEndTime = duration < 0.0f ? -1.0 : steadySeconds() + duration;
	return true;
}

void JoystickUserdata::getVibration(float &left, float &right)
{
	left = right = 0.0f;
	if (!runtime) return;
	auto found = runtime->_joysticks.find(id);
	if (found == runtime->_joysticks.end()) return;
	if (found->second.vibrationEndTime > 0.0 && steadySeconds() >= found->second.vibrationEndTime)
	{
		found->second.vibrationLeft = found->second.vibrationRight = 0.0f;
		found->second.vibrationEndTime = 0.0;
	}
	left = found->second.vibrationLeft;
	right = found->second.vibrationRight;
}

::love::joystick::Joystick *DoraLoveJoystickModule::addJoystick(int deviceindex)
{
	if (!_runtime) return nullptr;
	const auto found = _runtime->_joysticks.find(deviceindex);
	return found != _runtime->_joysticks.end() && found->second.connected
		? static_cast<::love::joystick::Joystick *>(found->second.object.get()) : nullptr;
}

void DoraLoveJoystickModule::removeJoystick(::love::joystick::Joystick *joystick)
{
	if (auto *dora = dynamic_cast<JoystickUserdata *>(joystick); dora && dora->runtime == _runtime)
	{
		auto found = _runtime->_joysticks.find(dora->id);
		if (found != _runtime->_joysticks.end()) found->second.connected = false;
	}
}

::love::joystick::Joystick *DoraLoveJoystickModule::getJoystickFromID(int instanceid)
{
	if (!_runtime) return nullptr;
	for (auto &[id, state] : _runtime->_joysticks)
		if (state.connected && state.info.instanceId == instanceid)
			return static_cast<::love::joystick::Joystick *>(state.object.get());
	return nullptr;
}

::love::joystick::Joystick *DoraLoveJoystickModule::getJoystick(int joyindex)
{
	if (!_runtime || joyindex < 0) return nullptr;
	for (auto &[id, state] : _runtime->_joysticks)
		if (state.connected && joyindex-- == 0)
			return static_cast<::love::joystick::Joystick *>(state.object.get());
	return nullptr;
}

int DoraLoveJoystickModule::getIndex(const ::love::joystick::Joystick *joystick)
{
	auto *dora = dynamic_cast<const JoystickUserdata *>(joystick);
	if (!_runtime || !dora || dora->runtime != _runtime) return -1;
	int index = 0;
	for (const auto &[id, state] : _runtime->_joysticks)
	{
		if (!state.connected) continue;
		if (id == dora->id) return index;
		++index;
	}
	return -1;
}

int DoraLoveJoystickModule::getJoystickCount() const
{
	int count = 0;
	if (_runtime) for (const auto &[id, state] : _runtime->_joysticks) if (state.connected) ++count;
	return count;
}

bool DoraLoveJoystickModule::setGamepadMapping(const std::string &guid,
	::love::joystick::Joystick::GamepadInput gpinput,
	::love::joystick::Joystick::JoystickInput joyinput)
{
	if (!_runtime || !_runtime->_joystickBackend) return false;
	const char *gamepad = nullptr, *inputType = nullptr, *hat = "";
	const bool valid = gpinput.type == ::love::joystick::Joystick::INPUT_TYPE_AXIS
		? ::love::joystick::Joystick::getConstant(gpinput.axis, gamepad)
		: gpinput.type == ::love::joystick::Joystick::INPUT_TYPE_BUTTON
			&& ::love::joystick::Joystick::getConstant(gpinput.button, gamepad);
	if (!valid || !::love::joystick::Joystick::getConstant(joyinput.type, inputType)) return false;
	int index = joyinput.type == ::love::joystick::Joystick::INPUT_TYPE_AXIS ? joyinput.axis
		: joyinput.type == ::love::joystick::Joystick::INPUT_TYPE_BUTTON ? joyinput.button : joyinput.hat.index;
	if (joyinput.type == ::love::joystick::Joystick::INPUT_TYPE_HAT
		&& !::love::joystick::Joystick::getConstant(joyinput.hat.value, hat)) return false;
	std::string error;
	const bool success = _runtime->_joystickBackend->setGamepadMapping(
		guid, gamepad, inputType, index, hat, error);
	if (!success && !error.empty()) throw ::love::Exception("%s", error.c_str());
	return success;
}

void DoraLoveJoystickModule::loadGamepadMappings(const std::string &mappings)
{
	if (!_runtime || !_runtime->_joystickBackend)
		throw ::love::Exception("love.joystick is not attached to a Dora Controller backend");
	std::string error;
	if (!_runtime->_joystickBackend->loadGamepadMappings(mappings, error))
		throw ::love::Exception("%s", error.empty() ? "Invalid gamepad mappings" : error.c_str());
}

std::string DoraLoveJoystickModule::saveGamepadMappings()
{
	return _runtime && _runtime->_joystickBackend
		? _runtime->_joystickBackend->saveGamepadMappings() : std::string{};
}

std::string DoraLoveJoystickModule::getGamepadMappingString(const std::string &guid) const
{
	return _runtime && _runtime->_joystickBackend
		? _runtime->_joystickBackend->getGamepadMappingString(guid) : std::string{};
}

int LoveRuntime::filesystemSetIdentity(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string_view identity = luaL_checkstring(state, 1);
	(void) lua_toboolean(state, 2); // appendToPath is accepted; save remains first in the embedded search order.
	std::string error;
	if (runtime == nullptr || !runtime->setIdentity(identity, error))
		return luaL_error(state, "%s", error.c_str());
	return 0;
}

int LoveRuntime::filesystemLoad(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string filename = luaL_checkstring(state, 1);
	std::string resolved;
	std::string error;
	if (!runtime->resolveReadPath(filename, resolved, error))
		return pushFilesystemFailure(state, error);
	std::string code;
	if (!runtime->_filesystemBackend || !runtime->_filesystemBackend->load(resolved, code, error))
		return pushFilesystemFailure(state, error.empty()
			? "failed to open Love filesystem file for loading: " + filename : error);
	const std::string chunkName = runtime->prepareGeneratedChunk(code, "@" + resolved);
	if (loadLoveChunk(state, code, chunkName.c_str()) != LUA_OK)
	{
		runtime->rewriteGeneratedErrorOnStack(state);
		lua_pushnil(state);
		lua_insert(state, -2);
		return 2;
	}
	return 1;
}

int LoveRuntime::sourceModuleSearcher(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::size_t moduleNameSize = 0;
	const char *moduleNameData = luaL_checklstring(state, 1, &moduleNameSize);
	const std::string moduleName(moduleNameData, moduleNameSize);
	if (runtime == nullptr || runtime->_sourceRoot.empty())
	{
		lua_pushliteral(state, "\n\tLove source root is not configured");
		return 1;
	}
	std::string modulePath;
	if (!normalizeLoveModulePath(moduleName, modulePath))
	{
		lua_pushfstring(state, "\n\tinvalid Love module name '%s'", moduleName.c_str());
		return 1;
	}
	std::string searched;
	for (const std::string &pattern : runtime->_requirePath)
	{
		if (pattern.empty())
			continue;
		std::string virtualPath = pattern;
		std::size_t offset = 0;
		while ((offset = virtualPath.find('?', offset)) != std::string::npos)
		{
			virtualPath.replace(offset, 1, modulePath);
			offset += modulePath.size();
		}
		std::string resolvedPath;
		std::string resolveError;
		searched += "\n\tno Love module file '" + virtualPath + "'";
		if (!runtime->resolveReadPath(virtualPath, resolvedPath, resolveError))
			continue;
		std::string code;
		std::string loadError;
		if (!runtime->_filesystemBackend->load(resolvedPath, code, loadError))
			continue;
		// Match official Love: debug.getinfo().source is game-root-relative even
		// though Dora reads the staged file through an absolute backend path.
		const std::string chunkName = runtime->prepareGeneratedChunk(code, "@" + virtualPath);
		if (loadLoveChunk(state, code, chunkName.c_str()) != LUA_OK)
		{
			runtime->rewriteGeneratedErrorOnStack(state);
			return 1;
		}
		lua_pushlstring(state, resolvedPath.data(), resolvedPath.size());
		return 2;
	}
	lua_pushlstring(state, searched.data(), searched.size());
	return 1;
}

int LoveRuntime::filesystemSetRequirePath(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	std::size_t pathSize = 0;
	const char *pathData = luaL_checklstring(state, 1, &pathSize);
	static constexpr std::size_t MaximumRequirePathSize = 4096;
	static constexpr std::size_t MaximumRequirePathPatterns = 32;
	if (pathSize > MaximumRequirePathSize)
		return luaL_argerror(state, 1, "Love require path is too long");

	std::vector<std::string> patterns;
	std::string path(pathData, pathSize);
	std::size_t start = 0;
	while (start < path.size())
	{
		const std::size_t separator = path.find(';', start);
		const std::size_t end = separator == std::string::npos ? path.size() : separator;
		std::string pattern = path.substr(start, end - start);
		if (patterns.size() >= MaximumRequirePathPatterns)
			return luaL_argerror(state, 1, "Love require path has too many patterns");
		if (!pattern.empty())
		{
			if (pattern.starts_with('/') || pattern.find(':') != std::string::npos
				|| pattern.find('\0') != std::string::npos)
				return luaL_argerror(state, 1, "Love require path patterns must be relative and confined");
			std::string probe = pattern;
			std::size_t offset = 0;
			while ((offset = probe.find('?', offset)) != std::string::npos)
			{
				probe.replace(offset, 1, "module");
				offset += 6;
			}
			if (!isSafeVirtualPath(probe, false))
				return luaL_argerror(state, 1, "Love require path patterns must be relative and confined");
		}
		patterns.push_back(std::move(pattern));
		if (separator == std::string::npos)
			break;
		start = separator + 1;
	}
	runtime->_requirePath = std::move(patterns);
	return 0;
}

int DoraLoveGraphics::getWidth() const
{
	return _runtime->_graphicsBackend
		? _runtime->_graphicsBackend->getPixelWidth() : _runtime->_configuredWidth;
}

int DoraLoveGraphics::getHeight() const
{
	return _runtime->_graphicsBackend
		? _runtime->_graphicsBackend->getPixelHeight() : _runtime->_configuredHeight;
}

int DoraLoveGraphics::getPixelWidth() const { return getWidth(); }
int DoraLoveGraphics::getPixelHeight() const { return getHeight(); }
bool DoraLoveGraphics::isActive() const { return _runtime->_graphicsBackend != nullptr; }
bool DoraLoveGraphics::isCreated() const { return _runtime->_graphicsBackend != nullptr; }

DoraLoveGraphics::BoolFields DoraLoveGraphics::getSupported() const
{
	if (!_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	const auto value = _runtime->_graphicsBackend->getCapabilities();
	return {{"multicanvasformats", value.multiCanvasFormats}, {"clampzero", value.clampZero},
		{"lighten", value.lighten}, {"fullnpot", value.fullNPOT},
		{"pixelshaderhighp", value.pixelShaderHighp}, {"shaderderivatives", value.shaderDerivatives},
		{"glsl3", value.glsl3}, {"instancing", value.instancing}};
}

DoraLoveGraphics::BoolFields DoraLoveGraphics::getTextureTypes() const
{
	if (!_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	const auto value = _runtime->_graphicsBackend->getTextureTypes();
	return {{"2d", value.texture2D}, {"array", value.array},
		{"cube", value.cube}, {"volume", value.volume}};
}

DoraLoveGraphics::BoolFields DoraLoveGraphics::getImageFormats() const
{
	if (!_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	static constexpr std::string_view formats[] = {
		"r8", "rg8", "rgba8", "r16", "rg16", "rgba16", "r16f", "rg16f",
		"rgba16f", "r32f", "rg32f", "rgba32f", "rgba4", "rgb5a1", "rgb565",
		"rgb10a2", "rg11b10f", "DXT1", "DXT3", "DXT5", "BC4", "BC4s", "BC5",
		"BC5s", "BC6h", "BC6hs", "BC7", "PVR1rgb2", "PVR1rgb4", "PVR1rgba2",
		"PVR1rgba4", "ETC1", "ETC2rgb", "ETC2rgba", "ETC2rgba1", "EACr", "EACrs",
		"EACrg", "EACrgs", "ASTC4x4", "ASTC5x4", "ASTC5x5", "ASTC6x5", "ASTC6x6",
		"ASTC8x5", "ASTC8x6", "ASTC8x8", "ASTC10x5", "ASTC10x6", "ASTC10x8",
		"ASTC10x10", "ASTC12x10", "ASTC12x12"};
	BoolFields result;
	result.reserve(std::size(formats));
	for (const auto format : formats)
		result.emplace_back(format, _runtime->_graphicsBackend->isImageFormatSupported(format));
	return result;
}

DoraLoveGraphics::BoolFields DoraLoveGraphics::getCanvasFormats(bool readable) const
{
	if (!_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	static constexpr std::string_view formats[] = {
		"normal", "hdr", "r8", "rg8", "rgba8", "srgba8", "r16", "rg16",
		"rgba16", "r16f", "rg16f", "rgba16f", "r32f", "rg32f", "rgba32f",
		"la8", "rgba4", "rgb5a1", "rgb565", "rgb10a2", "rg11b10f",
		"stencil8", "depth16", "depth24", "depth32f", "depth24stencil8",
		"depth32fstencil8"};
	BoolFields result;
	result.reserve(std::size(formats));
	for (const auto format : formats)
		result.emplace_back(format, _runtime->_graphicsBackend->isCanvasFormatSupported(format, readable));
	return result;
}

DoraLoveGraphics::BoolFields DoraLoveGraphics::getTextureFormats(bool canvas,
	int readable, bool computeWrite, bool shaderAtomics) const
{
	if (!_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	if (!canvas)
	{
		auto result = getImageFormats();
		if (computeWrite || shaderAtomics)
			for (auto &entry : result) entry.second = false;
		return result;
	}

	static constexpr std::string_view formats[] = {
		"normal", "hdr", "r8", "rg8", "rgba8", "srgba8", "r16", "rg16",
		"rgba16", "r16f", "rg16f", "rgba16f", "r32f", "rg32f", "rgba32f",
		"la8", "rgba4", "rgb5a1", "rgb565", "rgb10a2", "rg11b10f",
		"stencil8", "depth16", "depth24", "depth32f", "depth24stencil8",
		"depth32fstencil8"};
	BoolFields result;
	result.reserve(std::size(formats));
	for (const auto format : formats)
	{
		const bool depthStencil = format.starts_with("depth") || format == "stencil8";
		const bool formatReadable = readable < 0 ? !depthStencil : readable != 0;
		const bool supported = !computeWrite && !shaderAtomics
			&& _runtime->_graphicsBackend->isCanvasFormatSupported(format, formatReadable);
		result.emplace_back(format, supported);
	}
	return result;
}

DoraLoveGraphics::RendererInfo DoraLoveGraphics::getRendererInfo() const
{
	if (!_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	const auto value = _runtime->_graphicsBackend->getRendererInfo();
	return {value.name, value.version, value.vendor, value.device};
}

DoraLoveGraphics::NumberFields DoraLoveGraphics::getSystemLimits() const
{
	const auto value = _runtime->_graphicsBackend
		? _runtime->_graphicsBackend->getSystemLimits() : GraphicsBackend::SystemLimits{};
	return {{"pointsize", value.pointSize}, {"texturesize", value.textureSize},
		{"volumetexturesize", value.volumeTextureSize}, {"cubetexturesize", value.cubeTextureSize},
		{"texturelayers", value.textureLayers}, {"multicanvas", value.multiCanvas},
		{"canvasmsaa", value.canvasMSAA}, {"anisotropy", value.anisotropy}};
}

DoraLoveGraphics::Stats DoraLoveGraphics::getStats() const
{
	const auto value = _runtime->_graphicsBackend
		? _runtime->_graphicsBackend->getStats() : GraphicsBackend::Stats{};
	return {{"drawcalls", value.drawCalls}, {"drawcallsbatched", value.drawCallsBatched},
		{"canvasswitches", value.canvasSwitches}, {"shaderswitches", value.shaderSwitches},
		{"canvases", value.canvases}, {"images", value.images}, {"fonts", value.fonts},
		{"texturememory", value.textureMemory}};
}

::love::graphics::Image *DoraLoveGraphics::newImage(
	::love::graphics::Image::Slices &slices,
	const ::love::graphics::Image::Settings &settings)
{
	if (!_runtime || !_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	slices.validate();
	GraphicsBackend::TextureType type = GraphicsBackend::TextureType::Texture2D;
	switch (slices.getTextureType())
	{
		case ::love::graphics::TEXTURE_2D_ARRAY: type = GraphicsBackend::TextureType::Array; break;
		case ::love::graphics::TEXTURE_CUBE: type = GraphicsBackend::TextureType::Cube; break;
		case ::love::graphics::TEXTURE_VOLUME: type = GraphicsBackend::TextureType::Volume; break;
		default: break;
	}
	auto *base = slices.get(0, 0);
	if (!base) throw ::love::Exception("Image has no base slice");
	const bool compressed = ::love::isPixelFormatCompressed(base->getFormat());
	const int mipCount = slices.getMipmapCount(0);
	GraphicsBackend::ImageHandle handle = 0;
	std::string error;
	std::string format = "rgba8";
	int createdMipCount = mipCount;
	int layerCount = slices.getSliceCount(0);
	if (compressed)
	{
		const char *formatName = nullptr;
		if (!::love::getConstant(base->getFormat(), formatName) || !formatName)
			throw ::love::Exception("Image uses an unknown compressed pixel format");
		format = formatName;
		std::vector<GraphicsBackend::CompressedImageLevel> levels;
		levels.reserve(static_cast<std::size_t>(mipCount));
		for (int mip = 0; mip < mipCount; ++mip)
		{
			GraphicsBackend::CompressedImageLevel level;
			level.slices = slices.getSliceCount(mip);
			for (int slice = 0; slice < level.slices; ++slice)
			{
				auto *data = slices.get(slice, mip);
				if (!data) throw ::love::Exception("Image compressed slice is missing");
				if (slice == 0) { level.width = data->getWidth(); level.height = data->getHeight(); }
				const auto *bytes = static_cast<const std::uint8_t *>(data->getData());
				level.bytes.insert(level.bytes.end(), bytes, bytes + data->getSize());
			}
			levels.push_back(std::move(level));
		}
		handle = _runtime->_graphicsBackend->newCompressedImage(type, format, levels, error);
	}
	else
	{
		std::vector<GraphicsBackend::ImageLevel> levels;
		levels.reserve(static_cast<std::size_t>(mipCount));
		for (int mip = 0; mip < mipCount; ++mip)
		{
			GraphicsBackend::ImageLevel level;
			level.slices = 0;
			const int count = slices.getSliceCount(mip);
			for (int slice = 0; slice < count; ++slice)
			{
				auto *data = dynamic_cast<ImageDataUserdata *>(slices.get(slice, mip));
				if (!data || data->getRuntime() != _runtime)
					throw ::love::Exception("ImageData belongs to another or unsupported LoveRuntime");
				std::vector<std::uint8_t> rgba8;
				imageDataToRGBA8(*data, rgba8);
				if (slice == 0) { level.width = data->getWidth(); level.height = data->getHeight(); }
				level.rgba8.insert(level.rgba8.end(), rgba8.begin(), rgba8.end());
				++level.slices;
			}
			levels.push_back(std::move(level));
		}
		if (settings.mipmaps && levels.size() == 1)
			generateImageMipmaps(levels, type);
		createdMipCount = static_cast<int>(levels.size());
		handle = _runtime->_graphicsBackend->newImage(type, levels, error);
	}
	if (handle == 0)
		throw ::love::Exception("Love Image creation failed: %s",
			error.empty() ? "Dora graphics backend rejected the Image" : error.c_str());
	auto *image = new ImageUserdata(_runtime, handle, type, layerCount);
	image->filter = image->magFilter = _runtime->_graphicsDefaultFilter;
	image->anisotropy = _runtime->_graphicsDefaultAnisotropy;
	image->mipmapCount = createdMipCount;
	image->format = std::move(format);
	image->compressed = compressed;
	image->linear = settings.linear;
	image->dpiScale = settings.dpiScale;
	if (createdMipCount > 1)
	{
		image->mipmapFilter = _runtime->_graphicsDefaultMipmapFilter;
		image->mipmapSharpness = _runtime->_graphicsDefaultMipmapSharpness;
	}
	image->syncUpstreamMetadata();
	return image;
}

::love::graphics::Font *DoraLoveGraphics::newDefaultFont(int size)
{
	if (size <= 0 || size > 4096)
		throw ::love::Exception("Font size must be between 1 and 4096");
	if (!_runtime || !_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics Font is not attached to a Dora graphics backend");
	std::string error;
	const auto handle = _runtime->_graphicsBackend->newFont({}, size, error);
	if (handle == 0)
		throw ::love::Exception("Love default Font creation failed: %s",
			error.empty() ? "Dora graphics backend rejected the Font" : error.c_str());
	auto *font = new FontUserdata(_runtime, handle);
	font->filter.min = font->filter.mag = _runtime->_graphicsDefaultFilter
		== GraphicsBackend::TextureFilter::Nearest
		? ::love::graphics::Texture::FILTER_NEAREST
		: ::love::graphics::Texture::FILTER_LINEAR;
	font->filter.mipmap = ::love::graphics::Texture::FILTER_NONE;
	font->filter.anisotropy = _runtime->_graphicsDefaultAnisotropy;
	return font;
}

::love::graphics::Font *DoraLoveGraphics::newFont(
	::love::font::Rasterizer *requestedRasterizer)
{
	auto *rasterizer = dynamic_cast<RasterizerUserdata *>(requestedRasterizer);
	if (!rasterizer || rasterizer->runtime != _runtime)
		throw ::love::Exception("Rasterizer belongs to another or unsupported LoveRuntime");
	if (!_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics Font is not attached to a Dora graphics backend");
	const auto filter = _runtime->_graphicsDefaultFilter;
	GraphicsBackend::FontHandle handle = 0;
	std::string error;
	if (rasterizer->kind == RasterizerUserdata::Kind::TrueType)
	{
		handle = _runtime->_graphicsBackend->newFont(rasterizer->fontBytes,
			rasterizer->requestedSize, rasterizer->getDPIScale(), error);
	}
	else if (rasterizer->kind == RasterizerUserdata::Kind::BMFont)
	{
		std::vector<std::vector<std::uint8_t>> pixels;
		std::vector<GraphicsBackend::BMFontPage> pages;
		pixels.reserve(rasterizer->sourceObjects.size());
		pages.reserve(rasterizer->sourceObjects.size());
		for (const auto &source : rasterizer->sourceObjects)
		{
			auto *page = static_cast<ImageDataUserdata *>(source.get());
			if (!page || page->getRuntime() != _runtime
				|| std::string_view(getImageDataFormatName(*page)) != "rgba8")
				throw ::love::Exception("BMFont Rasterizer has an invalid page ImageData");
			pixels.emplace_back();
			imageDataToRGBA8(*page, pixels.back());
			pages.push_back({page->getWidth(), page->getHeight(), pixels.back()});
		}
		std::vector<GraphicsBackend::BMFontGlyph> glyphs;
		glyphs.reserve(rasterizer->bmGlyphs.size());
		for (const auto &[codepoint, glyph] : rasterizer->bmGlyphs)
			glyphs.push_back({codepoint, glyph.page, glyph.x, glyph.y, glyph.width,
				glyph.height, glyph.advance, glyph.bearingX, glyph.bearingY});
		handle = _runtime->_graphicsBackend->newBMFont(pages, glyphs,
			rasterizer->height, rasterizer->ascent, rasterizer->getDPIScale(), filter, error);
	}
	else
	{
		auto *image = rasterizer->sourceObjects.empty() ? nullptr
			: static_cast<ImageDataUserdata *>(rasterizer->sourceObjects.front().get());
		if (!image || image->getRuntime() != _runtime
			|| std::string_view(getImageDataFormatName(*image)) != "rgba8")
			throw ::love::Exception("Image Rasterizer has an invalid rgba8 ImageData source");
		std::vector<std::uint8_t> rgba8;
		imageDataToRGBA8(*image, rgba8);
		for (std::size_t offset = 0; offset < rgba8.size(); offset += 4)
			if (std::equal(rasterizer->spacer.begin(), rasterizer->spacer.end(),
				rgba8.begin() + static_cast<std::ptrdiff_t>(offset)))
				std::fill_n(rgba8.begin() + static_cast<std::ptrdiff_t>(offset), 4, 0);
		std::vector<GraphicsBackend::ImageFontGlyph> glyphs;
		glyphs.reserve(rasterizer->imageGlyphs.size());
		for (const auto &glyph : rasterizer->imageGlyphs)
			glyphs.push_back({glyph.codepoint, glyph.x, glyph.width,
				glyph.width + rasterizer->extraSpacing});
		handle = _runtime->_graphicsBackend->newImageFont(image->getWidth(), image->getHeight(),
			rgba8, glyphs, rasterizer->getDPIScale(), filter, error);
	}
	if (handle == 0)
		throw ::love::Exception("Love Font creation failed: %s",
			error.empty() ? "Dora graphics backend rejected the Rasterizer" : error.c_str());
	auto *font = new FontUserdata(_runtime, handle);
	font->filter.min = font->filter.mag = filter == GraphicsBackend::TextureFilter::Nearest
		? ::love::graphics::Texture::FILTER_NEAREST
		: ::love::graphics::Texture::FILTER_LINEAR;
	font->filter.mipmap = ::love::graphics::Texture::FILTER_NONE;
	font->filter.anisotropy = _runtime->_graphicsDefaultAnisotropy;
	return font;
}

void DoraLoveGraphics::setShader(::love::graphics::Shader *requestedShader)
{
	GraphicsBackend::ShaderHandle handle = 0;
	ShaderUserdata *shader = nullptr;
	if (requestedShader)
	{
		shader = dynamic_cast<ShaderUserdata *>(requestedShader);
		if (!shader || shader->runtime != _runtime || shader->handle == 0
			|| !_runtime->_shaderHandles.contains(shader->handle))
			throw ::love::Exception("Shader belongs to another or closed LoveRuntime");
		handle = shader->handle;
	}
	std::string error;
	if (_runtime->_graphicsBackend && !_runtime->_graphicsBackend->setShader(handle, error))
		throw ::love::Exception("%s", error.c_str());
	_runtime->_graphicsShader = handle;
	_runtime->_graphicsShaderObject.set(shader);
}

::love::graphics::Shader *DoraLoveGraphics::getShader() const
{
	return static_cast<ShaderUserdata *>(_runtime->_graphicsShaderObject.get());
}

::love::graphics::Shader *DoraLoveGraphics::newShader(
	const std::string &vertexSource, const std::string &pixelSource)
{
	if (!_runtime || !_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	std::string warnings;
	std::string error;
	const auto handle = _runtime->_graphicsBackend->newShader(
		vertexSource, pixelSource, warnings, error);
	if (handle == 0) throw ::love::Exception("%s", error.c_str());
	return new ShaderUserdata(_runtime, handle, std::move(warnings));
}

bool DoraLoveGraphics::validateShader(bool gles, const std::string &vertexSource,
	const std::string &pixelSource, std::string &error)
{
	(void)gles;
	if (!_runtime || !_runtime->_graphicsBackend)
	{
		error = "love.graphics is not attached to a Dora graphics backend";
		return false;
	}
	return _runtime->_graphicsBackend->validateShader(vertexSource, pixelSource, error);
}

void DoraLoveGraphics::setFont(::love::graphics::Font *requestedFont)
{
	auto *font = dynamic_cast<FontUserdata *>(requestedFont);
	if (!font || font->runtime != _runtime || !_runtime->_fontHandles.contains(font->handle))
		throw ::love::Exception("Font belongs to another or closed LoveRuntime");
	_runtime->_currentFont = font->handle;
	_runtime->_graphicsFontObject.set(font);
}

::love::graphics::Font *DoraLoveGraphics::getFont()
{
	std::string error;
	if (_runtime->ensureDefaultFont(error) == 0)
		throw ::love::Exception("%s", error.c_str());
	return static_cast<FontUserdata *>(_runtime->_graphicsFontObject.get());
}

static std::vector<float> flattenPrimitiveVertices(const std::vector<::love::Vector2> &vertices)
{
	std::vector<float> result;
	result.reserve(vertices.size() * 2);
	for (const auto &vertex : vertices)
	{
		result.push_back(vertex.x);
		result.push_back(vertex.y);
	}
	return result;
}

void DoraLoveGraphics::points(const std::vector<::love::Vector2> &positions,
	const std::vector<::love::Colorf> &colors)
{
	(void)colors;
	if (!_runtime->_graphicsBackend) return;
	std::string error;
	if (!_runtime->_graphicsBackend->validateShaderDraw(error)
		|| !_runtime->_graphicsBackend->points(
			_runtime->transformGraphicsPoints(flattenPrimitiveVertices(positions)),
			_runtime->_graphicsPointSize, _runtime->_graphicsColor[0], _runtime->_graphicsColor[1],
			_runtime->_graphicsColor[2], _runtime->_graphicsColor[3], error))
		throw ::love::Exception("%s", error.c_str());
}

void DoraLoveGraphics::polyline(const std::vector<::love::Vector2> &vertices)
{
	if (!_runtime->_graphicsBackend) return;
	std::string error;
	if (!_runtime->_graphicsBackend->validateShaderDraw(error)
		|| !_runtime->_graphicsBackend->line(flattenPrimitiveVertices(vertices),
			_runtime->_graphicsTransform, _runtime->_graphicsLineWidth, _runtime->_graphicsLineStyle,
			_runtime->_graphicsLineJoin, _runtime->_graphicsColor[0], _runtime->_graphicsColor[1],
			_runtime->_graphicsColor[2], _runtime->_graphicsColor[3], error))
		throw ::love::Exception("%s", error.c_str());
}

void DoraLoveGraphics::rectangle(DrawMode mode, float x, float y, float width, float height,
	float radiusX, float radiusY, int points)
{
	(void)radiusX; (void)radiusY; (void)points;
	if (!_runtime->_graphicsBackend) return;
	const bool fill = mode == DrawMode::Fill;
	std::string error;
	if (!_runtime->_graphicsBackend->validateShaderDraw(error))
		throw ::love::Exception("%s", error.c_str());
	const bool submitted = _runtime->isGraphicsTransformIdentity()
		? _runtime->_graphicsBackend->rectangle(fill, x, y, width, height,
			_runtime->_graphicsLineWidth, _runtime->_graphicsLineStyle, _runtime->_graphicsLineJoin,
			_runtime->_graphicsColor[0], _runtime->_graphicsColor[1], _runtime->_graphicsColor[2],
			_runtime->_graphicsColor[3], error)
		: _runtime->_graphicsBackend->polygon(fill,
			{x, y, x + width, y, x + width, y + height, x, y + height},
			_runtime->_graphicsTransform, _runtime->_graphicsLineWidth, _runtime->_graphicsLineStyle,
			_runtime->_graphicsLineJoin, _runtime->_graphicsColor[0], _runtime->_graphicsColor[1],
			_runtime->_graphicsColor[2], _runtime->_graphicsColor[3], error);
	if (!submitted) throw ::love::Exception("%s", error.c_str());
}

void DoraLoveGraphics::circle(DrawMode mode, float x, float y, float radius, int points)
{
	if (!_runtime->_graphicsBackend) return;
	const bool fill = mode == DrawMode::Fill;
	std::string error;
	if (!_runtime->_graphicsBackend->validateShaderDraw(error))
		throw ::love::Exception("%s", error.c_str());
	if (_runtime->isGraphicsTransformIdentity())
	{
		if (!_runtime->_graphicsBackend->circle(fill, x, y, radius, _runtime->_graphicsLineWidth,
			_runtime->_graphicsLineStyle, _runtime->_graphicsLineJoin, _runtime->_graphicsColor[0],
			_runtime->_graphicsColor[1], _runtime->_graphicsColor[2], _runtime->_graphicsColor[3], error))
			throw ::love::Exception("%s", error.c_str());
		return;
	}
	const int segments = points < 0 ? 48 : points;
	if (segments <= 0) return;
	std::vector<float> vertices;
	vertices.reserve(static_cast<size_t>(segments) * 2);
	for (int i = 0; i < segments; ++i)
	{
		const float angle = static_cast<float>(i) * 2.0f * std::numbers::pi_v<float>
			/ static_cast<float>(segments);
		vertices.push_back(x + std::cos(angle) * radius);
		vertices.push_back(y + std::sin(angle) * radius);
	}
	if (!_runtime->_graphicsBackend->polygon(fill, vertices, _runtime->_graphicsTransform,
		_runtime->_graphicsLineWidth, _runtime->_graphicsLineStyle, _runtime->_graphicsLineJoin,
		_runtime->_graphicsColor[0], _runtime->_graphicsColor[1], _runtime->_graphicsColor[2],
		_runtime->_graphicsColor[3], error))
		throw ::love::Exception("%s", error.c_str());
}

void DoraLoveGraphics::ellipse(DrawMode mode, float x, float y, float radiusX, float radiusY,
	int points)
{
	const int segments = points < 0 ? 48 : points;
	if (segments <= 0 || !_runtime->_graphicsBackend) return;
	std::vector<float> vertices;
	vertices.reserve(static_cast<size_t>(segments) * 2);
	for (int i = 0; i < segments; ++i)
	{
		const float angle = static_cast<float>(i) * 2.0f * std::numbers::pi_v<float>
			/ static_cast<float>(segments);
		vertices.push_back(x + std::cos(angle) * radiusX);
		vertices.push_back(y + std::sin(angle) * radiusY);
	}
	std::string error;
	if (!_runtime->_graphicsBackend->validateShaderDraw(error)
		|| !_runtime->_graphicsBackend->polygon(mode == DrawMode::Fill, vertices,
			_runtime->_graphicsTransform, _runtime->_graphicsLineWidth, _runtime->_graphicsLineStyle,
			_runtime->_graphicsLineJoin, _runtime->_graphicsColor[0], _runtime->_graphicsColor[1],
			_runtime->_graphicsColor[2], _runtime->_graphicsColor[3], error))
		throw ::love::Exception("%s", error.c_str());
}

void DoraLoveGraphics::arc(DrawMode drawMode, ArcMode arcMode, float x, float y, float radius,
	float angle1, float angle2, int points)
{
	for (const float value : {x, y, radius, angle1, angle2})
		if (!std::isfinite(value)) throw ::love::Exception("arc arguments must be finite");
	constexpr float tau = 2.0f * std::numbers::pi_v<float>;
	const float angle = std::abs(angle2 - angle1);
	int segments = points;
	if (segments < 0)
	{
		const float scale = std::max(_runtime->_graphicsTransform.pixelScale, 0.000001f);
		float count = std::max(std::sqrt(std::abs(radius) * 20.0f * scale), 8.0f);
		if (angle < tau) count *= angle / tau;
		segments = static_cast<int>(count + 0.5f);
	}
	if (segments <= 0 || angle1 == angle2 || !_runtime->_graphicsBackend) return;
	const bool fill = drawMode == DrawMode::Fill;
	std::vector<float> vertices;
	if (angle >= tau)
	{
		vertices.reserve(static_cast<size_t>(segments + (fill ? 0 : 1)) * 2);
		for (int index = 0; index < segments; ++index)
		{
			const float phi = static_cast<float>(index) * tau / static_cast<float>(segments);
			vertices.push_back(x + radius * std::cos(phi));
			vertices.push_back(y + radius * std::sin(phi));
		}
		if (!fill) { vertices.push_back(vertices[0]); vertices.push_back(vertices[1]); }
	}
	else
	{
		if (!fill && arcMode == ArcMode::Closed && angle < 4.0f * std::numbers::pi_v<float> / 180.0f)
			arcMode = ArcMode::Open;
		if (fill && arcMode == ArcMode::Open) arcMode = ArcMode::Closed;
		if (arcMode == ArcMode::Pie) { vertices.push_back(x); vertices.push_back(y); }
		const float shift = (angle2 - angle1) / static_cast<float>(segments);
		for (int index = 0; index <= segments; ++index)
		{
			const float phi = angle1 + static_cast<float>(index) * shift;
			vertices.push_back(x + radius * std::cos(phi));
			vertices.push_back(y + radius * std::sin(phi));
		}
		if (!fill && arcMode == ArcMode::Pie) { vertices.push_back(x); vertices.push_back(y); }
		else if (!fill && arcMode == ArcMode::Closed)
			{ vertices.push_back(vertices[0]); vertices.push_back(vertices[1]); }
	}
	std::string error;
	const bool submitted = _runtime->_graphicsBackend->validateShaderDraw(error)
		&& (fill ? _runtime->_graphicsBackend->polygon(true, vertices, _runtime->_graphicsTransform,
			_runtime->_graphicsLineWidth, _runtime->_graphicsLineStyle, _runtime->_graphicsLineJoin,
			_runtime->_graphicsColor[0], _runtime->_graphicsColor[1], _runtime->_graphicsColor[2],
			_runtime->_graphicsColor[3], error)
		: _runtime->_graphicsBackend->line(vertices, _runtime->_graphicsTransform,
			_runtime->_graphicsLineWidth, _runtime->_graphicsLineStyle, _runtime->_graphicsLineJoin,
			_runtime->_graphicsColor[0], _runtime->_graphicsColor[1], _runtime->_graphicsColor[2],
			_runtime->_graphicsColor[3], error));
	if (!submitted) throw ::love::Exception("%s", error.c_str());
}

void DoraLoveGraphics::polygon(DrawMode mode, const std::vector<::love::Vector2> &vertices)
{
	if (!_runtime->_graphicsBackend) return;
	std::string error;
	if (!_runtime->_graphicsBackend->validateShaderDraw(error)
		|| !_runtime->_graphicsBackend->polygon(mode == DrawMode::Fill,
			flattenPrimitiveVertices(vertices), _runtime->_graphicsTransform,
			_runtime->_graphicsLineWidth, _runtime->_graphicsLineStyle, _runtime->_graphicsLineJoin,
			_runtime->_graphicsColor[0], _runtime->_graphicsColor[1], _runtime->_graphicsColor[2],
			_runtime->_graphicsColor[3], error))
		throw ::love::Exception("%s", error.c_str());
}

void DoraLoveGraphics::captureScreenshot(lua_State *state,
	::love::graphics::GraphicsScreenshotRequest parsed)
{
	auto *runtime = _runtime;
	if (!runtime || !runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora screenshot backend");

	LoveRuntime::ScreenshotRequest request;
	request.callbackReference = parsed.callbackReference;
	if (parsed.type == ::love::graphics::GraphicsScreenshotRequest::Type::File)
	{
		request.filename = std::move(parsed.filename);
		const char *format = nullptr;
		if (!::love::image::ImageData::getConstant(parsed.format, format))
			throw ::love::Exception("Unknown screenshot image format");
		request.format = format;
	}
	else if (parsed.type == ::love::graphics::GraphicsScreenshotRequest::Type::Channel)
	{
		auto *channel = dynamic_cast<DoraLoveChannel *>(parsed.channel.get());
		if (!channel || channel->runtime() != runtime || !channel->channel())
			throw ::love::Exception("Channel belongs to another LoveRuntime");
		request.channel.set(channel);
	}

	const std::uint64_t requestId = runtime->_nextScreenshotRequest++;
	runtime->_screenshotRequests.emplace(requestId, std::move(request));
	std::string error;
	if (!runtime->_graphicsBackend->requestScreenshot(requestId, error))
	{
		auto found = runtime->_screenshotRequests.find(requestId);
		if (found != runtime->_screenshotRequests.end())
		{
			if (found->second.callbackReference != LUA_NOREF)
				luaL_unref(state, LUA_REGISTRYINDEX, found->second.callbackReference);
			runtime->_screenshotRequests.erase(found);
		}
		throw ::love::Exception("Love screenshot request failed: %s",
			error.empty() ? "Dora renderer rejected the capture" : error.c_str());
	}
}

int LoveRuntime::pushGraphicsState(lua_State *state, bool saveAll)
{
	auto *runtime = this;
	GraphicsState saved;
	saved.transform = runtime->_graphicsTransform;
	saved.all = saveAll;
	if (saveAll)
	{
		std::copy(std::begin(runtime->_graphicsColor), std::end(runtime->_graphicsColor), saved.color);
		std::copy(std::begin(runtime->_graphicsBackgroundColor),
			std::end(runtime->_graphicsBackgroundColor), saved.backgroundColor);
		saved.defaultFilter = runtime->_graphicsDefaultFilter;
		saved.defaultAnisotropy = runtime->_graphicsDefaultAnisotropy;
		saved.lineWidth = runtime->_graphicsLineWidth;
		saved.lineStyle = runtime->_graphicsLineStyle;
		saved.lineJoin = runtime->_graphicsLineJoin;
		saved.pointSize = runtime->_graphicsPointSize;
		saved.blendMode = runtime->_graphicsBlendMode;
		saved.blendAlphaMode = runtime->_graphicsBlendAlphaMode;
		saved.scissorEnabled = runtime->_graphicsScissorEnabled;
		std::copy(std::begin(runtime->_graphicsScissor), std::end(runtime->_graphicsScissor), saved.scissor);
		std::copy(std::begin(runtime->_graphicsColorMask), std::end(runtime->_graphicsColorMask), saved.colorMask);
		saved.depthCompare = runtime->_graphicsDepthCompare;
		saved.depthWrite = runtime->_graphicsDepthWrite;
		saved.meshCullMode = runtime->_graphicsMeshCullMode;
		saved.frontFaceWinding = runtime->_graphicsFrontFaceWinding;
		saved.wireframe = runtime->_graphicsWireframe;
		saved.canvases = runtime->_graphicsCanvases;
		saved.canvasTargets = runtime->_graphicsCanvasTargets;
		saved.canvasObjects = runtime->_graphicsCanvasObjects;
		saved.canvasDepthStencil = runtime->_graphicsCanvasDepthStencil;
		saved.canvasDepthStencilTarget = runtime->_graphicsCanvasDepthStencilTarget;
		saved.canvasDepthStencilObject = runtime->_graphicsCanvasDepthStencilObject;
		saved.canvasDepth = runtime->_graphicsCanvasDepth;
		saved.canvasStencil = runtime->_graphicsCanvasStencil;
		saved.stencilTestEnabled = runtime->_graphicsStencilTestEnabled;
		saved.stencilCompare = runtime->_graphicsStencilCompare;
		saved.stencilValue = runtime->_graphicsStencilValue;
		saved.stencilMode = runtime->_graphicsStencilMode;
		saved.shader = runtime->_graphicsShader;
		saved.shaderObject = runtime->_graphicsShaderObject;
		saved.font = runtime->_currentFont;
		saved.fontObject = runtime->_graphicsFontObject;
		for (const int reference : runtime->_graphicsCanvasReferences)
		{
			lua_rawgeti(state, LUA_REGISTRYINDEX, reference);
			saved.canvasReferences.push_back(luaL_ref(state, LUA_REGISTRYINDEX));
		}
		if (runtime->_graphicsCanvasDepthStencilReference != LUA_NOREF)
		{
			lua_rawgeti(state, LUA_REGISTRYINDEX,
				runtime->_graphicsCanvasDepthStencilReference);
			saved.canvasDepthStencilReference = luaL_ref(state, LUA_REGISTRYINDEX);
		}
	}
	runtime->_graphicsStateStack.push_back(saved);
	return 0;
}

int LoveRuntime::popGraphicsState(lua_State *state)
{
	auto *runtime = this;
	if (runtime->_graphicsStateStack.empty())
		return luaL_error(state, "too many love.graphics.pop calls");
	GraphicsState saved = std::move(runtime->_graphicsStateStack.back());
	runtime->_graphicsStateStack.pop_back();
	runtime->_graphicsTransform = saved.transform;
	if (saved.all)
	{
		const bool blendChanged = saved.blendMode != runtime->_graphicsBlendMode
			|| saved.blendAlphaMode != runtime->_graphicsBlendAlphaMode;
		const bool scissorChanged = saved.scissorEnabled != runtime->_graphicsScissorEnabled
			|| !std::equal(std::begin(saved.scissor), std::end(saved.scissor),
				std::begin(runtime->_graphicsScissor));
		const bool colorMaskChanged = !std::equal(std::begin(saved.colorMask),
			std::end(saved.colorMask), std::begin(runtime->_graphicsColorMask));
		const bool depthChanged = saved.depthCompare != runtime->_graphicsDepthCompare
			|| saved.depthWrite != runtime->_graphicsDepthWrite;
		const bool cullChanged = saved.meshCullMode != runtime->_graphicsMeshCullMode
			|| saved.frontFaceWinding != runtime->_graphicsFrontFaceWinding;
		const bool wireframeChanged = saved.wireframe != runtime->_graphicsWireframe;
		const bool stencilChanged = saved.stencilCompare != runtime->_graphicsStencilCompare
			|| saved.stencilValue != runtime->_graphicsStencilValue
			|| saved.stencilMode != runtime->_graphicsStencilMode;
		std::copy(std::begin(saved.color), std::end(saved.color), runtime->_graphicsColor);
		std::copy(std::begin(saved.backgroundColor), std::end(saved.backgroundColor),
			runtime->_graphicsBackgroundColor);
		runtime->_graphicsDefaultFilter = saved.defaultFilter;
		runtime->_graphicsDefaultAnisotropy = saved.defaultAnisotropy;
		runtime->_graphicsLineWidth = saved.lineWidth;
		runtime->_graphicsLineStyle = saved.lineStyle;
		runtime->_graphicsLineJoin = saved.lineJoin;
		runtime->_graphicsPointSize = saved.pointSize;
		runtime->_graphicsBlendMode = saved.blendMode;
		runtime->_graphicsBlendAlphaMode = saved.blendAlphaMode;
		runtime->_graphicsScissorEnabled = saved.scissorEnabled;
		std::copy(std::begin(saved.scissor), std::end(saved.scissor), runtime->_graphicsScissor);
		std::copy(std::begin(saved.colorMask), std::end(saved.colorMask), runtime->_graphicsColorMask);
		runtime->_graphicsDepthCompare = saved.depthCompare;
		runtime->_graphicsDepthWrite = saved.depthWrite;
		runtime->_graphicsMeshCullMode = saved.meshCullMode;
		runtime->_graphicsFrontFaceWinding = saved.frontFaceWinding;
		runtime->_graphicsWireframe = saved.wireframe;
		if (runtime->_graphicsBackend)
		{
			std::string error;
			if ((saved.canvasTargets != runtime->_graphicsCanvasTargets
				|| saved.canvasDepthStencil != runtime->_graphicsCanvasDepthStencil
				|| saved.canvasDepth != runtime->_graphicsCanvasDepth
				|| saved.canvasStencil != runtime->_graphicsCanvasStencil)
				&& !runtime->_graphicsBackend->setCanvasTargets(saved.canvasTargets,
					saved.canvasDepthStencil != 0 ? &saved.canvasDepthStencilTarget : nullptr,
					saved.canvasDepth, saved.canvasStencil, error))
				return luaL_error(state, "%s", error.c_str());
			if (blendChanged && !runtime->_graphicsBackend->setBlendMode(
				saved.blendMode, saved.blendAlphaMode, error))
				return luaL_error(state, "%s", error.c_str());
			if (scissorChanged)
				runtime->_graphicsBackend->setScissor(saved.scissorEnabled,
					saved.scissor[0], saved.scissor[1], saved.scissor[2], saved.scissor[3]);
			if (colorMaskChanged)
				runtime->_graphicsBackend->setColorMask(saved.colorMask[0], saved.colorMask[1],
					saved.colorMask[2], saved.colorMask[3]);
			if (depthChanged)
				runtime->_graphicsBackend->setDepthMode(saved.depthCompare, saved.depthWrite);
			if (cullChanged)
				runtime->_graphicsBackend->setMeshCullMode(saved.meshCullMode, saved.frontFaceWinding);
			if (wireframeChanged) runtime->_graphicsBackend->setWireframe(saved.wireframe);
			if (stencilChanged)
			{
				std::string error;
				if (!runtime->_graphicsBackend->setStencilMode(
					saved.stencilMode, saved.stencilValue, error))
					return luaL_error(state, "%s", error.c_str());
				if (saved.stencilMode == "custom")
					runtime->_graphicsBackend->setStencilTest(
						saved.stencilCompare, saved.stencilValue);
			}
			if (saved.shader != runtime->_graphicsShader
				&& !runtime->_graphicsBackend->setShader(saved.shader, error))
				return luaL_error(state, "%s", error.c_str());
		}
		for (const int reference : runtime->_graphicsCanvasReferences)
			luaL_unref(state, LUA_REGISTRYINDEX, reference);
		if (runtime->_graphicsCanvasDepthStencilReference != LUA_NOREF)
			luaL_unref(state, LUA_REGISTRYINDEX,
				runtime->_graphicsCanvasDepthStencilReference);
		runtime->_graphicsCanvases = std::move(saved.canvases);
		runtime->_graphicsCanvasTargets = std::move(saved.canvasTargets);
		runtime->_graphicsCanvasObjects = std::move(saved.canvasObjects);
		runtime->_graphicsCanvasReferences = std::move(saved.canvasReferences);
		runtime->_graphicsCanvasDepthStencil = saved.canvasDepthStencil;
		runtime->_graphicsCanvasDepthStencilTarget = saved.canvasDepthStencilTarget;
		runtime->_graphicsCanvasDepthStencilObject = std::move(saved.canvasDepthStencilObject);
		runtime->_graphicsCanvasDepthStencilReference = saved.canvasDepthStencilReference;
		runtime->_graphicsCanvasDepth = saved.canvasDepth;
		runtime->_graphicsCanvasStencil = saved.canvasStencil;
		runtime->_graphicsStencilTestEnabled = saved.stencilTestEnabled;
		runtime->_graphicsStencilCompare = std::move(saved.stencilCompare);
		runtime->_graphicsStencilValue = saved.stencilValue;
		runtime->_graphicsStencilMode = std::move(saved.stencilMode);
		runtime->_graphicsStencilWriting = runtime->_graphicsStencilMode == "draw";
		runtime->_graphicsShader = saved.shader;
		runtime->_graphicsShaderObject = std::move(saved.shaderObject);
		runtime->_currentFont = saved.font;
		runtime->_graphicsFontObject = std::move(saved.fontObject);
	}
	return 0;
}

void DoraLoveGraphics::reset(lua_State *state)
{
	auto *runtime = _runtime;
	if (runtime->_graphicsBackend)
	{
		std::string error;
		if (runtime->_graphicsStencilWriting)
			runtime->_graphicsBackend->endStencilWrite();
		if (!runtime->_graphicsBackend->setCanvases({}, 0, false, false, error))
			luaL_error(state, "%s", error.c_str());
		if (!runtime->_graphicsBackend->setShader(0, error))
			luaL_error(state, "%s", error.c_str());
		if (!runtime->_graphicsBackend->setBlendMode("alpha", "alphamultiply", error))
			luaL_error(state, "%s", error.c_str());
		runtime->_graphicsBackend->setScissor(false, 0.0f, 0.0f, 0.0f, 0.0f);
		runtime->_graphicsBackend->setColorMask(true, true, true, true);
		runtime->_graphicsBackend->setDepthMode("always", false);
		runtime->_graphicsBackend->setMeshCullMode("none", "ccw");
		runtime->_graphicsBackend->setWireframe(false);
		runtime->_graphicsBackend->setStencilTest("always", 0);
	}
	for (const int reference : runtime->_graphicsCanvasReferences)
		luaL_unref(state, LUA_REGISTRYINDEX, reference);
	runtime->_graphicsCanvasReferences.clear();
	runtime->_graphicsCanvasObjects.clear();
	runtime->_graphicsCanvases.clear();
	runtime->_graphicsCanvasTargets.clear();
	if (runtime->_graphicsCanvasDepthStencilReference != LUA_NOREF)
		luaL_unref(state, LUA_REGISTRYINDEX,
			runtime->_graphicsCanvasDepthStencilReference);
	runtime->_graphicsCanvasDepthStencil = 0;
	runtime->_graphicsCanvasDepthStencilTarget = {};
	runtime->_graphicsCanvasDepthStencilObject.set(nullptr);
	runtime->_graphicsCanvasDepthStencilReference = LUA_NOREF;
	runtime->_graphicsCanvasDepth = false;
	runtime->_graphicsCanvasStencil = false;
	runtime->_graphicsShader = 0;
	runtime->_graphicsShaderObject.set(nullptr);
	runtime->_graphicsStencilWriting = false;
	runtime->_graphicsStencilTestEnabled = false;
	runtime->_graphicsStencilCompare = "always";
	runtime->_graphicsStencilValue = 0;
	runtime->_graphicsStencilMode = "off";
	runtime->_graphicsColor[0] = runtime->_graphicsColor[1]
		= runtime->_graphicsColor[2] = runtime->_graphicsColor[3] = 1.0f;
	runtime->_graphicsBackgroundColor[0] = runtime->_graphicsBackgroundColor[1]
		= runtime->_graphicsBackgroundColor[2] = 0.0f;
	runtime->_graphicsBackgroundColor[3] = 1.0f;
	runtime->_graphicsDefaultFilter = GraphicsBackend::TextureFilter::Linear;
	runtime->_graphicsDefaultAnisotropy = 1.0f;
	runtime->_graphicsDefaultMipmapFilter.reset();
	runtime->_graphicsDefaultMipmapSharpness = 0.0f;
	runtime->_graphicsLineWidth = 1.0f;
	runtime->_graphicsLineStyle = GraphicsBackend::LineStyle::Smooth;
	runtime->_graphicsLineJoin = GraphicsBackend::LineJoin::Miter;
	runtime->_graphicsPointSize = 1.0f;
	runtime->_graphicsBlendMode = "alpha";
	runtime->_graphicsBlendAlphaMode = "alphamultiply";
	runtime->_graphicsScissorEnabled = false;
	std::fill(std::begin(runtime->_graphicsScissor), std::end(runtime->_graphicsScissor), 0.0f);
	std::fill(std::begin(runtime->_graphicsColorMask), std::end(runtime->_graphicsColorMask), true);
	runtime->_graphicsDepthCompare = "always";
	runtime->_graphicsDepthWrite = false;
	runtime->_graphicsMeshCullMode = "none";
	runtime->_graphicsFrontFaceWinding = "ccw";
	runtime->_graphicsWireframe = false;
	runtime->_currentFont = 0;
	runtime->_graphicsFontObject.set(nullptr);
	runtime->resetGraphicsTransform();
}

void DoraLoveGraphics::present(lua_State *state)
{
	if (!_runtime->_graphicsFrameActive)
		luaL_error(state,
			"love.graphics.present is only available during the Dora-driven love.draw frame");
	// The embedded host owns the RenderTarget pass boundary. LoveRuntime::draw closes it
	// exactly once after the callback returns, so explicit present calls are compatible
	// barriers without swapping the Dora window or submitting the same pass twice.
}

void DoraLoveGraphics::flushBatch()
{
	// LoveNode records each draw as an ordered Dora render command with its state
	// captured at submission time, rather than accumulating Love stream batches.
}

namespace
{
void layoutTextEntry(TextEntry &entry, GraphicsBackend &graphics,
	GraphicsBackend::FontHandle font)
{
	entry.runs.clear(); entry.width = 0.0f; entry.height = 0.0f;
	std::string flattened;
	std::vector<std::pair<std::size_t, std::size_t>> fragmentRanges;
	for (const auto &fragment : entry.fragments)
	{
		const std::size_t start = flattened.size(); flattened += fragment.text;
		fragmentRanges.emplace_back(start, flattened.size());
	}
	if (flattened.empty()) return;
	std::vector<std::uint32_t> decoded;
	std::string decodeError;
	if (!decodeUtf8(flattened, decoded, decodeError)) return;
	std::vector<LoveTextLayout::Codepoint> codepoints;
	codepoints.reserve(decoded.size());
	std::size_t byteOffset = 0;
	std::size_t fragmentIndex = 0;
	for (const auto value : decoded)
	{
		while (fragmentIndex + 1 < fragmentRanges.size()
			&& byteOffset >= fragmentRanges[fragmentIndex].second)
			++fragmentIndex;
		const std::size_t end = byteOffset + encodeUtf8(value).size();
		codepoints.push_back({value, byteOffset, end, fragmentIndex});
		byteOffset = end;
	}
	auto spacing = [&graphics, font](std::uint32_t value) {
		return graphics.getFontGlyphSpacing(font, value);
	};
	auto kerning = [&graphics, font](std::uint32_t left, std::uint32_t right) {
		return graphics.getFontKerning(font, left, right);
	};
	std::vector<LoveTextLayout::Line> lines;
	const float formattedWrap = std::max(entry.wrap, 0.0f);
	if (entry.formatted)
		lines = LoveTextLayout::wrap(codepoints, formattedWrap, spacing, kerning);
	else
	{
		LoveTextLayout::Line line;
		for (const auto &codepoint : codepoints)
		{
			if (codepoint.value == '\n')
			{
				line.width = LoveTextLayout::measure(line.codepoints, spacing, kerning);
				lines.push_back(std::move(line));
				line = {};
			}
			else if (codepoint.value != '\r')
				line.codepoints.push_back(codepoint);
		}
		line.width = LoveTextLayout::measure(line.codepoints, spacing, kerning);
		lines.push_back(std::move(line));
	}
	const float lineAdvance = graphics.getFontHeight(font) * graphics.getFontLineHeight(font);
	const float effectiveLineAdvance = entry.formatted
		? lineAdvance : std::floor(lineAdvance + 0.5f);
	float lineY = 0.0f;
	for (std::size_t lineIndex = 0; lineIndex < lines.size(); ++lineIndex)
	{
		const auto &line = lines[lineIndex];
		const float lineWidth = line.width;
		entry.width = std::max(entry.width, lineWidth);
		const float offsetX = entry.align == "center" ? std::floor((formattedWrap - lineWidth) * 0.5f)
			: entry.align == "right" ? std::floor(formattedWrap - lineWidth) : 0.0f;
		const std::size_t spaces = entry.align == "justify"
			? static_cast<std::size_t>(std::count_if(line.codepoints.begin(), line.codepoints.end(),
				[](const auto &codepoint) { return codepoint.value == ' '; })) : 0;
		const float extraSpacing = spaces > 0 && lineWidth < formattedWrap
			? (formattedWrap - lineWidth) / static_cast<float>(spaces) : 0.0f;
		float cursor = offsetX;
		std::uint32_t previous = 0;
		for (std::size_t index = 0; index < line.codepoints.size();)
		{
			const auto colorIndex = line.codepoints[index].colorIndex;
			TextLayoutRun run;
			run.x = cursor + kerning(previous, line.codepoints[index].value);
			run.y = std::floor(lineY);
			std::copy(std::begin(entry.fragments[colorIndex].color),
				std::end(entry.fragments[colorIndex].color), std::begin(run.color));
			while (index < line.codepoints.size()
				&& line.codepoints[index].colorIndex == colorIndex)
			{
				const auto &codepoint = line.codepoints[index];
				run.text.append(flattened.substr(codepoint.sourceBegin,
					codepoint.sourceEnd - codepoint.sourceBegin));
				cursor += kerning(previous, codepoint.value) + spacing(codepoint.value);
				previous = codepoint.value;
				++index;
				if (entry.align == "justify" && codepoint.value == ' ')
				{
					cursor = std::floor(cursor + extraSpacing);
					break;
				}
			}
			entry.runs.push_back(std::move(run));
		}
		lineY += effectiveLineAdvance;
	}
	if (entry.formatted)
		entry.height = std::floor(lineY);
	else
	{
		entry.height = lines.size() <= 1 ? (lines.front().codepoints.empty() ? 0.0f : effectiveLineAdvance)
			: static_cast<float>(lines.size() - 1) * effectiveLineAdvance
				+ (lines.back().codepoints.empty() ? 0.0f : effectiveLineAdvance);
	}
}

void drawTextEntry(GraphicsBackend &graphics, GraphicsBackend::FontHandle font,
	TextEntry &entry, float currentA, float currentB, float currentC, float currentD,
	float currentTx, float currentTy, const float *currentColor,
	float x, float y, float angle, float scaleX, float scaleY,
	float originX, float originY, float shearX, float shearY)
{
	layoutTextEntry(entry, graphics, font);
	TransformMatrix local;
	setTransform(local, x, y, angle, scaleX, scaleY, originX, originY, shearX, shearY);
	TransformMatrix outer;
	setTransformIdentity(outer);
	outer.elements[0] = currentA;
	outer.elements[1] = currentB;
	outer.elements[4] = currentC;
	outer.elements[5] = currentD;
	outer.elements[12] = currentTx;
	outer.elements[13] = currentTy;
	TransformMatrix combined;
	multiplyTransforms(outer, local, combined);
	for (const auto &run : entry.runs)
	{
		const float tx = combined.elements[12] + combined.elements[0] * run.x
			+ combined.elements[4] * run.y;
		const float ty = combined.elements[13] + combined.elements[1] * run.x
			+ combined.elements[5] * run.y;
		graphics.drawText(font, run.text, -1.0f, "left",
			combined.elements[0], combined.elements[1], combined.elements[4], combined.elements[5],
			tx, ty, 0.0f, 0.0f, run.color[0] * currentColor[0],
			run.color[1] * currentColor[1], run.color[2] * currentColor[2],
			run.color[3] * currentColor[3]);
	}
}

void readStandardTransform(lua_State *state, int index, TransformMatrix &transform,
	const char *errorMessage)
{
	::love::graphics::luax_checkstandardtransform(state, index,
		[&](const ::love::Matrix4 &matrix)
		{
			std::copy_n(matrix.getElements(), 16, transform.elements);
		});
	for (const float value : transform.elements)
		luaL_argcheck(state, std::isfinite(value), index, errorMessage);
}

GraphicsBackend::Transform2D readDrawTransform(lua_State *state, int index,
	const GraphicsBackend::Transform2D &current, const char *errorMessage,
	float *originX = nullptr, float *originY = nullptr)
{
	const bool providedTransform = luaL_testudata(state, index,
		::love::math::Transform::type.getName()) != nullptr;
	TransformMatrix local;
	readStandardTransform(state, index, local, errorMessage);
	luaL_argcheck(state, isAffine2DTransform(local), index,
		"embedded Dora graphics currently requires an affine 2D Transform");
	if (originX && originY)
	{
		*originX = providedTransform ? 0.0f
			: static_cast<float>(luaL_optnumber(state, index + 5, 0.0));
		*originY = providedTransform ? 0.0f
			: static_cast<float>(luaL_optnumber(state, index + 6, 0.0));
		// Image backends retain the historic split representation: x/y stay in
		// the matrix and the origin is applied separately by drawTexture.
		local.elements[12] += *originX * local.elements[0] + *originY * local.elements[4];
		local.elements[13] += *originX * local.elements[1] + *originY * local.elements[5];
	}
	GraphicsBackend::Transform2D result;
	result.a = current.a * local.elements[0] + current.c * local.elements[1];
	result.b = current.b * local.elements[0] + current.d * local.elements[1];
	result.c = current.a * local.elements[4] + current.c * local.elements[5];
	result.d = current.b * local.elements[4] + current.d * local.elements[5];
	result.tx = current.a * local.elements[12] + current.c * local.elements[13] + current.tx;
	result.ty = current.b * local.elements[12] + current.d * local.elements[13] + current.ty;
	return result;
}

GraphicsBackend::Transform2D combineDrawTransform(lua_State *state,
	const ::love::Matrix4 &matrix, const GraphicsBackend::Transform2D &current,
	int argumentIndex, const char *errorMessage)
{
	TransformMatrix local;
	std::copy_n(matrix.getElements(), 16, local.elements);
	for (const float value : local.elements)
		luaL_argcheck(state, std::isfinite(value), argumentIndex, errorMessage);
	luaL_argcheck(state, isAffine2DTransform(local), argumentIndex,
		"embedded Dora graphics currently requires an affine 2D Transform");
	GraphicsBackend::Transform2D result;
	result.a = current.a * local.elements[0] + current.c * local.elements[1];
	result.b = current.b * local.elements[0] + current.d * local.elements[1];
	result.c = current.a * local.elements[4] + current.c * local.elements[5];
	result.d = current.b * local.elements[4] + current.d * local.elements[5];
	result.tx = current.a * local.elements[12] + current.c * local.elements[13] + current.tx;
	result.ty = current.b * local.elements[12] + current.d * local.elements[13] + current.ty;
	return result;
}
}

namespace
{
std::vector<TextFragment> textFragments(
	const std::vector<::love::graphics::Font::ColoredString> &text)
{
	std::vector<TextFragment> fragments;
	fragments.reserve(text.size());
	for (const auto &part : text)
	{
		const float values[] = {part.color.r, part.color.g, part.color.b, part.color.a};
		for (float value : values)
			if (!std::isfinite(value))
				throw ::love::Exception("Text color must be finite.");
		TextFragment fragment;
		fragment.text = part.str;
		fragment.color[0] = std::clamp(part.color.r, 0.0f, 1.0f);
		fragment.color[1] = std::clamp(part.color.g, 0.0f, 1.0f);
		fragment.color[2] = std::clamp(part.color.b, 0.0f, 1.0f);
		fragment.color[3] = std::clamp(part.color.a, 0.0f, 1.0f);
		fragments.push_back(std::move(fragment));
	}
	return fragments;
}

std::string textAlignment(::love::graphics::Font::AlignMode align)
{
	const char *name = nullptr;
	if (!::love::graphics::Font::getConstant(align, name))
		throw ::love::Exception("Invalid Text alignment.");
	return name;
}

TransformMatrix textTransform(const ::love::Matrix4 &matrix)
{
	TransformMatrix result;
	std::copy_n(matrix.getElements(), 16, result.elements);
	for (float value : result.elements)
		if (!std::isfinite(value))
			throw ::love::Exception("Text transform values must be finite.");
	if (!isAffine2DTransform(result))
		throw ::love::Exception(
			"embedded Dora graphics currently requires an affine 2D Transform");
	return result;
}

bool emptyText(const std::vector<::love::graphics::Font::ColoredString> &text)
{
	return std::all_of(text.begin(), text.end(),
		[](const auto &part) { return part.str.empty(); });
}
}

void DoraLoveGraphics::print(
	const std::vector<::love::graphics::Font::ColoredString> &text,
	::love::graphics::Font *requestedFont, const ::love::Matrix4 &matrix)
{
	auto *font = requestedFont ? dynamic_cast<FontUserdata *>(requestedFont)
		: dynamic_cast<FontUserdata *>(getFont());
	if (!font || font->runtime != _runtime || !_runtime->_fontHandles.contains(font->handle))
		throw ::love::Exception("Font belongs to another or closed LoveRuntime");
	std::string error;
	if (!_runtime->_graphicsBackend->validateShaderDraw(error))
		throw ::love::Exception("%s", error.c_str());
	const auto transform = combineDrawTransform(_runtime->getState(), matrix,
		_runtime->_graphicsTransform, 2, "print transform values must be finite");
	TextEntry entry;
	entry.fragments = textFragments(text);
	entry.wrap = -1.0f;
	entry.align = "left";
	drawTextEntry(*_runtime->_graphicsBackend, font->handle, entry,
		transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty,
		_runtime->_graphicsColor, 0, 0, 0, 1, 1, 0, 0, 0, 0);
}

void DoraLoveGraphics::printf(
	const std::vector<::love::graphics::Font::ColoredString> &text,
	::love::graphics::Font *requestedFont, float wrap,
	::love::graphics::Font::AlignMode align, const ::love::Matrix4 &matrix)
{
	auto *font = requestedFont ? dynamic_cast<FontUserdata *>(requestedFont)
		: dynamic_cast<FontUserdata *>(getFont());
	if (!font || font->runtime != _runtime || !_runtime->_fontHandles.contains(font->handle))
		throw ::love::Exception("Font belongs to another or closed LoveRuntime");
	std::string error;
	if (!_runtime->_graphicsBackend->validateShaderDraw(error))
		throw ::love::Exception("%s", error.c_str());
	const auto transform = combineDrawTransform(_runtime->getState(), matrix,
		_runtime->_graphicsTransform, 2, "printf transform values must be finite");
	TextEntry entry;
	entry.fragments = textFragments(text);
	entry.wrap = std::max(wrap, 0.0f);
	entry.formatted = true;
	entry.align = textAlignment(align);
	drawTextEntry(*_runtime->_graphicsBackend, font->handle, entry,
		transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty,
		_runtime->_graphicsColor, 0, 0, 0, 1, 1, 0, 0, 0, 0);
}

TextUserdata::TextUserdata(LoveRuntime *valueRuntime, FontUserdata *valueFont,
	const std::vector<::love::graphics::Font::ColoredString> &text)
	: runtime(valueRuntime), font(valueFont ? valueFont->handle : 0), fontObject(valueFont)
{
	if (!runtime || !runtime->getGraphicsBackend() || !valueFont
		|| valueFont->runtime != runtime || valueFont->handle == 0)
		throw ::love::Exception("Font belongs to another or closed LoveRuntime.");
	if (!emptyText(text)) set(text);
}

void TextUserdata::set(const std::vector<::love::graphics::Font::ColoredString> &text)
{
	if (emptyText(text)) return clear();
	TextEntry entry;
	entry.fragments = textFragments(text);
	setTransformIdentity(entry.transform);
	layoutTextEntry(entry, *runtime->getGraphicsBackend(), font);
	entries.clear();
	entries.push_back(std::move(entry));
}

void TextUserdata::set(const std::vector<::love::graphics::Font::ColoredString> &text,
	float wrap, ::love::graphics::Font::AlignMode align)
{
	if (!std::isfinite(wrap))
		throw ::love::Exception("Text wrap limit must be finite.");
	if (emptyText(text)) return clear();
	TextEntry entry;
	entry.fragments = textFragments(text);
	entry.wrap = wrap;
	entry.formatted = true;
	entry.align = textAlignment(align);
	setTransformIdentity(entry.transform);
	layoutTextEntry(entry, *runtime->getGraphicsBackend(), font);
	entries.clear();
	entries.push_back(std::move(entry));
}

int TextUserdata::add(const std::vector<::love::graphics::Font::ColoredString> &text,
	const ::love::Matrix4 &transform)
{
	TextEntry entry;
	entry.fragments = textFragments(text);
	entry.transform = textTransform(transform);
	layoutTextEntry(entry, *runtime->getGraphicsBackend(), font);
	entries.push_back(std::move(entry));
	return static_cast<int>(entries.size() - 1);
}

int TextUserdata::addf(const std::vector<::love::graphics::Font::ColoredString> &text,
	float wrap, ::love::graphics::Font::AlignMode align,
	const ::love::Matrix4 &transform)
{
	if (!std::isfinite(wrap))
		throw ::love::Exception("Text wrap limit must be finite.");
	TextEntry entry;
	entry.fragments = textFragments(text);
	entry.wrap = wrap;
	entry.formatted = true;
	entry.align = textAlignment(align);
	entry.transform = textTransform(transform);
	layoutTextEntry(entry, *runtime->getGraphicsBackend(), font);
	entries.push_back(std::move(entry));
	return static_cast<int>(entries.size() - 1);
}

void TextUserdata::setFont(::love::graphics::Font *base)
{
	auto *value = dynamic_cast<FontUserdata *>(base);
	if (!value || value->runtime != runtime || value->handle == 0)
		throw ::love::Exception("Font belongs to another or closed LoveRuntime.");
	font = value->handle;
	fontObject.set(value);
	for (auto &entry : entries)
		layoutTextEntry(entry, *runtime->getGraphicsBackend(), font);
}

int TextUserdata::getWidth(int index) const
{
	if (index < 0) index = std::max(static_cast<int>(entries.size()) - 1, 0);
	return index < static_cast<int>(entries.size())
		? static_cast<int>(entries[static_cast<std::size_t>(index)].width) : 0;
}

int TextUserdata::getHeight(int index) const
{
	if (index < 0) index = std::max(static_cast<int>(entries.size()) - 1, 0);
	return index < static_cast<int>(entries.size())
		? static_cast<int>(entries[static_cast<std::size_t>(index)].height) : 0;
}

::love::graphics::Text *DoraLoveGraphics::newText(::love::graphics::Font *base,
	const std::vector<::love::graphics::Font::ColoredString> &text)
{
	auto *font = dynamic_cast<FontUserdata *>(base);
	if (!_runtime || !_runtime->_graphicsBackend || !font
		|| font->runtime != _runtime || font->handle == 0)
		throw ::love::Exception("Font belongs to another or closed LoveRuntime.");
	return new TextUserdata(_runtime, font, text);
}

::love::graphics::Video *DoraLoveGraphics::newVideo(
	::love::video::VideoStream *base, float dpiScale)
{
	if (!_runtime || !_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	auto *stream = dynamic_cast<VideoStreamUserdata *>(base);
	if (!stream || stream->state->runtime != _runtime)
		throw ::love::Exception("VideoStream belongs to another LoveRuntime");
	if (!std::isfinite(dpiScale) || dpiScale <= 0.0f)
		throw ::love::Exception("dpiscale must be a positive finite number");
	const int width = stream->getWidth();
	const int height = stream->getHeight();
	std::vector<std::uint8_t> blank(static_cast<std::size_t>(width) * height * 4, 0);
	std::string error;
	const auto image = _runtime->_graphicsBackend->newImage(
		GraphicsBackend::TextureType::Texture2D, width, height, 1, blank, error);
	if (image == 0)
		throw ::love::Exception("Love Video texture creation failed: %s", error.c_str());
	return new VideoUserdata(_runtime, stream, image, dpiScale);
}

::love::graphics::Canvas *DoraLoveGraphics::newCanvas(
	const ::love::graphics::Canvas::Settings &value)
{
	if (!_runtime || !_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	if (value.width <= 0 || value.height <= 0 || value.layers <= 0)
		throw ::love::Exception("Canvas dimensions must be greater than 0.");
	if (!std::isfinite(value.dpiScale) || value.dpiScale <= 0.0f)
		throw ::love::Exception("Canvas dpiscale must be positive and finite");
	const int pixelWidth = static_cast<int>(value.width * value.dpiScale + 0.5f);
	const int pixelHeight = static_cast<int>(value.height * value.dpiScale + 0.5f);
	if (pixelWidth <= 0 || pixelWidth > MaximumWindowDimension
		|| pixelHeight <= 0 || pixelHeight > MaximumWindowDimension)
		throw ::love::Exception("Canvas pixel dimensions must be between 1 and 16384");
	if (value.msaa != 0 && value.msaa != 2 && value.msaa != 4
		&& value.msaa != 8 && value.msaa != 16)
		throw ::love::Exception("Canvas msaa must be 0, 2, 4, 8, or 16");

	GraphicsBackend::CanvasSettings settings;
	settings.dpiScale = value.dpiScale;
	settings.msaa = value.msaa;
	settings.slices = value.layers;
	switch (value.type)
	{
		case ::love::graphics::TEXTURE_2D: settings.type = GraphicsBackend::TextureType::Texture2D; break;
		case ::love::graphics::TEXTURE_2D_ARRAY: settings.type = GraphicsBackend::TextureType::Array; break;
		case ::love::graphics::TEXTURE_CUBE: settings.type = GraphicsBackend::TextureType::Cube; settings.slices = 6; break;
		case ::love::graphics::TEXTURE_VOLUME: settings.type = GraphicsBackend::TextureType::Volume; break;
		default: throw ::love::Exception("Unsupported Canvas texture type");
	}
	if (settings.type == GraphicsBackend::TextureType::Cube && value.width != value.height)
		throw ::love::Exception("cube Canvas must be square");
	if (settings.type != GraphicsBackend::TextureType::Texture2D && value.msaa > 1)
		throw ::love::Exception("MSAA is only supported for Canvases with the 2D texture type.");

	const char *format = nullptr;
	if (!::love::getConstant(value.format, format))
		throw ::love::Exception("Unknown Canvas pixel format");
	settings.format = std::string_view(format) == "normal" ? std::string_view("rgba8")
		: std::string_view(format) == "hdr" ? std::string_view("rgba16f")
		: std::string_view(format);
	settings.readable = value.readable.hasValue ? value.readable.value
		: !::love::isPixelFormatDepthStencil(value.format);
	if (!_runtime->_graphicsBackend->isCanvasFormatSupported(format, settings.readable))
		throw ::love::Exception("Canvas format '%s' is not supported by the Dora graphics backend", format);
	settings.mipmapMode = value.mipmaps == ::love::graphics::Canvas::MIPMAPS_MANUAL ? "manual"
		: value.mipmaps == ::love::graphics::Canvas::MIPMAPS_AUTO ? "auto" : "none";

	std::string error;
	const auto handle = _runtime->_graphicsBackend->newCanvas(pixelWidth, pixelHeight, settings, error);
	if (handle == 0)
		throw ::love::Exception("Love Canvas %dx%d creation failed: %s", value.width, value.height,
			error.empty() ? "failed to create Dora RenderTarget" : error.c_str());
	auto *canvas = new CanvasUserdata(_runtime, handle, pixelWidth, pixelHeight, settings);
	canvas->filter = _runtime->_graphicsDefaultFilter;
	canvas->anisotropy = _runtime->_graphicsDefaultAnisotropy;
	canvas->textureType = settings.type;
	canvas->slices = settings.slices;
	canvas->dpiScale = settings.dpiScale;
	canvas->mipmapMode = std::string(settings.mipmapMode);
	canvas->mipmapCount = settings.mipmapMode == "none" ? 1
		: totalImageMipmapCount(pixelWidth, pixelHeight,
			settings.type == GraphicsBackend::TextureType::Volume ? settings.slices : 1);
	if (canvas->mipmapCount > 1)
	{
		canvas->mipmapFilter = _runtime->_graphicsDefaultMipmapFilter;
		canvas->mipmapSharpness = _runtime->_graphicsDefaultMipmapSharpness;
	}
	canvas->syncUpstreamMetadata();
	return canvas;
}

::love::graphics::Mesh *DoraLoveGraphics::newMesh(
	const std::vector<::love::graphics::Vertex> &vertices,
	::love::graphics::PrimitiveType drawmode,
	::love::graphics::vertex::Usage usage)
{
	auto *mesh = newDoraMesh(_runtime, ::love::graphics::Mesh::getDefaultVertexFormat(),
		vertices.size(), drawmode, usage);
	for (std::size_t index = 0; index < vertices.size(); ++index)
	{
		const auto &source = vertices[index];
		float *target = mesh->values.data() + index * mesh->componentCount;
		target[0] = source.x;
		target[1] = source.y;
		target[2] = source.s;
		target[3] = source.t;
		target[4] = source.color.r / 255.0f;
		target[5] = source.color.g / 255.0f;
		target[6] = source.color.b / 255.0f;
		target[7] = source.color.a / 255.0f;
	}
	encodeMeshStorage(*mesh);
	return mesh;
}

::love::graphics::Mesh *DoraLoveGraphics::newMesh(int vertexcount,
	::love::graphics::PrimitiveType drawmode,
	::love::graphics::vertex::Usage usage)
{
	if (vertexcount <= 0)
		throw ::love::Exception("vertex count must be greater than 0");
	return newDoraMesh(_runtime, ::love::graphics::Mesh::getDefaultVertexFormat(),
		static_cast<std::size_t>(vertexcount), drawmode, usage);
}

::love::graphics::Mesh *DoraLoveGraphics::newMesh(
	const std::vector<::love::graphics::Mesh::AttribFormat> &vertexformat,
	int vertexcount, ::love::graphics::PrimitiveType drawmode,
	::love::graphics::vertex::Usage usage)
{
	if (vertexcount <= 0)
		throw ::love::Exception("vertex count must be greater than 0");
	return newDoraMesh(_runtime, vertexformat, static_cast<std::size_t>(vertexcount),
		drawmode, usage);
}

::love::graphics::Mesh *DoraLoveGraphics::newMesh(
	const std::vector<::love::graphics::Mesh::AttribFormat> &vertexformat,
	const void *data, size_t datasize, ::love::graphics::PrimitiveType drawmode,
	::love::graphics::vertex::Usage usage)
{
	auto *mesh = newDoraMesh(_runtime, vertexformat, 1, drawmode, usage);
	if (datasize < mesh->vertexStride)
	{
		mesh->release();
		throw ::love::Exception("Data size is too small for the specified Mesh vertex format");
	}
	mesh->vertexCount = datasize / mesh->vertexStride;
	const auto *bytes = static_cast<const std::uint8_t *>(data);
	mesh->bytes.assign(bytes, bytes + mesh->vertexCount * mesh->vertexStride);
	if (!decodeMeshStorage(*mesh, mesh->bytes, mesh->values))
	{
		mesh->release();
		throw ::love::Exception("Mesh Data contains a non-finite float vertex component");
	}
	return mesh;
}

::love::graphics::SpriteBatch *DoraLoveGraphics::newSpriteBatch(
	::love::graphics::Texture *texture, int size,
	::love::graphics::vertex::Usage usage)
{
	if (!_runtime || !_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	if (size < 1 || size > 1000000)
		throw ::love::Exception("SpriteBatch size must be between 1 and 1000000");
	auto *image = dynamic_cast<ImageUserdata *>(texture);
	auto *canvas = dynamic_cast<CanvasUserdata *>(texture);
	if (!image && !canvas)
		throw ::love::Exception("expected an Image or Canvas");
	if (image)
	{
		if (image->runtime != _runtime || image->handle == 0)
			throw ::love::Exception("Image belongs to another or closed LoveRuntime");
		if (image->textureType != GraphicsBackend::TextureType::Texture2D
			&& image->textureType != GraphicsBackend::TextureType::Array)
			throw ::love::Exception(
				"SpriteBatch requires a 2D Image, ArrayImage, or Canvas");
	}
	else if (canvas->runtime != _runtime || canvas->handle == 0 || !canvas->readable)
		throw ::love::Exception("cannot create a SpriteBatch with a closed or non-readable Canvas");
	const char *usageName = nullptr;
	if (!::love::graphics::vertex::getConstant(usage, usageName))
		throw ::love::Exception("invalid SpriteBatch usage hint");
	auto *batch = new SpriteBatchUserdata;
	batch->runtime = _runtime;
	batch->image = image ? image->handle : 0;
	batch->canvas = canvas ? canvas->handle : 0;
	batch->textureObject.set(image ? static_cast<::love::Object *>(image)
		: static_cast<::love::Object *>(canvas));
	batch->textureType = image ? image->textureType : GraphicsBackend::TextureType::Texture2D;
	batch->layerCount = image ? image->slices : 1;
	batch->bufferSize = static_cast<std::size_t>(size);
	batch->sprites.resize(batch->bufferSize);
	batch->usage = usageName;
	return batch;
}

::love::graphics::ParticleSystem *DoraLoveGraphics::newParticleSystem(
	::love::graphics::Texture *texture, int size)
{
	if (!_runtime || !_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	if (size < 1 || static_cast<::love::uint32>(size) > ::love::graphics::ParticleSystem::MAX_PARTICLES)
		throw ::love::Exception("Invalid ParticleSystem size");
	auto *image = dynamic_cast<ImageUserdata *>(texture);
	auto *canvas = dynamic_cast<CanvasUserdata *>(texture);
	if (!image && !canvas)
		throw ::love::Exception("expected a 2D Image or Canvas");
	auto *system = new ParticleSystemUserdata;
	system->runtime = _runtime;
	try
	{
		system->setTexture(texture);
		system->setBufferSize(static_cast<::love::uint32>(size));
		system->randomState ^= static_cast<std::uint64_t>(
			reinterpret_cast<std::uintptr_t>(system));
	}
	catch (...)
	{
		system->release();
		throw;
	}
	return system;
}

void DoraLoveGraphics::draw(lua_State *state, ::love::graphics::Drawable *drawable,
	::love::graphics::Texture *texture, ::love::graphics::Quad *quad,
	const ::love::Matrix4 &matrix)
{
	if (!_runtime || !_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	auto *requestedTexture = texture ? texture
		: dynamic_cast<::love::graphics::Texture *>(drawable);
	auto *image = dynamic_cast<ImageUserdata *>(requestedTexture);
	auto *canvas = dynamic_cast<CanvasUserdata *>(requestedTexture);
	if (auto *mesh = dynamic_cast<MeshUserdata *>(drawable))
	{
		const auto transform = combineDrawTransform(state, matrix,
			_runtime->_graphicsTransform, 2, "Mesh draw transform values must be finite");
		_runtime->graphicsDrawCommand(state, mesh, &transform);
		return;
	}
	if (auto *batch = dynamic_cast<SpriteBatchUserdata *>(drawable))
	{
		const auto transform = combineDrawTransform(state, matrix,
			_runtime->_graphicsTransform, 2,
			"SpriteBatch draw transform values must be finite");
		_runtime->graphicsDrawCommand(state, batch, &transform);
		return;
	}
	if (auto *particles = dynamic_cast<ParticleSystemUserdata *>(drawable))
	{
		const auto transform = combineDrawTransform(state, matrix,
			_runtime->_graphicsTransform, 2,
			"ParticleSystem draw transform values must be finite");
		_runtime->graphicsDrawCommand(state, particles, &transform);
		return;
	}
	if (auto *text = dynamic_cast<TextUserdata *>(drawable))
	{
		const auto transform = combineDrawTransform(state, matrix,
			_runtime->_graphicsTransform, 2, "Text draw transform values must be finite");
		_runtime->graphicsDrawCommand(state, text, &transform);
		return;
	}
	if (auto *video = dynamic_cast<VideoUserdata *>(drawable))
	{
		const auto transform = combineDrawTransform(state, matrix,
			_runtime->_graphicsTransform, 2, "Video draw transform values must be finite");
		_runtime->graphicsDrawCommand(state, video, &transform);
		return;
	}
	if (!image && !canvas)
	{
		throw ::love::Exception("unsupported Drawable backend");
	}
	if (image)
		luaL_argcheck(state, image->runtime == _runtime && image->handle != 0, 1,
			"Image belongs to another or closed LoveRuntime");
	else
	{
		luaL_argcheck(state, canvas->runtime == _runtime && canvas->handle != 0
			&& _runtime->_canvasHandles.contains(canvas->handle), 1,
			"Canvas belongs to another or closed LoveRuntime");
		luaL_argcheck(state, canvas->readable, 1, "cannot draw a non-readable Canvas");
		luaL_argcheck(state, canvas->textureType == GraphicsBackend::TextureType::Texture2D, 1,
			"non-2D Canvas textures must be drawn with a compatible layered API");
		luaL_argcheck(state, std::find(_runtime->_graphicsCanvases.begin(),
			_runtime->_graphicsCanvases.end(), canvas->handle) == _runtime->_graphicsCanvases.end()
			&& canvas->handle != _runtime->_graphicsCanvasDepthStencil, 1,
			"cannot draw a Canvas to itself");
	}
	std::string shaderError;
	if (!_runtime->_graphicsBackend->validateShaderDraw(shaderError,
		image ? image->textureType : GraphicsBackend::TextureType::Texture2D))
		throw ::love::Exception("%s", shaderError.c_str());
	TransformMatrix local;
	std::copy_n(matrix.getElements(), 16, local.elements);
	for (const float value : local.elements)
		luaL_argcheck(state, std::isfinite(value), quad ? 3 : 2,
			"Texture draw transform values must be finite");
	luaL_argcheck(state, isAffine2DTransform(local), quad ? 3 : 2,
		"embedded Dora graphics currently requires an affine 2D Transform");
	const auto &current = _runtime->_graphicsTransform;
	const float a = current.a * local.elements[0] + current.c * local.elements[1];
	const float b = current.b * local.elements[0] + current.d * local.elements[1];
	const float c = current.a * local.elements[4] + current.c * local.elements[5];
	const float d = current.b * local.elements[4] + current.d * local.elements[5];
	const float tx = current.a * local.elements[12]
		+ current.c * local.elements[13] + current.tx;
	const float ty = current.b * local.elements[12]
		+ current.d * local.elements[13] + current.ty;
	const float imageWidth = static_cast<float>(image
		? _runtime->_graphicsBackend->getImageWidth(image->handle)
		: _runtime->_graphicsBackend->getCanvasWidth(canvas->handle));
	const float imageHeight = static_cast<float>(image
		? _runtime->_graphicsBackend->getImageHeight(image->handle)
		: _runtime->_graphicsBackend->getCanvasHeight(canvas->handle));
	float sourceX = 0.0f;
	float sourceY = 0.0f;
	float sourceWidth = imageWidth;
	float sourceHeight = imageHeight;
	int imageLayer = 0;
	if (quad)
	{
		const auto viewport = quad->getViewport();
		const int layer = quad->getLayer();
		if (image && image->textureType == GraphicsBackend::TextureType::Array)
		{
			luaL_argcheck(state, layer >= 0 && layer < image->slices, 2,
				"Quad layer exceeds the ArrayImage layer count");
			imageLayer = layer;
		}
		else luaL_argcheck(state, layer == 0, 2,
			"non-array embedded Dora Images support only Quad layer 1");
		sourceX = static_cast<float>(viewport.x * imageWidth / quad->getTextureWidth());
		sourceY = static_cast<float>(viewport.y * imageHeight / quad->getTextureHeight());
		sourceWidth = static_cast<float>(viewport.w * imageWidth / quad->getTextureWidth());
		sourceHeight = static_cast<float>(viewport.h * imageHeight / quad->getTextureHeight());
	}
	if (image && image->textureType == GraphicsBackend::TextureType::Array)
	{
		std::string error;
		if (!_runtime->_graphicsBackend->drawImageLayer(image->handle, imageLayer,
			sourceX, sourceY, sourceWidth, sourceHeight, a, b, c, d, tx, ty, 0.0f, 0.0f,
			_runtime->_graphicsColor[0], _runtime->_graphicsColor[1],
			_runtime->_graphicsColor[2], _runtime->_graphicsColor[3],
			image->filter, image->wrapU, image->wrapV, error))
			throw ::love::Exception("%s", error.c_str());
	}
	else if (image)
		_runtime->_graphicsBackend->drawImage(image->handle,
			sourceX, sourceY, sourceWidth, sourceHeight, a, b, c, d, tx, ty, 0.0f, 0.0f,
			_runtime->_graphicsColor[0], _runtime->_graphicsColor[1],
			_runtime->_graphicsColor[2], _runtime->_graphicsColor[3],
			image->filter, image->wrapU, image->wrapV);
	else
		_runtime->_graphicsBackend->drawCanvas(canvas->handle,
			sourceX, sourceY, sourceWidth, sourceHeight, a, b, c, d, tx, ty, 0.0f, 0.0f,
			_runtime->_graphicsColor[0], _runtime->_graphicsColor[1],
			_runtime->_graphicsColor[2], _runtime->_graphicsColor[3],
			canvas->filter, canvas->wrapU, canvas->wrapV);
}

void DoraLoveGraphics::drawInstanced(lua_State *state, ::love::graphics::Mesh *requestedMesh,
	int instanceCount, const ::love::Matrix4 &matrix)
{
	auto *mesh = dynamic_cast<MeshUserdata *>(requestedMesh);
	if (!mesh) throw ::love::Exception("expected a Mesh");
	const auto transform = combineDrawTransform(state, matrix,
		_runtime->_graphicsTransform, 3, "Mesh draw transform values must be finite");
	_runtime->graphicsDrawCommand(state, mesh, &transform, instanceCount, true);
}

void DoraLoveGraphics::drawLayer(lua_State *state,
	::love::graphics::Texture *texture, int layer, ::love::graphics::Quad *quad,
	const ::love::Matrix4 &matrix)
{
	if (!_runtime || !_runtime->_graphicsBackend)
		throw ::love::Exception("love.graphics is not attached to a Dora graphics backend");
	auto *image = dynamic_cast<ImageUserdata *>(texture);
	auto *canvas = dynamic_cast<CanvasUserdata *>(texture);
	luaL_argcheck(state, image || canvas, 1,
		"drawLayer requires an ArrayImage or array Canvas");
	if (image)
		luaL_argcheck(state, image->runtime == _runtime && image->handle != 0
			&& image->textureType == GraphicsBackend::TextureType::Array, 1,
			"drawLayer requires an open ArrayImage from this LoveRuntime");
	else
		luaL_argcheck(state, canvas->runtime == _runtime && canvas->handle != 0
			&& _runtime->_canvasHandles.contains(canvas->handle)
			&& canvas->textureType == GraphicsBackend::TextureType::Array, 1,
			"drawLayer requires an open array Canvas from this LoveRuntime");
	const int sliceCount = image ? image->slices : canvas->slices;
	luaL_argcheck(state, layer >= 0 && layer < sliceCount, 2,
		"array texture layer is outside the available range");
	std::string shaderError;
	if (!_runtime->_graphicsBackend->validateShaderDraw(
		shaderError, GraphicsBackend::TextureType::Array))
		throw ::love::Exception("%s", shaderError.c_str());
	TransformMatrix local;
	std::copy_n(matrix.getElements(), 16, local.elements);
	for (const float value : local.elements)
		luaL_argcheck(state, std::isfinite(value), 3,
			"drawLayer transform values must be finite");
	luaL_argcheck(state, isAffine2DTransform(local), 3,
		"embedded Dora graphics currently requires an affine 2D Transform");
	const auto &current = _runtime->_graphicsTransform;
	const float a = current.a * local.elements[0] + current.c * local.elements[1];
	const float b = current.b * local.elements[0] + current.d * local.elements[1];
	const float c = current.a * local.elements[4] + current.c * local.elements[5];
	const float d = current.b * local.elements[4] + current.d * local.elements[5];
	const float tx = current.a * local.elements[12]
		+ current.c * local.elements[13] + current.tx;
	const float ty = current.b * local.elements[12]
		+ current.d * local.elements[13] + current.ty;
	const float imageWidth = static_cast<float>(image
		? _runtime->_graphicsBackend->getImageWidth(image->handle)
		: _runtime->_graphicsBackend->getCanvasWidth(canvas->handle));
	const float imageHeight = static_cast<float>(image
		? _runtime->_graphicsBackend->getImageHeight(image->handle)
		: _runtime->_graphicsBackend->getCanvasHeight(canvas->handle));
	float sourceX = 0.0f;
	float sourceY = 0.0f;
	float sourceWidth = imageWidth;
	float sourceHeight = imageHeight;
	if (quad)
	{
		const auto viewport = quad->getViewport();
		sourceX = static_cast<float>(viewport.x * imageWidth / quad->getTextureWidth());
		sourceY = static_cast<float>(viewport.y * imageHeight / quad->getTextureHeight());
		sourceWidth = static_cast<float>(viewport.w * imageWidth / quad->getTextureWidth());
		sourceHeight = static_cast<float>(viewport.h * imageHeight / quad->getTextureHeight());
	}
	std::string error;
	const bool drawn = image ? _runtime->_graphicsBackend->drawImageLayer(image->handle,
		layer, sourceX, sourceY, sourceWidth, sourceHeight,
		a, b, c, d, tx, ty, 0.0f, 0.0f,
		_runtime->_graphicsColor[0], _runtime->_graphicsColor[1],
		_runtime->_graphicsColor[2], _runtime->_graphicsColor[3],
		image->filter, image->wrapU, image->wrapV, error)
		: _runtime->_graphicsBackend->drawCanvasLayer(canvas->handle,
			layer, sourceX, sourceY, sourceWidth, sourceHeight,
			a, b, c, d, tx, ty, 0.0f, 0.0f,
			_runtime->_graphicsColor[0], _runtime->_graphicsColor[1],
			_runtime->_graphicsColor[2], _runtime->_graphicsColor[3],
			canvas->filter, canvas->wrapU, canvas->wrapV, error);
	if (!drawn)
		throw ::love::Exception("%s", error.c_str());
}

void DoraLoveGraphics::renderTo(lua_State *state,
	::love::graphics::Canvas *canvas, int slice, int functionIndex)
{
	auto *doraCanvas = dynamic_cast<CanvasUserdata *>(canvas);
	if (!_runtime || !doraCanvas || doraCanvas->runtime != _runtime)
		throw ::love::Exception("Canvas belongs to another LoveRuntime");
	if (doraCanvas->getTextureType() != ::love::graphics::TEXTURE_2D
		|| slice != 0 || functionIndex != 2)
		throw ::love::Exception(
			"layered Canvas renderTo is not available until layered Canvas support is enabled");
	LoveRuntime::canvasRenderTo(state);
}

void DoraLoveGraphics::stopStencilWrite()
{
	endStencilWrite();
}

void DoraLoveGraphics::setCanvas(lua_State *state,
	const GraphicsCanvasCommand::RenderTargets &renderTargets)
{
	if (!_runtime || !_runtime->_graphicsBackend)
		throw ::love::Exception(
			"love.graphics is not attached to a Dora graphics backend");

	std::vector<GraphicsBackend::CanvasHandle> handles;
	std::vector<GraphicsBackend::CanvasTarget> targets;
	std::vector<::love::StrongRef<::love::Object>> canvasObjects;
	auto convertTarget = [&](const GraphicsCanvasCommand::RenderTarget &target)
	{
		auto *canvas = dynamic_cast<CanvasUserdata *>(target.canvas);
		if (!canvas || canvas->runtime != _runtime || canvas->handle == 0
			|| !_runtime->_canvasHandles.contains(canvas->handle))
			throw ::love::Exception("Canvas belongs to another or closed LoveRuntime");
		if (target.mipmap < 0 || target.mipmap >= canvas->mipmapCount)
			throw ::love::Exception("Canvas target mipmap is outside the available range");
		int slices = canvas->textureType == GraphicsBackend::TextureType::Volume
			? std::max(1, canvas->slices >> target.mipmap) : canvas->slices;
		const int slice = canvas->textureType == GraphicsBackend::TextureType::Texture2D
			? 0 : target.slice;
		if (slice < 0 || slice >= slices)
			throw ::love::Exception(
				"Canvas target layer, face, or volume slice is outside the available range");
		return std::pair{GraphicsBackend::CanvasTarget{
			canvas->handle, slice, target.mipmap}, canvas};
	};

	for (const auto &target : renderTargets.colors)
	{
		auto [converted, canvas] = convertTarget(target);
		handles.push_back(converted.canvas);
		targets.push_back(converted);
		canvasObjects.emplace_back(canvas);
	}

	GraphicsBackend::CanvasHandle depthStencil = 0;
	GraphicsBackend::CanvasTarget depthStencilTarget;
	::love::StrongRef<::love::Object> depthStencilObject;
	bool depth = (renderTargets.temporaryRTFlags
		& GraphicsCanvasCommand::TEMPORARY_RT_DEPTH) != 0;
	bool stencil = (renderTargets.temporaryRTFlags
		& GraphicsCanvasCommand::TEMPORARY_RT_STENCIL) != 0;
	if (renderTargets.depthStencil.canvas != nullptr)
	{
		auto [converted, canvas] = convertTarget(renderTargets.depthStencil);
		if (!isDepthStencilCanvasFormat(canvas->format))
			throw ::love::Exception(
				"depthstencil field requires a depth/stencil format Canvas");
		depthStencil = converted.canvas;
		depthStencilTarget = converted;
		depthStencilObject.set(canvas);
		depth = canvasFormatHasDepth(canvas->format);
		stencil = canvasFormatHasStencil(canvas->format);
	}
	if ((depth || stencil) && handles.empty() && depthStencil == 0)
		throw ::love::Exception(
			"temporary Canvas depth/stencil requires at least one color Canvas");

	if (!handles.empty() || depthStencil != 0)
	{
		const auto first = targets.empty() ? depthStencilTarget : targets.front();
		const int width = std::max(1,
			_runtime->_graphicsBackend->getCanvasWidth(first.canvas) >> first.mipmap);
		const int height = std::max(1,
			_runtime->_graphicsBackend->getCanvasHeight(first.canvas) >> first.mipmap);
		std::unordered_set<GraphicsBackend::CanvasHandle> uniqueHandles;
		for (const auto &target : targets)
		{
			if (!uniqueHandles.insert(target.canvas).second)
				throw ::love::Exception(
					"the same Love Canvas cannot be bound to multiple color attachments");
			if (std::max(1, _runtime->_graphicsBackend->getCanvasWidth(target.canvas)
					>> target.mipmap) != width
				|| std::max(1, _runtime->_graphicsBackend->getCanvasHeight(target.canvas)
					>> target.mipmap) != height)
				throw ::love::Exception(
					"simultaneous Love Canvas targets must have identical dimensions");
		}
		if (depthStencil != 0)
		{
			if (uniqueHandles.contains(depthStencil))
				throw ::love::Exception(
					"a depthstencil Canvas cannot also be a color attachment");
			if (std::max(1, _runtime->_graphicsBackend->getCanvasWidth(depthStencil)
					>> depthStencilTarget.mipmap) != width
				|| std::max(1, _runtime->_graphicsBackend->getCanvasHeight(depthStencil)
					>> depthStencilTarget.mipmap) != height)
				throw ::love::Exception(
					"depthstencil and color Canvases must have identical dimensions");
		}
	}

	std::string error;
	if (!_runtime->_graphicsBackend->setCanvasTargets(targets,
		depthStencil != 0 ? &depthStencilTarget : nullptr, depth, stencil, error))
		throw ::love::Exception("%s", error.empty()
			? "failed to switch Dora Canvas target" : error.c_str());

	for (const int reference : _runtime->_graphicsCanvasReferences)
		luaL_unref(state, LUA_REGISTRYINDEX, reference);
	_runtime->_graphicsCanvasReferences.clear();
	_runtime->_graphicsCanvasObjects.clear();
	if (_runtime->_graphicsCanvasDepthStencilReference != LUA_NOREF)
		luaL_unref(state, LUA_REGISTRYINDEX,
			_runtime->_graphicsCanvasDepthStencilReference);
	_runtime->_graphicsCanvasDepthStencilReference = LUA_NOREF;
	_runtime->_graphicsCanvases = handles;
	_runtime->_graphicsCanvasTargets = targets;
	_runtime->_graphicsCanvasObjects = std::move(canvasObjects);
	_runtime->_graphicsCanvasDepthStencil = depthStencil;
	_runtime->_graphicsCanvasDepthStencilTarget = depthStencilTarget;
	_runtime->_graphicsCanvasDepthStencilObject = std::move(depthStencilObject);
	_runtime->_graphicsCanvasDepth = depth;
	_runtime->_graphicsCanvasStencil = stencil;
	for (const auto &object : _runtime->_graphicsCanvasObjects)
	{
		::love::luax_pushtype(state, CanvasUserdata::type,
			static_cast<CanvasUserdata *>(object.get()));
		_runtime->_graphicsCanvasReferences.push_back(
			luaL_ref(state, LUA_REGISTRYINDEX));
	}
	if (_runtime->_graphicsCanvasDepthStencilObject)
	{
		::love::luax_pushtype(state, CanvasUserdata::type,
			static_cast<CanvasUserdata *>(
				_runtime->_graphicsCanvasDepthStencilObject.get()));
		_runtime->_graphicsCanvasDepthStencilReference =
			luaL_ref(state, LUA_REGISTRYINDEX);
	}
}

::love::graphics::GraphicsCanvasCommand::RenderTargets
DoraLoveGraphics::getCanvas() const
{
	GraphicsCanvasCommand::RenderTargets targets;
	if (!_runtime)
		return targets;
	for (std::size_t index = 0; index < _runtime->_graphicsCanvasObjects.size(); ++index)
	{
		auto *canvas = static_cast<CanvasUserdata *>(
			_runtime->_graphicsCanvasObjects[index].get());
		const auto &target = _runtime->_graphicsCanvasTargets[index];
		targets.colors.emplace_back(canvas, target.slice);
		targets.colors.back().mipmap = target.mipmap;
	}
	if (_runtime->_graphicsCanvasDepthStencilObject)
	{
		auto *canvas = static_cast<CanvasUserdata *>(
			_runtime->_graphicsCanvasDepthStencilObject.get());
		targets.depthStencil = GraphicsCanvasCommand::RenderTarget(
			canvas, _runtime->_graphicsCanvasDepthStencilTarget.slice);
		targets.depthStencil.mipmap =
			_runtime->_graphicsCanvasDepthStencilTarget.mipmap;
	}
	return targets;
}

void DoraLoveGraphics::clear(::love::Optional<::love::Colorf> color,
	::love::OptionalInt stencil, ::love::OptionalDouble depth)
{
	GraphicsBackend::ClearRequest request;
	request.colors.clear();
	GraphicsBackend::ClearColor clearColor;
	clearColor.enabled = color.hasValue;
	clearColor.red = color.value.r;
	clearColor.green = color.value.g;
	clearColor.blue = color.value.b;
	clearColor.alpha = color.value.a;
	request.colors.push_back(clearColor);
	request.clearStencil = stencil.hasValue;
	request.stencil = stencil.value;
	request.clearDepth = depth.hasValue;
	request.depth = (float) depth.value;
	if (_runtime && _runtime->_graphicsBackend)
	{
		std::string error;
		if (!_runtime->_graphicsBackend->clear(request, error))
			throw ::love::Exception("%s", error.empty()
				? "Dora graphics backend rejected love.graphics.clear" : error.c_str());
	}
}

void DoraLoveGraphics::clear(
	const std::vector<::love::Optional<::love::Colorf>> &colors,
	::love::OptionalInt stencil, ::love::OptionalDouble depth)
{
	GraphicsBackend::ClearRequest request;
	request.colors.clear();
	request.colorsPerAttachment = true;
	for (const auto &color : colors)
	{
		GraphicsBackend::ClearColor clearColor;
		clearColor.enabled = color.hasValue;
		clearColor.red = color.value.r;
		clearColor.green = color.value.g;
		clearColor.blue = color.value.b;
		clearColor.alpha = color.value.a;
		request.colors.push_back(clearColor);
	}
	request.clearStencil = stencil.hasValue;
	request.stencil = stencil.value;
	request.clearDepth = depth.hasValue;
	request.depth = (float) depth.value;
	if (_runtime && _runtime->_graphicsBackend)
	{
		std::string error;
		if (!_runtime->_graphicsBackend->clear(request, error))
			throw ::love::Exception("%s", error.empty()
				? "Dora graphics backend rejected love.graphics.clear" : error.c_str());
	}
}

void DoraLoveGraphics::discard(const std::vector<bool> &colorBuffers,
	bool depthStencil)
{
	// Love defines discard as an optional framebuffer invalidation hint. Dora's
	// embedded render graph keeps no additional transient attachment contents,
	// so retaining them is a valid implementation of the undefined result.
	(void) colorBuffers;
	(void) depthStencil;
}

size_t DoraLoveGraphics::getStackDepth() const
{
	return _runtime ? _runtime->_graphicsStateStack.size() : 0;
}

void DoraLoveGraphics::push(lua_State *state, StackType type)
{
	if (!_runtime)
		throw ::love::Exception("love.graphics has no owning LoveRuntime");
	_runtime->pushGraphicsState(state, type == STACK_ALL);
}

void DoraLoveGraphics::pop(lua_State *state)
{
	if (!_runtime)
		throw ::love::Exception("love.graphics has no owning LoveRuntime");
	_runtime->popGraphicsState(state);
}

void DoraLoveGraphics::rotate(float angle)
{
	const float cosine = std::cos(angle);
	const float sine = std::sin(angle);
	_runtime->multiplyGraphicsTransform(cosine, sine, -sine, cosine, 0.0f, 0.0f);
}

void DoraLoveGraphics::scale(float x, float y)
{
	_runtime->multiplyGraphicsTransform(x, 0.0f, 0.0f, y, 0.0f, 0.0f);
	_runtime->_graphicsTransform.pixelScale *= (std::abs(x) + std::abs(y)) * 0.5f;
}

void DoraLoveGraphics::translate(float x, float y)
{
	_runtime->multiplyGraphicsTransform(1.0f, 0.0f, 0.0f, 1.0f, x, y);
}

void DoraLoveGraphics::shear(float x, float y)
{
	_runtime->multiplyGraphicsTransform(1.0f, y, x, 1.0f, 0.0f, 0.0f);
}

void DoraLoveGraphics::origin()
{
	_runtime->resetGraphicsTransform();
}

void DoraLoveGraphics::applyTransform(::love::math::Transform *transform)
{
	if (!_runtime || transform == nullptr)
		throw ::love::Exception("invalid graphics Transform");
	const auto &matrix = transform->getMatrix();
	if (!matrix.isAffine2DTransform())
		throw ::love::Exception(
			"embedded Dora graphics currently requires an affine 2D Transform");
	const float *elements = matrix.getElements();
	_runtime->multiplyGraphicsTransform(elements[0], elements[1], elements[4],
		elements[5], elements[12], elements[13]);
	_runtime->_graphicsTransform.pixelScale = (std::hypot(_runtime->_graphicsTransform.a,
		_runtime->_graphicsTransform.b) + std::hypot(_runtime->_graphicsTransform.c,
		_runtime->_graphicsTransform.d)) * 0.5f;
}

void DoraLoveGraphics::replaceTransform(::love::math::Transform *transform)
{
	if (!_runtime || transform == nullptr)
		throw ::love::Exception("invalid graphics Transform");
	const auto &matrix = transform->getMatrix();
	if (!matrix.isAffine2DTransform())
		throw ::love::Exception(
			"embedded Dora graphics currently requires an affine 2D Transform");
	const float *elements = matrix.getElements();
	_runtime->_graphicsTransform = {elements[0], elements[1], elements[4],
		elements[5], elements[12], elements[13]};
	_runtime->_graphicsTransform.pixelScale = (std::hypot(_runtime->_graphicsTransform.a,
		_runtime->_graphicsTransform.b) + std::hypot(_runtime->_graphicsTransform.c,
		_runtime->_graphicsTransform.d)) * 0.5f;
}

::love::Vector2 DoraLoveGraphics::transformPoint(::love::Vector2 point) const
{
	const auto &transform = _runtime->_graphicsTransform;
	return {transform.a * point.x + transform.c * point.y + transform.tx,
		transform.b * point.x + transform.d * point.y + transform.ty};
}

::love::Vector2 DoraLoveGraphics::inverseTransformPoint(::love::Vector2 point) const
{
	const auto &transform = _runtime->_graphicsTransform;
	point.x -= transform.tx;
	point.y -= transform.ty;
	const float determinant = transform.a * transform.d - transform.b * transform.c;
	if (determinant == 0.0f)
		throw ::love::Exception("Cannot invert the current singular graphics Transform.");
	return {(transform.d * point.x - transform.c * point.y) / determinant,
		(-transform.b * point.x + transform.a * point.y) / determinant};
}

void DoraLoveGraphics::setColor(::love::Colorf color)
{
	_runtime->_graphicsColor[0] = color.r;
	_runtime->_graphicsColor[1] = color.g;
	_runtime->_graphicsColor[2] = color.b;
	_runtime->_graphicsColor[3] = color.a;
}

::love::Colorf DoraLoveGraphics::getColor() const
{
	return {_runtime->_graphicsColor[0], _runtime->_graphicsColor[1],
		_runtime->_graphicsColor[2], _runtime->_graphicsColor[3]};
}

void DoraLoveGraphics::setBackgroundColor(::love::Colorf color)
{
	_runtime->_graphicsBackgroundColor[0] = color.r;
	_runtime->_graphicsBackgroundColor[1] = color.g;
	_runtime->_graphicsBackgroundColor[2] = color.b;
	_runtime->_graphicsBackgroundColor[3] = color.a;
}

::love::Colorf DoraLoveGraphics::getBackgroundColor() const
{
	return {_runtime->_graphicsBackgroundColor[0], _runtime->_graphicsBackgroundColor[1],
		_runtime->_graphicsBackgroundColor[2], _runtime->_graphicsBackgroundColor[3]};
}

void DoraLoveGraphics::setLineWidth(float width)
{
	_runtime->_graphicsLineWidth = std::max(0.0f, width);
}

float DoraLoveGraphics::getLineWidth() const
{
	return _runtime->_graphicsLineWidth;
}

void DoraLoveGraphics::setLineStyle(LineStyle style)
{
	_runtime->_graphicsLineStyle = style == LINE_ROUGH
		? GraphicsBackend::LineStyle::Rough : GraphicsBackend::LineStyle::Smooth;
}

DoraLoveGraphics::LineStyle DoraLoveGraphics::getLineStyle() const
{
	return _runtime->_graphicsLineStyle == GraphicsBackend::LineStyle::Rough
		? LINE_ROUGH : LINE_SMOOTH;
}

void DoraLoveGraphics::setLineJoin(LineJoin join)
{
	switch (join)
	{
	case LINE_JOIN_NONE: _runtime->_graphicsLineJoin = GraphicsBackend::LineJoin::None; break;
	case LINE_JOIN_MITER: _runtime->_graphicsLineJoin = GraphicsBackend::LineJoin::Miter; break;
	case LINE_JOIN_BEVEL: _runtime->_graphicsLineJoin = GraphicsBackend::LineJoin::Bevel; break;
	}
}

DoraLoveGraphics::LineJoin DoraLoveGraphics::getLineJoin() const
{
	switch (_runtime->_graphicsLineJoin)
	{
	case GraphicsBackend::LineJoin::None: return LINE_JOIN_NONE;
	case GraphicsBackend::LineJoin::Miter: return LINE_JOIN_MITER;
	case GraphicsBackend::LineJoin::Bevel: return LINE_JOIN_BEVEL;
	}
	return LINE_JOIN_MITER;
}

void DoraLoveGraphics::setPointSize(float size)
{
	_runtime->_graphicsPointSize = size;
}

float DoraLoveGraphics::getPointSize() const
{
	return _runtime->_graphicsPointSize;
}

void DoraLoveGraphics::setColorMask(ColorMask mask)
{
	_runtime->_graphicsColorMask[0] = mask.r;
	_runtime->_graphicsColorMask[1] = mask.g;
	_runtime->_graphicsColorMask[2] = mask.b;
	_runtime->_graphicsColorMask[3] = mask.a;
	if (_runtime->_graphicsBackend)
		_runtime->_graphicsBackend->setColorMask(mask.r, mask.g, mask.b, mask.a);
}

DoraLoveGraphics::ColorMask DoraLoveGraphics::getColorMask() const
{
	return {_runtime->_graphicsColorMask[0], _runtime->_graphicsColorMask[1],
		_runtime->_graphicsColorMask[2], _runtime->_graphicsColorMask[3]};
}

void DoraLoveGraphics::setWireframe(bool enabled)
{
	_runtime->_graphicsWireframe = enabled;
	if (_runtime->_graphicsBackend)
		_runtime->_graphicsBackend->setWireframe(enabled);
}

bool DoraLoveGraphics::isWireframe() const
{
	return _runtime->_graphicsWireframe;
}

void DoraLoveGraphics::setScissor()
{
	_runtime->_graphicsScissorEnabled = false;
	std::fill(std::begin(_runtime->_graphicsScissor), std::end(_runtime->_graphicsScissor), 0.0f);
	if (_runtime->_graphicsBackend)
		_runtime->_graphicsBackend->setScissor(false, 0.0f, 0.0f, 0.0f, 0.0f);
}

void DoraLoveGraphics::setScissor(::love::Rect rect)
{
	_runtime->_graphicsScissorEnabled = true;
	_runtime->_graphicsScissor[0] = (float) rect.x;
	_runtime->_graphicsScissor[1] = (float) rect.y;
	_runtime->_graphicsScissor[2] = (float) rect.w;
	_runtime->_graphicsScissor[3] = (float) rect.h;
	if (_runtime->_graphicsBackend)
		_runtime->_graphicsBackend->setScissor(true, (float) rect.x, (float) rect.y,
			(float) rect.w, (float) rect.h);
}

void DoraLoveGraphics::intersectScissor(::love::Rect rect)
{
	float left = (float) rect.x;
	float top = (float) rect.y;
	float right = (float) (rect.x + rect.w);
	float bottom = (float) (rect.y + rect.h);
	if (_runtime->_graphicsScissorEnabled)
	{
		left = std::max(left, _runtime->_graphicsScissor[0]);
		top = std::max(top, _runtime->_graphicsScissor[1]);
		right = std::min(right, _runtime->_graphicsScissor[0] + _runtime->_graphicsScissor[2]);
		bottom = std::min(bottom, _runtime->_graphicsScissor[1] + _runtime->_graphicsScissor[3]);
	}
	setScissor({(int) left, (int) top, (int) std::max(0.0f, right - left),
		(int) std::max(0.0f, bottom - top)});
}

bool DoraLoveGraphics::getScissor(::love::Rect &rect) const
{
	if (!_runtime->_graphicsScissorEnabled)
		return false;
	rect = {(int) _runtime->_graphicsScissor[0], (int) _runtime->_graphicsScissor[1],
		(int) _runtime->_graphicsScissor[2], (int) _runtime->_graphicsScissor[3]};
	return true;
}

bool DoraLoveGraphics::setDefaultFilter(Filter filter, std::string &error)
{
	if (filter.min != filter.mag)
	{
		error = "embedded Dora textures require matching minification and magnification filters";
		return false;
	}
	if (!std::isfinite(filter.anisotropy) || filter.anisotropy < 0.0f)
	{
		error = "anisotropy must be a finite non-negative number";
		return false;
	}
	const float anisotropy = std::max(1.0f, filter.anisotropy);
	_runtime->_graphicsDefaultFilter = filter.min == FILTER_NEAREST
		? GraphicsBackend::TextureFilter::Nearest
		: anisotropy > 1.0f ? GraphicsBackend::TextureFilter::Anisotropic
		: GraphicsBackend::TextureFilter::Linear;
	_runtime->_graphicsDefaultAnisotropy = anisotropy;
	error.clear();
	return true;
}

DoraLoveGraphics::Filter DoraLoveGraphics::getDefaultFilter() const
{
	const auto mode = _runtime->_graphicsDefaultFilter == GraphicsBackend::TextureFilter::Nearest
		? FILTER_NEAREST : FILTER_LINEAR;
	return {mode, mode, _runtime->_graphicsDefaultAnisotropy};
}

bool DoraLoveGraphics::setDefaultMipmapFilter(FilterMode filter, float sharpness,
	std::string &error)
{
	if (!std::isfinite(sharpness))
	{
		error = "mipmap sharpness must be finite";
		return false;
	}
	if (filter == FILTER_NONE)
		_runtime->_graphicsDefaultMipmapFilter.reset();
	else
		_runtime->_graphicsDefaultMipmapFilter = filter == FILTER_NEAREST
			? GraphicsBackend::TextureFilter::Nearest : GraphicsBackend::TextureFilter::Linear;
	_runtime->_graphicsDefaultMipmapSharpness = sharpness;
	error.clear();
	return true;
}

void DoraLoveGraphics::getDefaultMipmapFilter(FilterMode &filter, float &sharpness) const
{
	if (!_runtime->_graphicsDefaultMipmapFilter)
		filter = FILTER_NONE;
	else
		filter = *_runtime->_graphicsDefaultMipmapFilter == GraphicsBackend::TextureFilter::Nearest
			? FILTER_NEAREST : FILTER_LINEAR;
	sharpness = _runtime->_graphicsDefaultMipmapSharpness;
}

bool DoraLoveGraphics::setBlendMode(BlendMode mode, BlendAlpha alphaMode,
	std::string &error)
{
	static constexpr std::string_view names[] = {"alpha", "add", "subtract", "multiply",
		"lighten", "darken", "screen", "replace", "none"};
	const std::string_view modeName = names[(int) mode];
	const std::string_view alphaName = alphaMode == BLENDALPHA_PREMULTIPLIED
		? "premultiplied" : "alphamultiply";
	if ((mode == BLEND_MULTIPLY || mode == BLEND_LIGHTEN || mode == BLEND_DARKEN)
		&& alphaMode != BLENDALPHA_PREMULTIPLIED)
	{
		error = "the '" + std::string(modeName)
			+ "' blend mode must be used with premultiplied alpha";
		return false;
	}
	if ((mode == BLEND_LIGHTEN || mode == BLEND_DARKEN) && _runtime->_graphicsBackend
		&& !_runtime->_graphicsBackend->getCapabilities().lighten)
	{
		error = "the 'lighten' and 'darken' blend modes are not supported on this system";
		return false;
	}
	if (_runtime->_graphicsBackend
		&& !_runtime->_graphicsBackend->setBlendMode(modeName, alphaName, error))
		return false;
	_runtime->_graphicsBlendMode.assign(modeName);
	_runtime->_graphicsBlendAlphaMode.assign(alphaName);
	error.clear();
	return true;
}

DoraLoveGraphics::BlendMode DoraLoveGraphics::getBlendMode(BlendAlpha &alphaMode) const
{
	alphaMode = _runtime->_graphicsBlendAlphaMode == "premultiplied"
		? BLENDALPHA_PREMULTIPLIED : BLENDALPHA_MULTIPLY;
	static constexpr std::string_view names[] = {"alpha", "add", "subtract", "multiply",
		"lighten", "darken", "screen", "replace", "none"};
	for (int index = 0; index < 9; ++index)
		if (_runtime->_graphicsBlendMode == names[index])
			return (BlendMode) index;
	return BLEND_ALPHA;
}

void DoraLoveGraphics::setDepthMode(CompareMode compare, bool write)
{
	static constexpr std::string_view names[] = {"less", "lequal", "equal", "gequal",
		"greater", "notequal", "always", "never"};
	_runtime->_graphicsDepthCompare.assign(names[(int) compare]);
	_runtime->_graphicsDepthWrite = write;
	if (_runtime->_graphicsBackend)
		_runtime->_graphicsBackend->setDepthMode(_runtime->_graphicsDepthCompare, write);
}

DoraLoveGraphics::CompareMode DoraLoveGraphics::getDepthMode(bool &write) const
{
	write = _runtime->_graphicsDepthWrite;
	static constexpr std::string_view names[] = {"less", "lequal", "equal", "gequal",
		"greater", "notequal", "always", "never"};
	for (int index = 0; index < 8; ++index)
		if (_runtime->_graphicsDepthCompare == names[index])
			return (CompareMode) index;
	return COMPARE_ALWAYS;
}

void DoraLoveGraphics::setMeshCullMode(CullMode mode)
{
	static constexpr std::string_view names[] = {"none", "back", "front"};
	_runtime->_graphicsMeshCullMode.assign(names[(int) mode]);
	if (_runtime->_graphicsBackend)
		_runtime->_graphicsBackend->setMeshCullMode(
			_runtime->_graphicsMeshCullMode, _runtime->_graphicsFrontFaceWinding);
}

DoraLoveGraphics::CullMode DoraLoveGraphics::getMeshCullMode() const
{
	if (_runtime->_graphicsMeshCullMode == "back") return CULL_BACK;
	if (_runtime->_graphicsMeshCullMode == "front") return CULL_FRONT;
	return CULL_NONE;
}

void DoraLoveGraphics::setFrontFaceWinding(Winding winding)
{
	_runtime->_graphicsFrontFaceWinding = winding == WINDING_CW ? "cw" : "ccw";
	if (_runtime->_graphicsBackend)
		_runtime->_graphicsBackend->setMeshCullMode(
			_runtime->_graphicsMeshCullMode, _runtime->_graphicsFrontFaceWinding);
}

DoraLoveGraphics::Winding DoraLoveGraphics::getFrontFaceWinding() const
{
	return _runtime->_graphicsFrontFaceWinding == "cw" ? WINDING_CW : WINDING_CCW;
}

void DoraLoveGraphics::setStencilTest(CompareMode compare, int value)
{
	static constexpr std::string_view names[] = {"less", "lequal", "equal", "gequal",
		"greater", "notequal", "always", "never"};
	_runtime->_graphicsStencilCompare.assign(names[(int) compare]);
	_runtime->_graphicsStencilValue = value;
	_runtime->_graphicsStencilTestEnabled = compare != COMPARE_ALWAYS;
	_runtime->_graphicsStencilWriting = false;
	_runtime->_graphicsStencilMode = compare == COMPARE_ALWAYS ? "off"
		: compare == COMPARE_EQUAL ? "test" : "custom";
	if (_runtime->_graphicsBackend)
		_runtime->_graphicsBackend->setStencilTest(_runtime->_graphicsStencilCompare, value);
}

DoraLoveGraphics::CompareMode DoraLoveGraphics::getStencilTest(int &value) const
{
	value = _runtime->_graphicsStencilValue;
	static constexpr std::string_view names[] = {"less", "lequal", "equal", "gequal",
		"greater", "notequal", "always", "never"};
	for (int index = 0; index < 8; ++index)
		if (_runtime->_graphicsStencilCompare == names[index])
			return (CompareMode) index;
	return COMPARE_ALWAYS;
}

void DoraLoveGraphics::setStencilMode(StencilMode mode, int value)
{
	static constexpr std::string_view names[] = {"off", "draw", "test", "custom"};
	const StencilMode effectiveMode = mode == STENCIL_MODE_CUSTOM ? STENCIL_MODE_OFF : mode;
	std::string error;
	if (_runtime->_graphicsBackend
		&& !_runtime->_graphicsBackend->setStencilMode(names[(int) effectiveMode], value, error))
		throw ::love::Exception("%s", error.c_str());
	_runtime->_graphicsStencilMode.assign(names[(int) effectiveMode]);
	_runtime->_graphicsStencilValue = value;
	_runtime->_graphicsStencilWriting = effectiveMode == STENCIL_MODE_DRAW;
	_runtime->_graphicsStencilCompare = effectiveMode == STENCIL_MODE_TEST ? "equal" : "always";
	_runtime->_graphicsStencilTestEnabled = effectiveMode == STENCIL_MODE_TEST;
	const bool colorEnabled = effectiveMode != STENCIL_MODE_DRAW;
	std::fill(std::begin(_runtime->_graphicsColorMask),
		std::end(_runtime->_graphicsColorMask), colorEnabled);
	if (_runtime->_graphicsBackend)
		_runtime->_graphicsBackend->setColorMask(
			colorEnabled, colorEnabled, colorEnabled, colorEnabled);
}

DoraLoveGraphics::StencilMode DoraLoveGraphics::getStencilMode(int &value) const
{
	value = _runtime->_graphicsStencilValue;
	if (_runtime->_graphicsStencilMode == "draw") return STENCIL_MODE_DRAW;
	if (_runtime->_graphicsStencilMode == "test") return STENCIL_MODE_TEST;
	if (_runtime->_graphicsStencilMode == "custom") return STENCIL_MODE_CUSTOM;
	return STENCIL_MODE_OFF;
}

bool DoraLoveGraphics::beginStencilWrite(StencilAction action, int value,
	bool shouldClear, int clearValue, std::string &error)
{
	if (!_runtime || !_runtime->_graphicsBackend)
	{
		error = "love.graphics is not attached to a Dora graphics backend";
		return false;
	}
	if (_runtime->_graphicsStencilWriting)
	{
		error = "nested love.graphics.stencil callbacks are not supported";
		return false;
	}
	static constexpr std::string_view names[] = {
		"replace", "increment", "decrement", "incrementwrap", "decrementwrap", "invert"};
	if (shouldClear && !_runtime->_graphicsBackend->clearStencil(clearValue, error))
		return false;
	if (!_runtime->_graphicsBackend->beginStencilWrite(names[(int) action], value, error))
		return false;
	_runtime->_graphicsStencilWriting = true;
	error.clear();
	return true;
}

void DoraLoveGraphics::endStencilWrite()
{
	if (_runtime && _runtime->_graphicsStencilWriting)
	{
		if (_runtime->_graphicsBackend)
			_runtime->_graphicsBackend->endStencilWrite();
		_runtime->_graphicsStencilWriting = false;
	}
}

int LoveRuntime::graphicsDrawCommand(lua_State *state,
	::love::graphics::Drawable *drawable,
	const GraphicsBackend::Transform2D *transformOverride,
	int instanceCountOverride, bool instancedOverride)
{
	auto *runtime = this;
	if (!runtime->_graphicsBackend)
		return luaL_error(state, "love.graphics is not attached to a Dora graphics backend");
	const bool instanced = instancedOverride;
	if (instanced && !luaL_testudata(state, 1, ::love::graphics::Mesh::type.getName()))
		return luaL_argerror(state, 1, "expected a Mesh");
	if (auto *video = testVideo(state, 1))
	{
		luaL_argcheck(state, video->runtime == runtime && video->handle != 0, 1,
			"Video belongs to another or closed LoveRuntime");
		if (video->stream->swapBuffers())
		{
			const auto *frame = static_cast<const ::love::video::VideoStream::Frame *>(
				video->stream->getFrontBuffer());
			auto rgba = convertVideoFrame(*frame);
			std::string error;
			if (!runtime->_graphicsBackend->updateImage(video->handle, frame->yw, frame->yh,
				rgba, error))
				return luaL_error(state, "Love Video frame upload failed: %s", error.c_str());
		}
		std::string shaderError;
		if (!runtime->_graphicsBackend->validateShaderDraw(shaderError))
			return luaL_error(state, "%s", shaderError.c_str());
		float originX = 0.0f, originY = 0.0f;
		const auto transform = transformOverride ? *transformOverride
			: readDrawTransform(state, 2, runtime->_graphicsTransform,
				"Video draw transform values must be finite", &originX, &originY);
		const float width = static_cast<float>(video->getWidth());
		const float height = static_cast<float>(video->getHeight());
		runtime->_graphicsBackend->drawImage(video->handle, 0.0f, 0.0f, width, height,
			transform.a, transform.b, transform.c, transform.d,
			transform.tx, transform.ty, originX, originY,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3],
			video->backendFilter(), GraphicsBackend::TextureWrap::Clamp,
			GraphicsBackend::TextureWrap::Clamp);
		return 0;
	}
	auto *text = drawable ? dynamic_cast<TextUserdata *>(drawable)
		: (::love::luax_istype(state, 1, ::love::graphics::Text::type)
			? dynamic_cast<TextUserdata *>(::love::graphics::luax_checktext(state, 1)) : nullptr);
	if (text)
	{
		luaL_argcheck(state, text->runtime == runtime && runtime->_fontHandles.contains(text->font), 1,
			"Text belongs to another or closed LoveRuntime");
		std::string shaderError;
		if (!runtime->_graphicsBackend->validateShaderDraw(shaderError))
			return luaL_error(state, "%s", shaderError.c_str());
		auto *font = dynamic_cast<FontUserdata *>(text->fontObject.get());
		luaL_argcheck(state, font && font->runtime == runtime && font->handle == text->font, 1,
			"Text Font reference is missing or closed");
		const auto outer = transformOverride ? *transformOverride
			: readDrawTransform(state, 2, runtime->_graphicsTransform,
				"Text draw transform values must be finite");
		TransformMatrix outerTransform; setTransformIdentity(outerTransform);
		outerTransform.elements[0] = outer.a;
		outerTransform.elements[1] = outer.b;
		outerTransform.elements[4] = outer.c;
		outerTransform.elements[5] = outer.d;
		outerTransform.elements[12] = outer.tx;
		outerTransform.elements[13] = outer.ty;
		for (const auto &entry : text->entries)
		{
			TransformMatrix combined; multiplyTransforms(outerTransform, entry.transform, combined);
			for (const auto &run : entry.runs)
			{
				const float tx = combined.elements[12] + combined.elements[0] * run.x
					+ combined.elements[4] * run.y;
				const float ty = combined.elements[13] + combined.elements[1] * run.x
					+ combined.elements[5] * run.y;
				runtime->_graphicsBackend->drawText(text->font, run.text, -1.0f, "left",
					combined.elements[0], combined.elements[1], combined.elements[4], combined.elements[5],
					tx, ty, 0.0f, 0.0f,
					run.color[0] * runtime->_graphicsColor[0], run.color[1] * runtime->_graphicsColor[1],
					run.color[2] * runtime->_graphicsColor[2], run.color[3] * runtime->_graphicsColor[3]);
			}
		}
		return 0;
	}
	auto *particleSystem = drawable ? dynamic_cast<ParticleSystemUserdata *>(drawable)
		: (luaL_testudata(state, 1, ::love::graphics::ParticleSystem::type.getName())
			? dynamic_cast<ParticleSystemUserdata *>(
				::love::graphics::luax_checkparticlesystem(state, 1)) : nullptr);
	if (particleSystem)
	{
		luaL_argcheck(state, particleSystem->runtime == runtime, 1,
			"ParticleSystem belongs to another LoveRuntime");
		if (particleSystem->particles.empty()) return 0;
		std::string shaderError;
		if (!runtime->_graphicsBackend->validateShaderDraw(shaderError))
			return luaL_error(state, "%s", shaderError.c_str());
		const auto drawTransform = transformOverride ? *transformOverride
			: readDrawTransform(state, 2, runtime->_graphicsTransform,
				"ParticleSystem draw transform values must be finite");
		GraphicsBackend::TextureFilter filter = GraphicsBackend::TextureFilter::Linear;
		GraphicsBackend::TextureWrap wrapU = GraphicsBackend::TextureWrap::Clamp;
		GraphicsBackend::TextureWrap wrapV = GraphicsBackend::TextureWrap::Clamp;
		int textureWidth = 0, textureHeight = 0;
		if (particleSystem->image != 0)
		{
			auto *texture = static_cast<ImageUserdata *>(particleSystem->textureObject.get());
			luaL_argcheck(state, texture->runtime == runtime && texture->handle == particleSystem->image,
				1, "ParticleSystem Image texture is closed");
			filter = texture->filter; wrapU = texture->wrapU; wrapV = texture->wrapV;
			textureWidth = runtime->_graphicsBackend->getImageWidth(texture->handle);
			textureHeight = runtime->_graphicsBackend->getImageHeight(texture->handle);
		}
		else if (particleSystem->canvas != 0)
		{
			auto *texture = static_cast<CanvasUserdata *>(particleSystem->textureObject.get());
			luaL_argcheck(state, texture->runtime == runtime && texture->handle == particleSystem->canvas
				&& runtime->_canvasHandles.contains(texture->handle), 1,
				"ParticleSystem Canvas texture is closed");
			luaL_argcheck(state, texture->readable, 1,
				"cannot draw a ParticleSystem with a non-readable Canvas texture");
			luaL_argcheck(state, std::find(runtime->_graphicsCanvases.begin(),
				runtime->_graphicsCanvases.end(), texture->handle) == runtime->_graphicsCanvases.end()
				&& texture->handle != runtime->_graphicsCanvasDepthStencil, 1,
				"cannot draw a ParticleSystem Canvas to itself");
			filter = texture->filter; wrapU = texture->wrapU; wrapV = texture->wrapV;
			textureWidth = runtime->_graphicsBackend->getCanvasWidth(texture->handle);
			textureHeight = runtime->_graphicsBackend->getCanvasHeight(texture->handle);
		}
		else return luaL_error(state, "ParticleSystem texture reference is missing");
		if (particleSystem->geometryDirty)
		{
			auto &buffer = *particleSystem->renderBuffer;
			buffer.vertices.clear();
			buffer.attributes.clear();
			buffer.vertices.reserve(particleSystem->particles.size() * 4);
			for (const auto &particle : particleSystem->particles)
			{
				float sourceX = 0.0f, sourceY = 0.0f;
				float sourceWidth = static_cast<float>(textureWidth);
				float sourceHeight = static_cast<float>(textureHeight);
				float uvWidth = sourceWidth, uvHeight = sourceHeight;
				if (!particleSystem->quads.empty())
				{
					const auto &quad = particleSystem->quads[std::min(particle.quadIndex,
						particleSystem->quads.size() - 1)];
					sourceX = quad.x; sourceY = quad.y; sourceWidth = quad.width; sourceHeight = quad.height;
					uvWidth = quad.textureWidth; uvHeight = quad.textureHeight;
				}
				const float pc = std::cos(particle.angle) * particle.size;
				const float ps = std::sin(particle.angle) * particle.size;
				const float ptx = particle.x - pc * particleSystem->offsetX + ps * particleSystem->offsetY;
				const float pty = particle.y - ps * particleSystem->offsetX - pc * particleSystem->offsetY;
				const float positions[4][2] = {{0.0f, 0.0f}, {sourceWidth, 0.0f},
					{sourceWidth, sourceHeight}, {0.0f, sourceHeight}};
				const float texcoords[4][2] = {{sourceX / uvWidth, sourceY / uvHeight},
					{(sourceX + sourceWidth) / uvWidth, sourceY / uvHeight},
					{(sourceX + sourceWidth) / uvWidth, (sourceY + sourceHeight) / uvHeight},
					{sourceX / uvWidth, (sourceY + sourceHeight) / uvHeight}};
				for (int vertexIndex = 0; vertexIndex < 4; ++vertexIndex)
				{
					const float px = positions[vertexIndex][0], py = positions[vertexIndex][1];
					const float localX = pc * px - ps * py + ptx;
					const float localY = ps * px + pc * py + pty;
					GraphicsBackend::MeshVertex vertex;
					vertex.x = localX;
					vertex.y = localY;
					vertex.u = texcoords[vertexIndex][0]; vertex.v = texcoords[vertexIndex][1];
					vertex.red = particle.color.red;
					vertex.green = particle.color.green;
					vertex.blue = particle.color.blue;
					vertex.alpha = particle.color.alpha;
					buffer.vertices.push_back(vertex);
				}
			}
			if (particleSystem->preparedParticleCount != particleSystem->particles.size())
			{
				buffer.indices.clear();
				buffer.indices.reserve(particleSystem->particles.size() * 6);
				for (std::size_t index = 0; index < particleSystem->particles.size(); ++index)
				{
					const auto base = static_cast<std::uint32_t>(index * 4);
					buffer.indices.insert(buffer.indices.end(),
						{base, base + 1, base + 2, base, base + 2, base + 3});
				}
				particleSystem->preparedParticleCount = particleSystem->particles.size();
			}
			++buffer.revision;
			particleSystem->geometryDirty = false;
		}
		std::string error;
		const std::array<float, 4> color{
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3]};
		if (!runtime->_graphicsBackend->drawMeshBuffer(particleSystem->renderBuffer, "triangles",
			particleSystem->image, particleSystem->canvas, runtime->_graphicsPointSize,
			filter, wrapU, wrapV, drawTransform, color, error))
			return luaL_error(state, "%s", error.c_str());
		return 0;
	}
	auto *batch = drawable ? dynamic_cast<SpriteBatchUserdata *>(drawable)
		: (luaL_testudata(state, 1, ::love::graphics::SpriteBatch::type.getName())
			? dynamic_cast<SpriteBatchUserdata *>(
				::love::graphics::luax_checkspritebatch(state, 1)) : nullptr);
	if (batch)
	{
		luaL_argcheck(state, batch->runtime == runtime, 1,
			"SpriteBatch belongs to another LoveRuntime");
		if (batch->count == 0) return 0;
		std::string shaderError;
		if (!runtime->_graphicsBackend->validateShaderDraw(shaderError, batch->textureType))
			return luaL_error(state, "%s", shaderError.c_str());
		const auto drawTransform = transformOverride ? *transformOverride
			: readDrawTransform(state, 2, runtime->_graphicsTransform,
				"SpriteBatch draw transform values must be finite");
		const std::size_t start = batch->drawStart < 0 ? 0
			: std::min(static_cast<std::size_t>(batch->drawStart), batch->count - 1);
		const std::size_t requested = batch->drawCount > 0
			? static_cast<std::size_t>(batch->drawCount) : batch->count;
		const std::size_t count = std::min(requested, batch->count - start);
		for (const auto &[name, attachment] : batch->attachments)
		{
			luaL_argcheck(state, attachment.mesh && attachment.mesh->runtime == runtime
				&& attachment.attributeIndex < attachment.mesh->format.size(), 1,
				"SpriteBatch attached Mesh is closed");
			luaL_argcheck(state, batch->count <= std::numeric_limits<std::size_t>::max() / 4
				&& attachment.mesh->vertexCount >= batch->count * 4, 1,
				("Mesh with attribute '" + name
					+ "' attached to this SpriteBatch has too few vertices").c_str());
		}
		const auto attachmentFor = [batch](std::string_view name) -> const SpriteBatchAttachment * {
			const auto found = batch->attachments.find(std::string(name));
			return found == batch->attachments.end() ? nullptr : &found->second;
		};
		const auto attachmentValues = [](const SpriteBatchAttachment &attachment,
			std::size_t vertexIndex) -> const float * {
			const auto *mesh = attachment.mesh;
			const auto &attribute = mesh->format[attachment.attributeIndex];
			return mesh->values.data() + vertexIndex * mesh->componentCount + attribute.offset;
		};
		const auto *positionAttachment = attachmentFor("VertexPosition");
		const auto *texcoordAttachment = attachmentFor("VertexTexCoord");
		const auto *colorAttachment = attachmentFor("VertexColor");
		if (positionAttachment)
		{
			const auto &attribute = positionAttachment->mesh->format[positionAttachment->attributeIndex];
			luaL_argcheck(state, attribute.type == "float" && attribute.components >= 2, 1,
				"SpriteBatch VertexPosition attachment must be a float attribute with at least 2 components");
		}
		if (texcoordAttachment)
		{
			const auto &attribute = texcoordAttachment->mesh->format[texcoordAttachment->attributeIndex];
			luaL_argcheck(state, attribute.components >= 2, 1,
				"SpriteBatch VertexTexCoord attachment must have at least 2 components");
		}
		if (colorAttachment)
		{
			const auto &attribute = colorAttachment->mesh->format[colorAttachment->attributeIndex];
			luaL_argcheck(state, attribute.components >= 1, 1,
				"SpriteBatch VertexColor attachment must have at least 1 component");
		}
		auto &buffer = *batch->renderBuffer;
		if (batch->geometryDirty || !batch->attachments.empty())
		{
			buffer.vertices.clear();
			buffer.indices.clear();
			buffer.attributes.clear();
			buffer.vertices.reserve(count * 4);
			buffer.indices.reserve(count * 6);
			for (std::size_t spriteIndex = 0; spriteIndex < count; ++spriteIndex)
			{
				const auto &sprite = batch->sprites[start + spriteIndex];
				const std::uint32_t base = static_cast<std::uint32_t>(buffer.vertices.size());
				for (std::size_t localVertex = 0; localVertex < 4; ++localVertex)
				{
					auto vertex = sprite.vertices[localVertex];
					const std::size_t sourceVertex = (start + spriteIndex) * 4 + localVertex;
					if (positionAttachment)
					{
						const auto &attribute = positionAttachment->mesh->format[positionAttachment->attributeIndex];
						const float *values = attachmentValues(*positionAttachment, sourceVertex);
						vertex.x = values[0]; vertex.y = values[1];
						if (attribute.components >= 3) vertex.z = values[2];
						if (attribute.components >= 4) vertex.w = values[3];
					}
					if (texcoordAttachment)
					{
						const auto &attribute = texcoordAttachment->mesh->format[texcoordAttachment->attributeIndex];
						const float *values = attachmentValues(*texcoordAttachment, sourceVertex);
						vertex.u = values[0]; vertex.v = values[1];
						if (batch->textureType == GraphicsBackend::TextureType::Array)
							vertex.textureLayer = attribute.components >= 3 ? values[2] : 0.0f;
					}
					if (colorAttachment)
					{
						const auto &attribute = colorAttachment->mesh->format[colorAttachment->attributeIndex];
						const float *values = attachmentValues(*colorAttachment, sourceVertex);
						vertex.red = values[0];
						vertex.green = attribute.components >= 2 ? values[1] : 0.0f;
						vertex.blue = attribute.components >= 3 ? values[2] : 0.0f;
						vertex.alpha = attribute.components >= 4 ? values[3] : 1.0f;
					}
					buffer.vertices.push_back(vertex);
				}
				buffer.indices.insert(buffer.indices.end(),
					{base, base + 1, base + 2, base, base + 2, base + 3});
			}
			buffer.attributes.reserve(batch->attachments.size());
			for (const auto &[name, attachment] : batch->attachments)
			{
				if (name == "VertexPosition" || name == "VertexTexCoord" || name == "VertexColor")
					continue;
				const auto &attribute = attachment.mesh->format[attachment.attributeIndex];
				GraphicsBackend::MeshAttributeData data;
				data.name = name;
				data.components = attribute.components;
				data.values.reserve(count * 4 * static_cast<std::size_t>(attribute.components));
				for (std::size_t spriteIndex = 0; spriteIndex < count; ++spriteIndex)
				for (std::size_t localVertex = 0; localVertex < 4; ++localVertex)
				{
					const std::size_t sourceVertex = (start + spriteIndex) * 4 + localVertex;
					const float *values = attachmentValues(attachment, sourceVertex);
					data.values.insert(data.values.end(), values, values + attribute.components);
				}
				buffer.attributes.push_back(std::move(data));
			}
			++buffer.revision;
			batch->geometryDirty = false;
		}
		GraphicsBackend::TextureFilter filter = GraphicsBackend::TextureFilter::Linear;
		GraphicsBackend::TextureWrap wrapU = GraphicsBackend::TextureWrap::Clamp;
		GraphicsBackend::TextureWrap wrapV = GraphicsBackend::TextureWrap::Clamp;
		if (batch->image != 0)
		{
			auto *texture = static_cast<ImageUserdata *>(batch->textureObject.get());
			luaL_argcheck(state, texture->runtime == runtime && texture->handle == batch->image
				&& texture->textureType == batch->textureType, 1,
				"SpriteBatch Image texture is closed");
			filter = texture->filter; wrapU = texture->wrapU; wrapV = texture->wrapV;
		}
		else if (batch->canvas != 0)
		{
			auto *texture = static_cast<CanvasUserdata *>(batch->textureObject.get());
			luaL_argcheck(state, texture->runtime == runtime && texture->handle == batch->canvas
				&& runtime->_canvasHandles.contains(texture->handle), 1,
				"SpriteBatch Canvas texture is closed");
			luaL_argcheck(state, texture->readable, 1,
				"cannot draw a SpriteBatch with a non-readable Canvas texture");
			luaL_argcheck(state, std::find(runtime->_graphicsCanvases.begin(),
				runtime->_graphicsCanvases.end(), texture->handle) == runtime->_graphicsCanvases.end()
				&& texture->handle != runtime->_graphicsCanvasDepthStencil, 1,
				"cannot draw a SpriteBatch Canvas to itself");
			filter = texture->filter; wrapU = texture->wrapU; wrapV = texture->wrapV;
		}
		else return luaL_error(state, "SpriteBatch texture reference is missing");
		std::string error;
		const std::array<float, 4> color{
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3]};
		if (!runtime->_graphicsBackend->drawMeshBuffer(batch->renderBuffer, "triangles",
			batch->image, batch->canvas, runtime->_graphicsPointSize,
			filter, wrapU, wrapV, drawTransform, color, error))
			return luaL_error(state, "%s", error.c_str());
		return 0;
	}
	auto *mesh = drawable ? dynamic_cast<MeshUserdata *>(drawable)
		: (luaL_testudata(state, 1, ::love::graphics::Mesh::type.getName())
			? dynamic_cast<MeshUserdata *>(::love::graphics::luax_checkmesh(state, 1)) : nullptr);
	if (mesh)
	{
		luaL_argcheck(state, mesh->runtime == runtime, 1, "Mesh belongs to another LoveRuntime");
		const int instanceCount = instanced ? instanceCountOverride : 1;
		const int transformStart = instanced ? 3 : 2;
		const auto drawTransform = transformOverride ? *transformOverride
			: readDrawTransform(state, transformStart, runtime->_graphicsTransform,
				"Mesh draw transform values must be finite");
		if (instanceCount <= 0) return 0;
		std::string shaderError;
		if (!runtime->_graphicsBackend->validateShaderDraw(shaderError))
			return luaL_error(state, "%s", shaderError.c_str());
		std::size_t perInstanceAttributeCount = 0;
		if (instanced && instanceCount > 1 && runtime->_graphicsShader != 0)
		{
			for (const auto &[name, attachment] : mesh->attachments)
			{
				(void)name;
				if (attachment.enabled && attachment.step == "perinstance")
					++perInstanceAttributeCount;
			}
		}
		const bool hardwareInstancing = instanced && instanceCount > 1
			&& runtime->_graphicsShader != 0
			&& runtime->_graphicsBackend->supportsMeshInstancing(
				runtime->_graphicsShader, perInstanceAttributeCount);
		if (instanced && instanceCount > 1 && runtime->_graphicsShader != 0
			&& !hardwareInstancing
			&& runtime->_graphicsBackend->requiresMeshInstancing(runtime->_graphicsShader))
			return luaL_error(state,
				"active Shader uses love_InstanceID but hardware Mesh instancing is unavailable");
		GraphicsBackend::TextureFilter filter = GraphicsBackend::TextureFilter::Linear;
		GraphicsBackend::TextureWrap wrapU = GraphicsBackend::TextureWrap::Clamp;
		GraphicsBackend::TextureWrap wrapV = GraphicsBackend::TextureWrap::Clamp;
		if (mesh->image != 0)
		{
			auto *texture = static_cast<ImageUserdata *>(mesh->textureObject.get());
			filter = texture->filter; wrapU = texture->wrapU; wrapV = texture->wrapV;
		}
		else if (mesh->canvas != 0)
		{
			auto *texture = static_cast<CanvasUserdata *>(mesh->textureObject.get());
			luaL_argcheck(state, texture->readable, 1,
				"cannot draw a Mesh with a non-readable Canvas texture");
			luaL_argcheck(state, std::find(runtime->_graphicsCanvases.begin(),
				runtime->_graphicsCanvases.end(), texture->handle)
					== runtime->_graphicsCanvases.end()
				&& texture->handle != runtime->_graphicsCanvasDepthStencil, 1,
				"cannot draw a Canvas to itself");
			filter = texture->filter; wrapU = texture->wrapU; wrapV = texture->wrapV;
		}
		const bool cacheableGeometry = mesh->attachments.empty() && instanceCount == 1
			&& runtime->_graphicsShader == 0;
		if (cacheableGeometry && mesh->preparedRevision == mesh->geometryRevision
			&& mesh->preparedInstanceCount == instanceCount)
		{
			std::string error;
			const std::array<float, 4> drawColor{
				runtime->_graphicsColor[0], runtime->_graphicsColor[1],
				runtime->_graphicsColor[2], runtime->_graphicsColor[3]};
			if (!runtime->_graphicsBackend->drawMeshBuffer(mesh->renderBuffer,
				mesh->preparedDrawMode, mesh->image, mesh->canvas, runtime->_graphicsPointSize,
				filter, wrapU, wrapV, drawTransform, drawColor, error,
				hardwareInstancing ? instanceCount : 1))
				return luaL_error(state, "%s", error.c_str());
			return 0;
		}
		const std::size_t expandedInstances = hardwareInstancing ? 1
			: static_cast<std::size_t>(instanceCount);
		luaL_argcheck(state, expandedInstances
			<= std::numeric_limits<std::size_t>::max() / mesh->vertexCount, 2,
			"Mesh instance count is too large");
		const std::size_t expandedVertexCount = mesh->vertexCount
			* expandedInstances;
		luaL_argcheck(state, expandedVertexCount <= std::numeric_limits<std::uint32_t>::max(), 2,
			"instanced Mesh exceeds Dora/bgfx's 32-bit vertex limit");
		std::vector<GraphicsBackend::MeshVertex> vertices(expandedVertexCount);
		struct ResolvedAttribute
		{
			const MeshUserdata *mesh = nullptr;
			const MeshAttribute *attribute = nullptr;
			bool perInstance = false;
		};
		const auto resolveAttribute = [mesh](std::string_view name) -> ResolvedAttribute {
			if (const auto attached = mesh->attachments.find(std::string(name));
				attached != mesh->attachments.end())
			{
				if (!attached->second.enabled) return {};
				const auto *source = attached->second.mesh;
				return {source, &source->format[attached->second.attributeIndex],
					attached->second.step == "perinstance"};
			}
			const std::size_t index = meshAttributeIndex(*mesh, name);
			if (index == mesh->format.size() || !mesh->format[index].enabled) return {};
			return {mesh, &mesh->format[index], false};
		};
		const auto position = resolveAttribute("VertexPosition");
		const auto texcoord = resolveAttribute("VertexTexCoord");
		const auto color = resolveAttribute("VertexColor");
		luaL_argcheck(state, position.attribute && position.attribute->type == "float"
			&& position.attribute->components >= 2, 1,
			"Mesh drawing requires a float VertexPosition attribute with at least 2 components");
		const auto attributeValues = [state](const ResolvedAttribute &resolved,
			std::size_t targetIndex, std::size_t instanceIndex) -> const float * {
			if (!resolved.attribute) return nullptr;
			const std::size_t sourceIndex = resolved.perInstance ? instanceIndex : targetIndex;
			luaL_argcheck(state, sourceIndex < resolved.mesh->vertexCount, 1,
				"attached Mesh attribute does not contain enough vertices");
			return resolved.mesh->values.data() + sourceIndex * resolved.mesh->componentCount
				+ resolved.attribute->offset;
		};
		for (std::size_t instanceIndex = 0; instanceIndex < expandedInstances;
			++instanceIndex)
		for (std::size_t index = 0; index < mesh->vertexCount; ++index)
		{
			auto &vertex = vertices[instanceIndex * mesh->vertexCount + index];
			const float *positionValues = attributeValues(position, index, instanceIndex);
			const float px = positionValues[0];
			const float py = positionValues[1];
			vertex.x = px;
			vertex.y = py;
			if (position.attribute->components >= 3) vertex.z = positionValues[2];
			if (position.attribute->components >= 4) vertex.w = positionValues[3];
			if (texcoord.attribute && texcoord.attribute->components >= 2)
			{
				const float *texcoordValues = attributeValues(texcoord, index, instanceIndex);
				vertex.u = texcoordValues[0];
				vertex.v = texcoordValues[1];
			}
			if (color.attribute)
			{
				const float *colorValues = attributeValues(color, index, instanceIndex);
				if (color.attribute->components >= 1) vertex.red = colorValues[0];
				if (color.attribute->components >= 2) vertex.green = colorValues[1];
				if (color.attribute->components >= 3) vertex.blue = colorValues[2];
				if (color.attribute->components >= 4) vertex.alpha = colorValues[3];
			}
		}
		std::vector<GraphicsBackend::MeshAttributeData> customAttributes;
		std::unordered_set<std::string> customNames;
		const auto appendCustomAttribute = [&](std::string_view name) {
			if (name == "VertexPosition" || name == "VertexTexCoord" || name == "VertexColor"
				|| !customNames.emplace(name).second)
				return;
			const auto resolved = resolveAttribute(name);
			if (!resolved.attribute) return;
			GraphicsBackend::MeshAttributeData data;
			data.name = name;
			data.components = resolved.attribute->components;
			data.perInstance = hardwareInstancing && resolved.perInstance;
			const std::size_t valueRows = data.perInstance
				? static_cast<std::size_t>(instanceCount) : expandedVertexCount;
			data.values.reserve(valueRows * static_cast<std::size_t>(data.components));
			const std::size_t attributeInstances = data.perInstance
				? static_cast<std::size_t>(instanceCount) : expandedInstances;
			const std::size_t verticesPerAttributeInstance = data.perInstance ? 1 : mesh->vertexCount;
			for (std::size_t instanceIndex = 0; instanceIndex < attributeInstances; ++instanceIndex)
			for (std::size_t vertexIndex = 0;
				vertexIndex < verticesPerAttributeInstance; ++vertexIndex)
			{
				const float *values = attributeValues(resolved, vertexIndex, instanceIndex);
				data.values.insert(data.values.end(), values, values + data.components);
			}
			customAttributes.push_back(std::move(data));
		};
		for (const auto &attribute : mesh->format)
			appendCustomAttribute(attribute.name);
		for (const auto &[name, attachment] : mesh->attachments)
		{
			(void)attachment;
			appendCustomAttribute(name);
		}
		if (runtime->_graphicsShader != 0
			&& runtime->_graphicsBackend->requiresMeshVertexID(runtime->_graphicsShader))
		{
			GraphicsBackend::MeshAttributeData vertexIDs;
			vertexIDs.name = "__DoraLoveVertexID";
			vertexIDs.components = 1;
			vertexIDs.values.reserve(expandedVertexCount);
			for (std::size_t instanceIndex = 0; instanceIndex < expandedInstances; ++instanceIndex)
				for (std::size_t vertexIndex = 0; vertexIndex < mesh->vertexCount; ++vertexIndex)
					vertexIDs.values.push_back(static_cast<float>(vertexIndex));
			customAttributes.push_back(std::move(vertexIDs));
		}
		if (hardwareInstancing)
		{
			const auto appendBuiltinInstanceAttribute = [&](std::string_view name,
				const ResolvedAttribute &resolved) {
				if (!resolved.attribute || !resolved.perInstance) return;
				GraphicsBackend::MeshAttributeData data;
				data.name = name;
				data.components = resolved.attribute->components;
				data.perInstance = true;
				data.values.reserve(static_cast<std::size_t>(instanceCount)
					* static_cast<std::size_t>(data.components));
				for (std::size_t instanceIndex = 0;
					instanceIndex < static_cast<std::size_t>(instanceCount); ++instanceIndex)
				{
					const float *values = attributeValues(resolved, 0, instanceIndex);
					data.values.insert(data.values.end(), values, values + data.components);
				}
				customAttributes.push_back(std::move(data));
			};
			appendBuiltinInstanceAttribute("VertexPosition", position);
			appendBuiltinInstanceAttribute("VertexTexCoord", texcoord);
			appendBuiltinInstanceAttribute("VertexColor", color);
		}
		std::vector<std::uint32_t> indices;
		if (!mesh->useVertexMap)
		{
			indices.resize(mesh->vertexCount);
			for (std::size_t index = 0; index < mesh->vertexCount; ++index)
				indices[index] = static_cast<std::uint32_t>(index);
		}
		else indices = mesh->vertexMap;
		if (mesh->drawStart >= 0)
		{
			const std::size_t start = static_cast<std::size_t>(mesh->drawStart);
			const std::size_t count = static_cast<std::size_t>(mesh->drawCount);
			luaL_argcheck(state, start <= indices.size() && count <= indices.size() - start, 1,
				"Mesh draw range exceeds its current vertex map");
			indices = std::vector<std::uint32_t>(indices.begin() + start, indices.begin() + start + count);
		}
		std::string submittedDrawMode = mesh->drawMode;
		if (!hardwareInstancing && instanceCount > 1)
		{
			if (mesh->drawMode == "fan" || mesh->drawMode == "strip")
			{
				std::vector<std::uint32_t> triangles;
				if (indices.size() >= 3)
				{
					triangles.reserve((indices.size() - 2) * 3);
					if (mesh->drawMode == "fan")
					{
						for (std::size_t index = 1; index + 1 < indices.size(); ++index)
							triangles.insert(triangles.end(),
								{indices[0], indices[index], indices[index + 1]});
					}
					else
					{
						for (std::size_t index = 0; index + 2 < indices.size(); ++index)
							triangles.insert(triangles.end(), (index & 1) == 0
								? std::initializer_list<std::uint32_t>{indices[index], indices[index + 1], indices[index + 2]}
								: std::initializer_list<std::uint32_t>{indices[index + 1], indices[index], indices[index + 2]});
					}
				}
				indices = std::move(triangles);
				submittedDrawMode = "triangles";
			}
			const auto baseIndices = indices;
			luaL_argcheck(state, baseIndices.empty()
				|| static_cast<std::size_t>(instanceCount)
					<= std::numeric_limits<std::size_t>::max() / baseIndices.size(), 2,
				"Mesh instance count is too large");
			indices.clear();
			indices.reserve(baseIndices.size() * static_cast<std::size_t>(instanceCount));
			for (std::size_t instanceIndex = 0;
				instanceIndex < static_cast<std::size_t>(instanceCount); ++instanceIndex)
			{
				const std::uint32_t offset = static_cast<std::uint32_t>(instanceIndex * mesh->vertexCount);
				for (const auto index : baseIndices) indices.push_back(index + offset);
			}
		}
		auto &buffer = *mesh->renderBuffer;
		buffer.vertices = std::move(vertices);
		buffer.attributes = std::move(customAttributes);
		buffer.indices = std::move(indices);
		++buffer.revision;
		mesh->preparedRevision = cacheableGeometry ? mesh->geometryRevision : 0;
		mesh->preparedInstanceCount = cacheableGeometry ? instanceCount : 0;
		mesh->preparedDrawMode = submittedDrawMode;
		std::string error;
		const std::array<float, 4> drawColor{
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3]};
		if (!runtime->_graphicsBackend->drawMeshBuffer(mesh->renderBuffer, submittedDrawMode,
			mesh->image, mesh->canvas, runtime->_graphicsPointSize, filter, wrapU, wrapV,
			drawTransform, drawColor, error, hardwareInstancing ? instanceCount : 1))
			return luaL_error(state, "%s", error.c_str());
		return 0;
	}
	auto *image = testImage(state, 1);
	auto *canvas = testCanvas(state, 1);
	if (!image && !canvas)
		return luaL_argerror(state, 1, "expected an Image, Canvas, Mesh, SpriteBatch, ParticleSystem, or Text");
	if (image)
		luaL_argcheck(state, image->runtime == runtime && image->handle != 0, 1,
			"Image belongs to another or closed LoveRuntime");
	else
		luaL_argcheck(state, canvas->runtime == runtime && canvas->handle != 0
			&& runtime->_canvasHandles.contains(canvas->handle), 1,
			"Canvas belongs to another or closed LoveRuntime");
	if (canvas)
		luaL_argcheck(state, canvas->readable, 1, "cannot draw a non-readable Canvas");
	if (canvas)
		luaL_argcheck(state, canvas->textureType == GraphicsBackend::TextureType::Texture2D, 1,
			"non-2D Canvas textures must be drawn with a compatible layered API");
	if (canvas)
		luaL_argcheck(state, std::find(runtime->_graphicsCanvases.begin(), runtime->_graphicsCanvases.end(),
			canvas->handle) == runtime->_graphicsCanvases.end()
			&& canvas->handle != runtime->_graphicsCanvasDepthStencil, 1,
			"cannot draw a Canvas to itself");
	std::string shaderError;
	if (!runtime->_graphicsBackend->validateShaderDraw(shaderError,
		image ? image->textureType : GraphicsBackend::TextureType::Texture2D))
		return luaL_error(state, "%s", shaderError.c_str());
	float sourceX = 0.0f;
	float sourceY = 0.0f;
	const float imageWidth = static_cast<float>(image
		? runtime->_graphicsBackend->getImageWidth(image->handle)
		: runtime->_graphicsBackend->getCanvasWidth(canvas->handle));
	const float imageHeight = static_cast<float>(image
		? runtime->_graphicsBackend->getImageHeight(image->handle)
		: runtime->_graphicsBackend->getCanvasHeight(canvas->handle));
	float sourceWidth = imageWidth;
	float sourceHeight = imageHeight;
	int imageLayer = 0;
	int startIndex = 2;
	if (auto *quad = ::love::luax_istype(state, 2, ::love::graphics::Quad::type)
		? ::love::graphics::luax_checkquad(state, 2) : nullptr)
	{
		const auto viewport = quad->getViewport();
		const int layer = quad->getLayer();
		if (image && image->textureType == GraphicsBackend::TextureType::Array)
		{
			luaL_argcheck(state, layer >= 0 && layer < image->slices, 2,
				"Quad layer exceeds the ArrayImage layer count");
			imageLayer = layer;
		}
		else luaL_argcheck(state, layer == 0, 2,
			"non-array embedded Dora Images support only Quad layer 1");
		sourceX = static_cast<float>(viewport.x * imageWidth / quad->getTextureWidth());
		sourceY = static_cast<float>(viewport.y * imageHeight / quad->getTextureHeight());
		sourceWidth = static_cast<float>(viewport.w * imageWidth / quad->getTextureWidth());
		sourceHeight = static_cast<float>(viewport.h * imageHeight / quad->getTextureHeight());
		startIndex = 3;
	}
	float originX = 0.0f, originY = 0.0f;
	const auto transform = readDrawTransform(state, startIndex, runtime->_graphicsTransform,
		"Texture draw transform values must be finite", &originX, &originY);
	if (image && image->textureType == GraphicsBackend::TextureType::Array)
	{
		std::string error;
		if (!runtime->_graphicsBackend->drawImageLayer(image->handle, imageLayer,
			sourceX, sourceY, sourceWidth, sourceHeight,
			transform.a, transform.b, transform.c, transform.d,
			transform.tx, transform.ty, originX, originY,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3],
			image->filter, image->wrapU, image->wrapV, error))
			return luaL_error(state, "%s", error.c_str());
	}
	else if (image)
		runtime->_graphicsBackend->drawImage(image->handle,
			sourceX, sourceY, sourceWidth, sourceHeight,
			transform.a, transform.b, transform.c, transform.d,
			transform.tx, transform.ty, originX, originY,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3],
			image->filter, image->wrapU, image->wrapV);
	else
		runtime->_graphicsBackend->drawCanvas(canvas->handle,
			sourceX, sourceY, sourceWidth, sourceHeight,
			transform.a, transform.b, transform.c, transform.d,
			transform.tx, transform.ty, originX, originY,
			runtime->_graphicsColor[0], runtime->_graphicsColor[1],
			runtime->_graphicsColor[2], runtime->_graphicsColor[3],
			canvas->filter, canvas->wrapU, canvas->wrapV);
	return 0;
}

GraphicsBackend::FontHandle LoveRuntime::ensureDefaultFont(std::string &error)
{
	if (_currentFont != 0)
		return _currentFont;
	if (!_graphicsBackend)
	{
		error = "love.graphics Font is not attached to a Dora graphics backend";
		return 0;
	}
	const auto handle = _graphicsBackend->newFont({}, 12, error);
	if (handle != 0)
	{
		_currentFont = handle;
		auto *font = new FontUserdata(this, handle);
		font->filter.min = font->filter.mag = _graphicsDefaultFilter
			== GraphicsBackend::TextureFilter::Nearest
			? ::love::graphics::Texture::FILTER_NEAREST
			: ::love::graphics::Texture::FILTER_LINEAR;
		font->filter.mipmap = ::love::graphics::Texture::FILTER_NONE;
		font->filter.anisotropy = _graphicsDefaultAnisotropy;
		_graphicsFontObject.set(font, ::love::Acquire::NORETAIN);
	}
	return handle;
}

namespace
{
int writeSpriteBatchSprite(SpriteBatchUserdata &batch, ::love::graphics::Quad *quad,
	const ::love::Matrix4 &matrix, int requestedIndex, std::optional<int> explicitLayer)
{
	auto *graphics = batch.runtime ? batch.runtime->getGraphicsBackend() : nullptr;
	if (!graphics) throw ::love::Exception("closed SpriteBatch");
	float sourceX = 0.0f;
	float sourceY = 0.0f;
	float sourceWidth = static_cast<float>(batch.image != 0
		? graphics->getImageWidth(batch.image) : graphics->getCanvasWidth(batch.canvas));
	float sourceHeight = static_cast<float>(batch.image != 0
		? graphics->getImageHeight(batch.image) : graphics->getCanvasHeight(batch.canvas));
	float textureWidth = sourceWidth;
	float textureHeight = sourceHeight;
	int quadLayer = 0;
	if (quad)
	{
		const auto viewport = quad->getViewport();
		quadLayer = quad->getLayer();
		sourceX = static_cast<float>(viewport.x);
		sourceY = static_cast<float>(viewport.y);
		sourceWidth = static_cast<float>(viewport.w);
		sourceHeight = static_cast<float>(viewport.h);
		textureWidth = static_cast<float>(quad->getTextureWidth());
		textureHeight = static_cast<float>(quad->getTextureHeight());
	}
	const bool arrayTexture = batch.textureType == GraphicsBackend::TextureType::Array;
	if (explicitLayer && !arrayTexture)
		throw ::love::Exception("addLayer/setLayer can only be used with an ArrayImage SpriteBatch");
	const int layer = arrayTexture ? explicitLayer.value_or(quadLayer) : 0;
	if (layer < 0 || layer >= batch.layerCount)
		throw ::love::Exception("SpriteBatch layer is outside its ArrayImage");
	TransformMatrix local;
	std::copy_n(matrix.getElements(), 16, local.elements);
	for (const float value : local.elements)
		if (!std::isfinite(value))
			throw ::love::Exception("SpriteBatch transform values must be finite");
	if (!isAffine2DTransform(local))
		throw ::love::Exception("embedded Dora SpriteBatch requires an affine 2D Transform");
	const float quadValues[] = {
		sourceX, sourceY, sourceWidth, sourceHeight, textureWidth, textureHeight};
	for (const float value : quadValues)
		if (!std::isfinite(value))
			throw ::love::Exception("SpriteBatch Quad values must be finite");
	if (textureWidth <= 0.0f || textureHeight <= 0.0f)
		throw ::love::Exception("SpriteBatch texture dimensions must be positive");

	std::size_t index = 0;
	if (requestedIndex < 0)
	{
		if (batch.count >= batch.bufferSize)
		{
			if (batch.bufferSize > 500000)
				throw ::love::Exception(
					"SpriteBatch automatic growth exceeds the 1000000 sprite limit");
			batch.bufferSize *= 2;
			batch.sprites.resize(batch.bufferSize);
		}
		index = batch.count++;
	}
	else
	{
		if (static_cast<std::size_t>(requestedIndex) >= batch.bufferSize)
			throw ::love::Exception("SpriteBatch sprite index is outside its buffer");
		index = static_cast<std::size_t>(requestedIndex);
	}

	const float positions[4][2] = {
		{0.0f, 0.0f}, {sourceWidth, 0.0f},
		{sourceWidth, sourceHeight}, {0.0f, sourceHeight}};
	const float u0 = sourceX / textureWidth;
	const float v0 = sourceY / textureHeight;
	const float u1 = (sourceX + sourceWidth) / textureWidth;
	const float v1 = (sourceY + sourceHeight) / textureHeight;
	const float texcoords[4][2] = {{u0, v0}, {u1, v0}, {u1, v1}, {u0, v1}};
	auto &sprite = batch.sprites[index];
	for (int vertexIndex = 0; vertexIndex < 4; ++vertexIndex)
	{
		auto &vertex = sprite.vertices[vertexIndex];
		const float px = positions[vertexIndex][0];
		const float py = positions[vertexIndex][1];
		vertex.x = local.elements[0] * px + local.elements[4] * py + local.elements[12];
		vertex.y = local.elements[1] * px + local.elements[5] * py + local.elements[13];
		vertex.u = texcoords[vertexIndex][0];
		vertex.v = texcoords[vertexIndex][1];
		vertex.red = batch.colorEnabled ? batch.color[0] : 1.0f;
		vertex.green = batch.colorEnabled ? batch.color[1] : 1.0f;
		vertex.blue = batch.colorEnabled ? batch.color[2] : 1.0f;
		vertex.alpha = batch.colorEnabled ? batch.color[3] : 1.0f;
		vertex.textureLayer = arrayTexture ? static_cast<float>(layer)
			: std::numeric_limits<float>::quiet_NaN();
	}
	batch.geometryDirty = true;
	return static_cast<int>(index);
}
}

int SpriteBatchUserdata::add(const ::love::Matrix4 &matrix, int index)
{
	return writeSpriteBatchSprite(*this, nullptr, matrix, index, std::nullopt);
}

int SpriteBatchUserdata::add(::love::graphics::Quad *quad,
	const ::love::Matrix4 &matrix, int index)
{
	return writeSpriteBatchSprite(*this, quad, matrix, index, std::nullopt);
}

int SpriteBatchUserdata::addLayer(int layer, const ::love::Matrix4 &matrix, int index)
{
	return writeSpriteBatchSprite(*this, nullptr, matrix, index, layer);
}

int SpriteBatchUserdata::addLayer(int layer, ::love::graphics::Quad *quad,
	const ::love::Matrix4 &matrix, int index)
{
	return writeSpriteBatchSprite(*this, quad, matrix, index, layer);
}

void SpriteBatchUserdata::clear()
{
	count = 0;
	geometryDirty = true;
}

void SpriteBatchUserdata::setTexture(::love::graphics::Texture *texture)
{
	auto *imageTexture = dynamic_cast<ImageUserdata *>(texture);
	auto *canvasTexture = dynamic_cast<CanvasUserdata *>(texture);
	if (!imageTexture && !canvasTexture)
		throw ::love::Exception("expected an Image or Canvas");
	if (imageTexture)
	{
		if (imageTexture->runtime != runtime || imageTexture->handle == 0)
			throw ::love::Exception("Image belongs to another or closed LoveRuntime");
		if (imageTexture->textureType != textureType)
			throw ::love::Exception(
				"Texture must have the same texture type as the SpriteBatch's previous texture");
		image = imageTexture->handle;
		canvas = 0;
		layerCount = imageTexture->slices;
		textureObject.set(imageTexture);
	}
	else
	{
		if (textureType != GraphicsBackend::TextureType::Texture2D)
			throw ::love::Exception(
				"Texture must have the same texture type as the SpriteBatch's previous texture");
		if (canvasTexture->runtime != runtime || canvasTexture->handle == 0
			|| !canvasTexture->readable)
			throw ::love::Exception("cannot use a closed or non-readable Canvas as a SpriteBatch texture");
		image = 0;
		canvas = canvasTexture->handle;
		layerCount = 1;
		textureObject.set(canvasTexture);
	}
	geometryDirty = true;
}

::love::graphics::Texture *SpriteBatchUserdata::getTexture() const
{
	return dynamic_cast<::love::graphics::Texture *>(textureObject.get());
}

void SpriteBatchUserdata::setColor(const ::love::Colorf &value)
{
	const float values[] = {value.r, value.g, value.b, value.a};
	for (const float component : values)
		if (!std::isfinite(component))
			throw ::love::Exception("SpriteBatch color values must be finite");
	for (std::size_t index = 0; index < 4; ++index)
	{
		const float clamped = std::clamp(values[index], 0.0f, 1.0f);
		color[index] = static_cast<unsigned char>(clamped * 255.0f) / 255.0f;
	}
	colorEnabled = true;
}

::love::Colorf SpriteBatchUserdata::getColor(bool &active) const
{
	active = colorEnabled;
	return {color[0], color[1], color[2], color[3]};
}

void SpriteBatchUserdata::attachAttribute(const std::string &name,
	::love::graphics::Mesh *meshObject)
{
	auto *mesh = dynamic_cast<MeshUserdata *>(meshObject);
	if (!mesh || !runtime || mesh->runtime != runtime)
		throw ::love::Exception("attached Mesh belongs to another or closed LoveRuntime");
	const std::size_t attributeIndex = meshAttributeIndex(*mesh, name);
	if (attributeIndex >= mesh->format.size())
		throw ::love::Exception(
			"the supplied Mesh does not have the requested vertex attribute");
	if (count > std::numeric_limits<std::size_t>::max() / 4
		|| mesh->vertexCount < count * 4)
		throw ::love::Exception(
			"Mesh has too few vertices to be attached to this SpriteBatch");
	attachments[name] = {mesh, attributeIndex};
	attachmentObjects[name].set(mesh);
	geometryDirty = true;
}

void SpriteBatchUserdata::setDrawRange(int start, int rangeCount)
{
	if (start < 0 || rangeCount <= 0)
		throw ::love::Exception("invalid SpriteBatch draw range");
	drawStart = start;
	drawCount = rangeCount;
	geometryDirty = true;
}

void SpriteBatchUserdata::setDrawRange()
{
	drawStart = -1;
	drawCount = 0;
	geometryDirty = true;
}

bool SpriteBatchUserdata::getDrawRange(int &start, int &rangeCount) const
{
	if (drawStart < 0) return false;
	start = drawStart;
	rangeCount = drawCount;
	return true;
}
namespace
{
double particleRandom(ParticleSystemUserdata &system)
{
	std::uint64_t value = system.randomState;
	value ^= value >> 12;
	value ^= value << 25;
	value ^= value >> 27;
	system.randomState = value;
	return static_cast<double>((value * 2685821657736338717ULL) >> 11)
		* (1.0 / 9007199254740992.0);
}

float particleRandomRange(ParticleSystemUserdata &system, float minimum, float maximum)
{
	return minimum == maximum ? minimum
		: minimum + static_cast<float>(particleRandom(system)) * (maximum - minimum);
}

float particleRandomNormal(ParticleSystemUserdata &system, float deviation)
{
	const double u1 = std::max(particleRandom(system), std::numeric_limits<double>::min());
	const double u2 = particleRandom(system);
	return deviation * static_cast<float>(std::sqrt(-2.0 * std::log(u1))
		* std::cos(2.0 * std::numbers::pi * u2));
}

ParticleColor interpolateParticleColor(const ParticleColor &first,
	const ParticleColor &second, float amount)
{
	return {
		first.red + (second.red - first.red) * amount,
		first.green + (second.green - first.green) * amount,
		first.blue + (second.blue - first.blue) * amount,
		first.alpha + (second.alpha - first.alpha) * amount,
	};
}

float variedParticleValue(ParticleSystemUserdata &system,
	float value, float alternate, float variation)
{
	return value + (alternate - value) * variation
		* static_cast<float>(particleRandom(system));
}

void resetParticleSystemOffset(ParticleSystemUserdata &system)
{
	if (!system.defaultOffset || !system.runtime || !system.runtime->getGraphicsBackend()) return;
	if (!system.quads.empty())
	{
		system.offsetX = system.quads.front().width * 0.5f;
		system.offsetY = system.quads.front().height * 0.5f;
		return;
	}
	auto *graphics = system.runtime->getGraphicsBackend();
	system.offsetX = static_cast<float>(system.image != 0
		? graphics->getImageWidth(system.image) : graphics->getCanvasWidth(system.canvas)) * 0.5f;
	system.offsetY = static_cast<float>(system.image != 0
		? graphics->getImageHeight(system.image) : graphics->getCanvasHeight(system.canvas)) * 0.5f;
}

void initializeParticle(ParticleSystemUserdata &system, ParticleState &particle, float time)
{
	particle = {};
	particle.life = particleRandomRange(system,
		system.particleLifetimeMin, system.particleLifetimeMax);
	particle.lifetime = particle.life;
	particle.x = system.previousX + (system.positionX - system.previousX) * time;
	particle.y = system.previousY + (system.positionY - system.previousY) * time;
	const float centerX = particle.x, centerY = particle.y;
	float direction = particleRandomRange(system,
		system.direction - system.spread * 0.5f,
		system.direction + system.spread * 0.5f);
	float dx = 0.0f, dy = 0.0f;
	if (system.emissionDistribution == "uniform")
	{
		dx = particleRandomRange(system, -system.emissionX, system.emissionX);
		dy = particleRandomRange(system, -system.emissionY, system.emissionY);
	}
	else if (system.emissionDistribution == "normal")
	{
		dx = particleRandomNormal(system, system.emissionX);
		dy = particleRandomNormal(system, system.emissionY);
	}
	else if (system.emissionDistribution == "ellipse")
	{
		const float rx = particleRandomRange(system, -1.0f, 1.0f);
		const float ry = particleRandomRange(system, -1.0f, 1.0f);
		dx = system.emissionX * rx * std::sqrt(std::max(0.0f, 1.0f - 0.5f * ry * ry));
		dy = system.emissionY * ry * std::sqrt(std::max(0.0f, 1.0f - 0.5f * rx * rx));
	}
	else if (system.emissionDistribution == "borderellipse")
	{
		const float radians = particleRandomRange(system, 0.0f,
			2.0f * std::numbers::pi_v<float>);
		dx = std::cos(radians) * system.emissionX;
		dy = std::sin(radians) * system.emissionY;
	}
	else if (system.emissionDistribution == "borderrectangle")
	{
		const float width = system.emissionX * 2.0f;
		const float height = system.emissionY * 2.0f;
		float point = particleRandomRange(system, 0.0f, 2.0f * (width + height));
		if (point < width) { dx = -system.emissionX + point; dy = -system.emissionY; }
		else if ((point -= width) < height) { dx = system.emissionX; dy = -system.emissionY + point; }
		else if ((point -= height) < width) { dx = system.emissionX - point; dy = system.emissionY; }
		else { point -= width; dx = -system.emissionX; dy = system.emissionY - point; }
	}
	const float areaCosine = std::cos(system.emissionAngle);
	const float areaSine = std::sin(system.emissionAngle);
	particle.x += areaCosine * dx - areaSine * dy;
	particle.y += areaSine * dx + areaCosine * dy;
	if (system.directionRelativeToCenter)
		direction += std::atan2(particle.y - centerY, particle.x - centerX);
	particle.originX = centerX;
	particle.originY = centerY;
	const float speed = particleRandomRange(system, system.speedMin, system.speedMax);
	particle.velocityX = std::cos(direction) * speed;
	particle.velocityY = std::sin(direction) * speed;
	particle.accelerationX = particleRandomRange(system, system.accelerationMinX, system.accelerationMaxX);
	particle.accelerationY = particleRandomRange(system, system.accelerationMinY, system.accelerationMaxY);
	particle.radialAcceleration = particleRandomRange(system, system.radialMin, system.radialMax);
	particle.tangentialAcceleration = particleRandomRange(system, system.tangentialMin, system.tangentialMax);
	particle.linearDamping = particleRandomRange(system, system.dampingMin, system.dampingMax);
	particle.sizeOffset = particleRandomRange(system, 0.0f, system.sizeVariation);
	particle.sizeInterval = 1.0f - particleRandomRange(system, 0.0f, system.sizeVariation)
		- particle.sizeOffset;
	particle.size = system.sizes.front();
	particle.spinStart = variedParticleValue(system,
		system.spinStart, system.spinEnd, system.spinVariation);
	particle.spinEnd = variedParticleValue(system,
		system.spinEnd, system.spinStart, system.spinVariation);
	particle.rotation = particleRandomRange(system, system.rotationMin, system.rotationMax);
	particle.angle = particle.rotation;
	if (system.relativeRotation)
		particle.angle += std::atan2(particle.velocityY, particle.velocityX);
	particle.color = system.colors.front();
}

void addParticle(ParticleSystemUserdata &system, float time)
{
	system.geometryDirty = true;
	if (system.particles.size() >= system.bufferSize) return;
	ParticleState particle;
	initializeParticle(system, particle, time);
	if (system.insertMode == "bottom") system.particles.insert(system.particles.begin(), particle);
	else if (system.insertMode == "random")
	{
		const std::size_t index = static_cast<std::size_t>(particleRandom(system)
			* static_cast<double>(system.particles.size() + 1));
		system.particles.insert(system.particles.begin()
			+ static_cast<std::ptrdiff_t>(std::min(index, system.particles.size())), particle);
	}
	else system.particles.push_back(particle);
}
} // namespace

::love::graphics::ParticleSystem *ParticleSystemUserdata::clone()
{
	auto *result = new ParticleSystemUserdata(*this);
	result->renderBuffer = std::make_shared<GraphicsBackend::MeshBuffer>();
	result->geometryDirty = true;
	result->preparedParticleCount = 0;
	result->particles.clear();
	result->particles.reserve(result->bufferSize);
	result->emitCounter = 0.0f;
	result->emitterLife = result->emitterLifetime;
	return result;
}

void ParticleSystemUserdata::setTexture(::love::graphics::Texture *texture)
{
	if (!texture || texture->getTextureType() != ::love::graphics::TEXTURE_2D)
		throw ::love::Exception("ParticleSystem supports only 2D textures");
	if (auto *imageObject = dynamic_cast<ImageUserdata *>(texture))
	{
		if (imageObject->runtime != runtime || imageObject->handle == 0)
			throw ::love::Exception("Image belongs to another or closed LoveRuntime");
		image = imageObject->handle;
		canvas = 0;
	}
	else if (auto *canvasObject = dynamic_cast<CanvasUserdata *>(texture))
	{
		if (canvasObject->runtime != runtime || canvasObject->handle == 0)
			throw ::love::Exception("Canvas belongs to another or closed LoveRuntime");
		if (!canvasObject->readable)
			throw ::love::Exception("cannot use a non-readable Canvas as a ParticleSystem texture");
		image = 0;
		canvas = canvasObject->handle;
	}
	else throw ::love::Exception("expected a 2D Image or Canvas");
	textureObject.set(texture);
	resetParticleSystemOffset(*this);
	geometryDirty = true;
}

void ParticleSystemUserdata::setQuads(
	const std::vector<::love::graphics::Quad *> &values)
{
	quads.clear();
	quadObjects.clear();
	for (auto *quad : values)
	{
		const auto viewport = quad->getViewport();
		quads.push_back({static_cast<float>(viewport.x), static_cast<float>(viewport.y),
			static_cast<float>(viewport.w), static_cast<float>(viewport.h),
			static_cast<float>(quad->getTextureWidth()),
			static_cast<float>(quad->getTextureHeight())});
		quadObjects.emplace_back(quad);
	}
	resetParticleSystemOffset(*this);
	geometryDirty = true;
}

void ParticleSystemUserdata::setQuads()
{
	setQuads({});
}

void ParticleSystemUserdata::emit(::love::uint32 count)
{
	if (active)
		for (::love::uint32 index = 0; index < count && particles.size() < bufferSize; ++index)
			addParticle(*this, 1.0f);
}

void ParticleSystemUserdata::update(float dt)
{
	if (!std::isfinite(dt) || dt < 0.0f)
		throw ::love::Exception("update time must be finite and non-negative");
	if (dt == 0.0f) return;
	geometryDirty = true;
	for (std::size_t index = 0; index < particles.size();)
	{
		auto &particle = particles[index];
		particle.life -= dt;
		if (particle.life <= 0.0f)
		{
			particles.erase(particles.begin() + static_cast<std::ptrdiff_t>(index));
			continue;
		}
		float radialX = particle.x - particle.originX;
		float radialY = particle.y - particle.originY;
		const float distance = std::sqrt(radialX * radialX + radialY * radialY);
		if (distance > 0.0f) { radialX /= distance; radialY /= distance; }
		const float tangentX = -radialY * particle.tangentialAcceleration;
		const float tangentY = radialX * particle.tangentialAcceleration;
		particle.velocityX += (radialX * particle.radialAcceleration + tangentX
			+ particle.accelerationX) * dt;
		particle.velocityY += (radialY * particle.radialAcceleration + tangentY
			+ particle.accelerationY) * dt;
		const float damping = 1.0f / (1.0f + particle.linearDamping * dt);
		particle.velocityX *= damping;
		particle.velocityY *= damping;
		particle.x += particle.velocityX * dt;
		particle.y += particle.velocityY * dt;
		const float age = particle.lifetime > 0.0f
			? 1.0f - particle.life / particle.lifetime : 1.0f;
		particle.rotation += (particle.spinStart * (1.0f - age) + particle.spinEnd * age) * dt;
		particle.angle = particle.rotation + (relativeRotation
			? std::atan2(particle.velocityY, particle.velocityX) : 0.0f);
		float progress = std::clamp(particle.sizeOffset + age * particle.sizeInterval, 0.0f, 1.0f)
			* static_cast<float>(sizes.size() - 1);
		std::size_t first = std::min(static_cast<std::size_t>(progress), sizes.size() - 1);
		std::size_t second = std::min(first + 1, sizes.size() - 1);
		particle.size = sizes[first] + (sizes[second] - sizes[first])
			* (progress - static_cast<float>(first));
		progress = std::clamp(age, 0.0f, 1.0f) * static_cast<float>(colors.size() - 1);
		first = std::min(static_cast<std::size_t>(progress), colors.size() - 1);
		second = std::min(first + 1, colors.size() - 1);
		particle.color = interpolateParticleColor(colors[first], colors[second],
			progress - static_cast<float>(first));
		if (!quads.empty())
			particle.quadIndex = std::min(static_cast<std::size_t>(
				std::clamp(age, 0.0f, 1.0f) * static_cast<float>(quads.size())), quads.size() - 1);
		++index;
	}
	if (active)
	{
		if (emissionRate > 0.0f)
		{
			const float interval = 1.0f / emissionRate;
			emitCounter += dt;
			const float total = std::max(emitCounter - interval,
				std::numeric_limits<float>::epsilon());
			while (emitCounter > interval && particles.size() < bufferSize)
			{
				addParticle(*this, std::clamp(1.0f - (emitCounter - interval) / total, 0.0f, 1.0f));
				emitCounter -= interval;
			}
		}
		emitterLife -= dt;
		if (emitterLifetime != -1.0f && emitterLife < 0.0f) stop();
	}
	previousX = positionX;
	previousY = positionY;
}

int LoveRuntime::canvasRenderTo(lua_State *state)
{
	auto *canvas = checkCanvas(state, 1);
	auto *runtime = canvas->runtime;
	luaL_argcheck(state, runtime && runtime->_graphicsBackend
		&& runtime->_canvasHandles.contains(canvas->handle), 1, "closed Canvas");
	luaL_checktype(state, 2, LUA_TFUNCTION);
	luaL_argcheck(state, canvas->textureType == GraphicsBackend::TextureType::Texture2D, 1,
		"layered Canvas renderTo is not available until layered Canvas support is enabled");

	auto savedCanvases = std::move(runtime->_graphicsCanvases);
	auto savedTargets = std::move(runtime->_graphicsCanvasTargets);
	auto savedReferences = std::move(runtime->_graphicsCanvasReferences);
	auto savedObjects = std::move(runtime->_graphicsCanvasObjects);
	const auto savedDepthStencil = runtime->_graphicsCanvasDepthStencil;
	const auto savedDepthTarget = runtime->_graphicsCanvasDepthStencilTarget;
	const int savedDepthReference = runtime->_graphicsCanvasDepthStencilReference;
	auto savedDepthObject = std::move(runtime->_graphicsCanvasDepthStencilObject);
	const bool savedDepth = runtime->_graphicsCanvasDepth;
	const bool savedStencil = runtime->_graphicsCanvasStencil;

	std::string error;
	const GraphicsBackend::CanvasTarget renderTarget{canvas->handle, 0, 0};
	if (!runtime->_graphicsBackend->setCanvasTargets({&renderTarget, 1}, nullptr,
		false, false, error))
	{
		runtime->_graphicsCanvases = std::move(savedCanvases);
		runtime->_graphicsCanvasTargets = std::move(savedTargets);
		runtime->_graphicsCanvasReferences = std::move(savedReferences);
		runtime->_graphicsCanvasObjects = std::move(savedObjects);
		runtime->_graphicsCanvasDepthStencilObject = std::move(savedDepthObject);
		return luaL_error(state, "%s", error.c_str());
	}
	runtime->_graphicsCanvases = {canvas->handle};
	runtime->_graphicsCanvasTargets = {renderTarget};
	runtime->_graphicsCanvasObjects = {::love::StrongRef<::love::Object>(canvas)};
	lua_pushvalue(state, 1);
	runtime->_graphicsCanvasReferences = {luaL_ref(state, LUA_REGISTRYINDEX)};
	runtime->_graphicsCanvasDepthStencil = 0;
	runtime->_graphicsCanvasDepthStencilTarget = {};
	runtime->_graphicsCanvasDepthStencilObject.set(nullptr);
	runtime->_graphicsCanvasDepthStencilReference = LUA_NOREF;
	runtime->_graphicsCanvasDepth = false;
	runtime->_graphicsCanvasStencil = false;

	const int argumentCount = lua_gettop(state) - 2;
	lua_pushvalue(state, 2);
	for (int index = 0; index < argumentCount; ++index)
		lua_pushvalue(state, 3 + index);
	const int status = lua_pcall(state, argumentCount, 0, 0);
	std::string callbackError;
	if (status != LUA_OK)
	{
		const char *message = lua_tostring(state, -1);
		callbackError = message ? message : "Canvas:renderTo callback failed";
		lua_pop(state, 1);
	}

	for (const int reference : runtime->_graphicsCanvasReferences)
		luaL_unref(state, LUA_REGISTRYINDEX, reference);
	if (runtime->_graphicsCanvasDepthStencilReference != LUA_NOREF)
		luaL_unref(state, LUA_REGISTRYINDEX, runtime->_graphicsCanvasDepthStencilReference);
	if (!runtime->_graphicsBackend->setCanvasTargets(savedTargets,
		savedDepthStencil != 0 ? &savedDepthTarget : nullptr,
		savedDepth, savedStencil, error) && callbackError.empty())
		callbackError = error.empty() ? "failed to restore Canvas after renderTo" : error;
	runtime->_graphicsCanvases = std::move(savedCanvases);
	runtime->_graphicsCanvasTargets = std::move(savedTargets);
	runtime->_graphicsCanvasReferences = std::move(savedReferences);
	runtime->_graphicsCanvasObjects = std::move(savedObjects);
	runtime->_graphicsCanvasDepthStencil = savedDepthStencil;
	runtime->_graphicsCanvasDepthStencilTarget = savedDepthTarget;
	runtime->_graphicsCanvasDepthStencilReference = savedDepthReference;
	runtime->_graphicsCanvasDepthStencilObject = std::move(savedDepthObject);
	runtime->_graphicsCanvasDepth = savedDepth;
	runtime->_graphicsCanvasStencil = savedStencil;
	if (!callbackError.empty()) return luaL_error(state, "%s", callbackError.c_str());
	return 0;
}

namespace
{
void pushThreadData(lua_State *state, const std::vector<std::uint8_t> &bytes)
{
	auto *data = new ::love::data::ByteData(bytes.data(), bytes.size());
	::love::luax_pushtype(state, ::love::data::ByteData::type, data);
	data->release();
}
}

namespace
{
std::uint16_t readFontU16(const std::uint8_t *bytes)
{
	return static_cast<std::uint16_t>((static_cast<std::uint16_t>(bytes[0]) << 8) | bytes[1]);
}

std::uint32_t readFontU32(const std::uint8_t *bytes)
{
	return (static_cast<std::uint32_t>(bytes[0]) << 24)
		| (static_cast<std::uint32_t>(bytes[1]) << 16)
		| (static_cast<std::uint32_t>(bytes[2]) << 8) | bytes[3];
}

bool fontRange(std::size_t offset, std::size_t length, std::size_t size)
{
	return offset <= size && length <= size - offset;
}

bool validateSfnt(const std::vector<std::uint8_t> &bytes, std::size_t offset)
{
	if (!fontRange(offset, 12, bytes.size())) return false;
	const auto signature = readFontU32(bytes.data() + offset);
	if (signature != 0x00010000 && signature != 0x4f54544f
		&& signature != 0x74727565 && signature != 0x74797031) return false;
	const auto count = readFontU16(bytes.data() + offset + 4);
	if (count == 0 || count > 4096 || !fontRange(offset + 12,
		static_cast<std::size_t>(count) * 16, bytes.size())) return false;
	bool cmap = false, head = false, hhea = false, hmtx = false, maxp = false;
	bool glyf = false, loca = false, cff = false;
	for (std::uint16_t index = 0; index < count; ++index)
	{
		const auto *record = bytes.data() + offset + 12 + static_cast<std::size_t>(index) * 16;
		const auto tag = readFontU32(record);
		const auto tableOffset = readFontU32(record + 8);
		const auto length = readFontU32(record + 12);
		if (!fontRange(tableOffset, length, bytes.size())) return false;
		switch (tag)
		{
			case 0x636d6170: cmap = length >= 4; break;
			case 0x68656164: head = length >= 54; break;
			case 0x68686561: hhea = length >= 36; break;
			case 0x686d7478: hmtx = length >= 4; break;
			case 0x6d617870: maxp = length >= 6; break;
			case 0x676c7966: glyf = length > 0; break;
			case 0x6c6f6361: loca = length >= 4; break;
			case 0x43464620:
			case 0x43464632: cff = length > 0; break;
			default: break;
		}
	}
	return cmap && head && hhea && hmtx && maxp && ((glyf && loca) || cff);
}

bool validateFontData(const std::vector<std::uint8_t> &bytes)
{
	if (bytes.size() < 12) return false;
	if (readFontU32(bytes.data()) != 0x74746366) return validateSfnt(bytes, 0);
	if (!fontRange(0, 16, bytes.size())) return false;
	const auto count = readFontU32(bytes.data() + 8);
	return count > 0 && count <= 4096 && fontRange(12, static_cast<std::size_t>(count) * 4, bytes.size())
		&& validateSfnt(bytes, readFontU32(bytes.data() + 12));
}

struct BMFontLineData
{
	std::string tag;
	std::unordered_map<std::string, std::string> attributes;
};

BMFontLineData parseBMFontLine(std::string_view line)
{
	BMFontLineData result;
	std::size_t position = 0;
	while (position < line.size() && std::isspace(static_cast<unsigned char>(line[position]))) ++position;
	const std::size_t tagStart = position;
	while (position < line.size() && !std::isspace(static_cast<unsigned char>(line[position]))) ++position;
	result.tag.assign(line.substr(tagStart, position - tagStart));
	while (position < line.size())
	{
		while (position < line.size() && std::isspace(static_cast<unsigned char>(line[position]))) ++position;
		const std::size_t keyStart = position;
		while (position < line.size() && line[position] != '='
			&& !std::isspace(static_cast<unsigned char>(line[position]))) ++position;
		if (position >= line.size() || line[position] != '=')
		{
			while (position < line.size() && !std::isspace(static_cast<unsigned char>(line[position]))) ++position;
			continue;
		}
		std::string key(line.substr(keyStart, position - keyStart));
		++position;
		std::string value;
		if (position < line.size() && line[position] == '"')
		{
			++position;
			const std::size_t valueStart = position;
			while (position < line.size() && line[position] != '"') ++position;
			value.assign(line.substr(valueStart, position - valueStart));
			if (position < line.size()) ++position;
		}
		else
		{
			const std::size_t valueStart = position;
			while (position < line.size() && !std::isspace(static_cast<unsigned char>(line[position]))) ++position;
			value.assign(line.substr(valueStart, position - valueStart));
		}
		if (!key.empty()) result.attributes[std::move(key)] = std::move(value);
	}
	return result;
}

bool bmFontInteger(const BMFontLineData &line, std::string_view name, int defaultValue,
	int &value, std::string &error, bool required = false)
{
	const auto found = line.attributes.find(std::string(name));
	if (found == line.attributes.end())
	{
		if (required)
		{
			error = "BMFont " + line.tag + " entry is missing " + std::string(name);
			return false;
		}
		value = defaultValue;
		return true;
	}
	const char *begin = found->second.data();
	const char *end = begin + found->second.size();
	const auto result = std::from_chars(begin, end, value);
	if (result.ec != std::errc{} || result.ptr != end)
	{
		error = "BMFont " + line.tag + " attribute " + std::string(name) + " is not an integer";
		return false;
	}
	return true;
}

bool validateCompressedImage(const ImageBackend::CompressedImage &image)
{
	if (image.format.empty() || image.levels.empty()) return false;
	std::size_t total = 0;
	int previousWidth = MaximumWindowDimension + 1;
	int previousHeight = MaximumWindowDimension + 1;
	for (const auto &level : image.levels)
	{
		if (level.width <= 0 || level.height <= 0
			|| level.width > MaximumWindowDimension || level.height > MaximumWindowDimension
			|| level.width > previousWidth || level.height > previousHeight || level.bytes.empty()
			|| level.bytes.size() > MaximumLoveDataBytes - total)
			return false;
		total += level.bytes.size();
		previousWidth = level.width;
		previousHeight = level.height;
	}
	return total > 0;
}
} // namespace

::love::image::ImageData *DoraLoveImage::newImageData(::love::Data *data)
{
	if (!data || !_runtime || !_runtime->getImageBackend())
		throw ::love::Exception("love.image is not attached to a Dora image decoder");
	int width = 0;
	int height = 0;
	std::vector<std::uint8_t> pixels;
	std::string error;
	const auto encoded = std::string_view(static_cast<const char *>(data->getData()), data->getSize());
	if (!_runtime->getImageBackend()->decodeImage(encoded, width, height, pixels, error))
		throw ::love::Exception("Love ImageData decode failed: %s",
			error.empty() ? "Dora image decoder rejected the data" : error.c_str());
	const std::size_t expected = static_cast<std::size_t>(width)
		* static_cast<std::size_t>(height) * 4;
	if (width <= 0 || height <= 0 || width > MaximumWindowDimension
		|| height > MaximumWindowDimension || pixels.size() != expected)
		throw ::love::Exception("Dora image decoder returned invalid rgba8 dimensions");
	return new DoraImageData(_runtime, width, height, ::love::PIXELFORMAT_RGBA8, pixels.data());
}

::love::image::ImageData *DoraLoveImage::newImageData(int width, int height,
	::love::PixelFormat format)
{
	return new DoraImageData(_runtime, width, height, format);
}

::love::image::ImageData *DoraLoveImage::newImageData(int width, int height,
	::love::PixelFormat format, void *data, bool own)
{
	auto *result = new DoraImageData(_runtime, width, height, format, data);
	if (own) delete[] static_cast<::love::uint8 *>(data);
	return result;
}

::love::image::CompressedImageData *DoraLoveImage::newCompressedData(::love::Data *data)
{
	if (!data || !_runtime || !_runtime->getImageBackend())
		throw ::love::Exception("love.image is not attached to a Dora compressed image parser");
	ImageBackend::CompressedImage image;
	std::string error;
	const auto encoded = std::string_view(static_cast<const char *>(data->getData()), data->getSize());
	if (!_runtime->getImageBackend()->decodeCompressedImage(encoded, image, error))
		throw ::love::Exception("Love CompressedImageData decode failed: %s",
			error.empty() ? "Dora image parser rejected the data" : error.c_str());
	if (!validateCompressedImage(image))
		throw ::love::Exception("Dora image parser returned invalid compressed metadata");
	return new DoraCompressedImageData(std::move(image));
}

bool DoraLoveImage::isCompressed(::love::Data *data)
{
	if (!data || !_runtime || !_runtime->getImageBackend()) return false;
	ImageBackend::CompressedImage image;
	std::string error;
	const auto encoded = std::string_view(static_cast<const char *>(data->getData()), data->getSize());
	return _runtime->getImageBackend()->decodeCompressedImage(encoded, image, error)
		&& validateCompressedImage(image);
}

::love::font::Rasterizer *DoraLoveFont::newRasterizer(
	::love::filesystem::FileData *data)
{
	if (!data)
		throw ::love::Exception("Font data is unavailable.");
	const std::string_view bytes(static_cast<const char *>(data->getData()), data->getSize());
	if (bytes.starts_with("info"))
		return newBMFontRasterizer(data, {}, 1.0f);
	return newTrueTypeRasterizer(data, 12,
		::love::font::TrueTypeRasterizer::HINTING_NORMAL);
}

::love::font::Rasterizer *DoraLoveFont::newTrueTypeRasterizer(int size,
	::love::font::TrueTypeRasterizer::Hinting hinting)
{
	return newTrueTypeRasterizer(size, 1.0f, hinting);
}

::love::font::Rasterizer *DoraLoveFont::newTrueTypeRasterizer(int size,
	float dpiScale, ::love::font::TrueTypeRasterizer::Hinting hinting)
{
	if (!_runtime || _runtime->_defaultFontData.empty())
		throw ::love::Exception("Default TrueType font data is unavailable.");
	auto *data = new ::love::data::ByteData(_runtime->_defaultFontData.data(),
		_runtime->_defaultFontData.size());
	::love::StrongRef<::love::data::ByteData> retained(data, ::love::Acquire::NORETAIN);
	return newTrueTypeRasterizer(data, size, dpiScale, hinting);
}

::love::font::Rasterizer *DoraLoveFont::newTrueTypeRasterizer(::love::Data *data,
	int size, ::love::font::TrueTypeRasterizer::Hinting hinting)
{
	return newTrueTypeRasterizer(data, size, 1.0f, hinting);
}

::love::font::Rasterizer *DoraLoveFont::newTrueTypeRasterizer(::love::Data *data,
	int size, float dpiScale, ::love::font::TrueTypeRasterizer::Hinting hinting)
{
	if (!data || data->getSize() == 0)
		throw ::love::Exception("TrueType font data is empty.");
	if (size <= 0 || size > 4096)
		throw ::love::Exception("TrueType Rasterizer size must be between 1 and 4096.");
	if (!std::isfinite(dpiScale) || dpiScale <= 0.0f
		|| static_cast<double>(size) * dpiScale > 4096.0)
		throw ::love::Exception("TrueType Rasterizer DPI scale is outside the supported range.");
	if (data->getSize() > MaximumLoveDataBytes)
		throw ::love::Exception("TrueType font data is too large.");

	RasterizerUserdata rasterizer;
	rasterizer.kind = RasterizerUserdata::Kind::TrueType;
	rasterizer.runtime = _runtime;
	rasterizer.requestedSize = size;
	rasterizer.setDPIScale(dpiScale);
	rasterizer.monochrome = hinting == ::love::font::TrueTypeRasterizer::HINTING_MONO;
	const auto *begin = static_cast<const std::uint8_t *>(data->getData());
	rasterizer.fontBytes.assign(begin, begin + data->getSize());
	if (!validateFontData(rasterizer.fontBytes))
		throw ::love::Exception("Invalid or truncated TrueType/OpenType font data.");
	const int fontOffset = stbtt_GetFontOffsetForIndex(rasterizer.fontBytes.data(), 0);
	if (fontOffset < 0
		|| stbtt_InitFont(&rasterizer.fontInfo, rasterizer.fontBytes.data(), fontOffset) == 0)
		throw ::love::Exception("Failed to initialize TrueType/OpenType font data.");
	const float pixelSize = static_cast<float>(std::floor(
		static_cast<double>(size) * dpiScale + 0.5));
	rasterizer.fontScale = stbtt_ScaleForPixelHeight(&rasterizer.fontInfo, pixelSize);
	int ascent = 0, descent = 0, lineGap = 0;
	stbtt_GetFontVMetrics(&rasterizer.fontInfo, &ascent, &descent, &lineGap);
	rasterizer.ascent = static_cast<int>(std::floor(ascent * rasterizer.fontScale + 0.5f));
	rasterizer.descent = static_cast<int>(std::ceil(descent * rasterizer.fontScale - 0.5f));
	rasterizer.height = static_cast<int>(std::floor(
		(ascent - descent) * rasterizer.fontScale + 0.5f));
	rasterizer.lineHeight = static_cast<int>(std::floor(rasterizer.height * 1.25f));
	int x0 = 0, y0 = 0, x1 = 0, y1 = 0;
	stbtt_GetFontBoundingBox(&rasterizer.fontInfo, &x0, &y0, &x1, &y1);
	rasterizer.advance = static_cast<int>(std::floor(
		(x1 - x0) * rasterizer.fontScale + 0.5f));
	return new RasterizerUserdata(std::move(rasterizer));
}

::love::font::Rasterizer *DoraLoveFont::newImageRasterizer(
	::love::image::ImageData *data, const std::string &glyphText,
	int extraSpacing, float dpiScale)
{
	std::vector<std::uint32_t> glyphs;
	std::string error;
	if (!decodeUtf8(glyphText, glyphs, error))
		throw ::love::Exception("UTF-8 decoding error: %s", error.c_str());
	return newImageRasterizer(data, glyphs.data(), static_cast<int>(glyphs.size()),
		extraSpacing, dpiScale);
}

::love::font::Rasterizer *DoraLoveFont::newImageRasterizer(
	::love::image::ImageData *data, ::love::uint32 *glyphs, int length,
	int extraSpacing, float dpiScale)
{
	auto *image = dynamic_cast<ImageDataUserdata *>(data);
	if (!image || image->getRuntime() != _runtime)
		throw ::love::Exception("ImageData belongs to another LoveRuntime.");
	if (image->getFormat() != ::love::PIXELFORMAT_RGBA8)
		throw ::love::Exception("Image Rasterizer requires an rgba8 ImageData source.");
	if (!glyphs || length <= 0)
		throw ::love::Exception("Image Rasterizer glyph string must not be empty.");
	if (!std::isfinite(dpiScale) || dpiScale <= 0.0f)
		throw ::love::Exception("Image Rasterizer DPI scale must be positive and finite.");

	RasterizerUserdata rasterizer;
	rasterizer.kind = RasterizerUserdata::Kind::Image;
	rasterizer.runtime = _runtime;
	rasterizer.height = image->getHeight();
	rasterizer.lineHeight = image->getHeight();
	rasterizer.extraSpacing = extraSpacing;
	rasterizer.setDPIScale(dpiScale);
	rasterizer.glyphs.assign(glyphs, glyphs + length);
	std::vector<std::uint8_t> rgba8;
	imageDataToRGBA8(*image, rgba8);
	std::copy_n(rgba8.begin(), 4, rasterizer.spacer.begin());
	int end = 0;
	for (const auto codepoint : rasterizer.glyphs)
	{
		int start = end;
		while (start < image->getWidth()
			&& std::equal(rasterizer.spacer.begin(), rasterizer.spacer.end(),
				rgba8.begin() + static_cast<std::ptrdiff_t>(start) * 4)) ++start;
		end = start;
		while (end < image->getWidth()
			&& !std::equal(rasterizer.spacer.begin(), rasterizer.spacer.end(),
				rgba8.begin() + static_cast<std::ptrdiff_t>(end) * 4)) ++end;
		if (start >= end) break;
		auto found = std::find_if(rasterizer.imageGlyphs.begin(), rasterizer.imageGlyphs.end(),
			[codepoint](const ImageRasterizerGlyph &glyph) { return glyph.codepoint == codepoint; });
		if (found == rasterizer.imageGlyphs.end())
			rasterizer.imageGlyphs.push_back({codepoint, start, end - start});
		else *found = {codepoint, start, end - start};
	}
	rasterizer.sourceObjects.emplace_back(image);
	return new RasterizerUserdata(std::move(rasterizer));
}

::love::font::Rasterizer *DoraLoveFont::newBMFontRasterizer(
	::love::filesystem::FileData *fontDefinition,
	const std::vector<::love::image::ImageData *> &images, float dpiScale)
{
	if (!fontDefinition || fontDefinition->getSize() == 0)
		throw ::love::Exception("BMFont descriptor is empty.");
	if (fontDefinition->getSize() > MaximumLoveDataBytes)
		throw ::love::Exception("BMFont descriptor is too large.");
	if (!std::isfinite(dpiScale) || dpiScale <= 0.0f)
		throw ::love::Exception("BMFont DPI scale must be positive and finite.");

	RasterizerUserdata rasterizer;
	rasterizer.kind = RasterizerUserdata::Kind::BMFont;
	rasterizer.runtime = _runtime;
	rasterizer.setDPIScale(dpiScale);
	std::unordered_map<int, std::string> pageFiles;
	bool unicode = false;
	int lineHeight = 0;
	int base = 0;
	std::string error;
	const std::string descriptor(static_cast<const char *>(fontDefinition->getData()),
		fontDefinition->getSize());
	std::istringstream input(descriptor);
	std::string textLine;
	while (std::getline(input, textLine))
	{
		if (!textLine.empty() && textLine.back() == '\r') textLine.pop_back();
		const auto line = parseBMFontLine(textLine);
		if (line.tag.empty()) continue;
		if (line.tag == "info")
		{
			int unicodeValue = 0;
			if (!bmFontInteger(line, "unicode", 0, unicodeValue, error))
				throw ::love::Exception("%s", error.c_str());
			unicode = unicodeValue > 0;
		}
		else if (line.tag == "common")
		{
			if (!bmFontInteger(line, "lineHeight", 0, lineHeight, error)
				|| !bmFontInteger(line, "base", 0, base, error))
				throw ::love::Exception("%s", error.c_str());
		}
		else if (line.tag == "page")
		{
			int page = 0;
			if (!bmFontInteger(line, "id", 0, page, error, true))
				throw ::love::Exception("%s", error.c_str());
			const auto filename = line.attributes.find("file");
			if (page < 0 || page > 4095 || filename == line.attributes.end()
				|| filename->second.empty())
				throw ::love::Exception("Invalid BMFont page entry.");
			pageFiles[page] = filename->second;
		}
		else if (line.tag == "char")
		{
			BMFontGlyph glyph;
			int codepoint = 0;
			if (!bmFontInteger(line, "id", 0, codepoint, error, true)
				|| !bmFontInteger(line, "x", 0, glyph.x, error, true)
				|| !bmFontInteger(line, "y", 0, glyph.y, error, true)
				|| !bmFontInteger(line, "page", 0, glyph.page, error)
				|| !bmFontInteger(line, "width", 0, glyph.width, error, true)
				|| !bmFontInteger(line, "height", 0, glyph.height, error, true)
				|| !bmFontInteger(line, "xadvance", 0, glyph.advance, error)
				|| !bmFontInteger(line, "xoffset", 0, glyph.bearingX, error))
				throw ::love::Exception("%s", error.c_str());
			int yOffset = 0;
			if (!bmFontInteger(line, "yoffset", 0, yOffset, error))
				throw ::love::Exception("%s", error.c_str());
			if (codepoint < 0 || codepoint > 0x10ffff
				|| (codepoint >= 0xd800 && codepoint <= 0xdfff)
				|| glyph.page < 0 || glyph.page > 4095 || glyph.x < 0 || glyph.y < 0
				|| glyph.width < 0 || glyph.height < 0)
				throw ::love::Exception("Invalid BMFont character entry.");
			glyph.codepoint = static_cast<std::uint32_t>(codepoint);
			glyph.bearingY = -yOffset;
			rasterizer.bmGlyphs[glyph.codepoint] = glyph;
			if (lineHeight == 0)
				rasterizer.height = std::max(rasterizer.height, glyph.height);
		}
	}
	if (rasterizer.bmGlyphs.empty())
		throw ::love::Exception("Invalid BMFont descriptor: no character definitions.");
	if (!unicode)
		for (const auto &[codepoint, glyph] : rasterizer.bmGlyphs)
		{
			(void) glyph;
			if (codepoint > 127)
				throw ::love::Exception("Invalid non-Unicode BMFont character id %u.", codepoint);
		}
	if (lineHeight > 0) rasterizer.height = lineHeight;
	rasterizer.lineHeight = rasterizer.height;
	rasterizer.ascent = base;

	std::size_t requiredPages = images.size();
	for (const auto &[page, filename] : pageFiles)
	{
		(void) filename;
		requiredPages = std::max(requiredPages, static_cast<std::size_t>(page) + 1);
	}
	for (const auto &[codepoint, glyph] : rasterizer.bmGlyphs)
	{
		(void) codepoint;
		requiredPages = std::max(requiredPages, static_cast<std::size_t>(glyph.page) + 1);
	}
	rasterizer.sourceObjects.resize(requiredPages);
	for (std::size_t index = 0; index < images.size(); ++index)
	{
		auto *image = dynamic_cast<ImageDataUserdata *>(images[index]);
		if (!image || image->getRuntime() != _runtime)
			throw ::love::Exception("BMFont page ImageData belongs to another LoveRuntime.");
		rasterizer.sourceObjects[index].set(image);
	}

	auto *imageBackend = _runtime ? _runtime->getImageBackend() : nullptr;
	auto *filesystemBackend = _runtime ? _runtime->getFilesystemBackend() : nullptr;
	const std::filesystem::path descriptorFolder =
		std::filesystem::path(fontDefinition->getFilename()).parent_path();
	for (const auto &[page, filename] : pageFiles)
	{
		auto &destination = rasterizer.sourceObjects[static_cast<std::size_t>(page)];
		if (destination) continue;
		if (!imageBackend || !filesystemBackend)
			throw ::love::Exception("love.font BMFont is not attached to Dora Content and image decoding.");
		const std::string pagePath = (descriptorFolder / filename).lexically_normal().generic_string();
		std::string resolved;
		std::string encoded;
		if (!_runtime->resolveReadPath(pagePath, resolved, error)
			|| !filesystemBackend->load(resolved, encoded, error))
			throw ::love::Exception("Content load failed for BMFont page '%s': %s",
				pagePath.c_str(), error.empty() ? "file does not exist" : error.c_str());
		int width = 0;
		int height = 0;
		std::vector<std::uint8_t> pixels;
		if (!imageBackend->decodeImage(encoded, width, height, pixels, error)
			|| width <= 0 || height <= 0 || width > MaximumWindowDimension
			|| height > MaximumWindowDimension
			|| pixels.size() != static_cast<std::size_t>(width) * height * 4)
			throw ::love::Exception("BMFont page decode failed for '%s': %s", pagePath.c_str(),
				error.empty() ? "invalid RGBA8 image" : error.c_str());
		destination.set(new ImageDataUserdata(_runtime, width, height,
			::love::PIXELFORMAT_RGBA8, pixels.data()), ::love::Acquire::NORETAIN);
	}
	for (const auto &[codepoint, glyph] : rasterizer.bmGlyphs)
	{
		auto *image = rasterizer.sourceObjects[static_cast<std::size_t>(glyph.page)].get();
		if (!image || glyph.x >= image->getWidth() || glyph.y >= image->getHeight()
			|| glyph.width > image->getWidth() - glyph.x
			|| glyph.height > image->getHeight() - glyph.y)
			throw ::love::Exception("BMFont character %u has an invalid page or rectangle.", codepoint);
	}
	return new RasterizerUserdata(std::move(rasterizer));
}

::love::font::GlyphData *DoraLoveFont::newGlyphData(
	::love::font::Rasterizer *rasterizer, const std::string &glyph)
{
	std::vector<std::uint32_t> codepoints;
	std::string error;
	if (!decodeUtf8(glyph, codepoints, error) || codepoints.empty())
		throw ::love::Exception("UTF-8 decoding error: %s",
			error.empty() ? "empty glyph" : error.c_str());
	return rasterizer->getGlyphData(codepoints.front());
}

::love::font::GlyphData *DoraLoveFont::newGlyphData(
	::love::font::Rasterizer *rasterizer, ::love::uint32 glyph)
{
	return rasterizer->getGlyphData(glyph);
}

namespace
{
VideoStreamUserdata *makeVideoStream(lua_State *luaState,
	LoveRuntime *runtime, std::string filename)
{
	if (!runtime || !runtime->getFilesystemBackend())
		luaL_error(luaState, "love.video is not attached to Dora Content");
	std::string resolved;
	std::string bytes;
	std::string error;
	if (!runtime->resolveReadPath(filename, resolved, error)
		|| !runtime->getFilesystemBackend()->load(resolved, bytes, error))
		luaL_error(luaState, "Love VideoStream '%s' load failed through Dora Content: %s",
			filename.c_str(), error.empty() ? "file is unavailable" : error.c_str());
	try
	{
		auto state = std::make_shared<VideoStreamState>();
		state->runtime = runtime;
		state->file.set(new ContentVideoFile(filename, std::move(bytes)), ::love::Acquire::NORETAIN);
		state->stream.set(new ::love::video::theora::TheoraVideoStream(state->file),
			::love::Acquire::NORETAIN);
		state->start();
		auto *result = new VideoStreamUserdata;
		result->state = std::move(state);
		return result;
	}
	catch (const ::love::Exception &exception)
	{
		luaL_error(luaState, "Love VideoStream '%s' is not valid Ogg/Theora: %s",
			filename.c_str(), exception.what());
	}
	catch (const std::exception &exception)
	{
		luaL_error(luaState, "Love VideoStream '%s' creation failed: %s",
			filename.c_str(), exception.what());
	}
	return {};
}

void pushNewVideoStream(lua_State *state, VideoStreamUserdata *stream)
{
	::love::luax_pushtype(state, stream);
	stream->release();
}

std::vector<std::uint8_t> convertVideoFrame(const ::love::video::VideoStream::Frame &frame)
{
	std::vector<std::uint8_t> rgba(static_cast<std::size_t>(frame.yw) * frame.yh * 4);
	for (int y = 0; y < frame.yh; ++y)
	for (int x = 0; x < frame.yw; ++x)
	{
		const int chromaX = x * frame.cw / frame.yw;
		const int chromaY = y * frame.ch / frame.yh;
		const int luminance = static_cast<int>(frame.yplane[y * frame.yw + x]) - 16;
		const int blueDifference = static_cast<int>(frame.cbplane[chromaY * frame.cw + chromaX]) - 128;
		const int redDifference = static_cast<int>(frame.crplane[chromaY * frame.cw + chromaX]) - 128;
		const int scaled = std::max(0, luminance) * 298;
		const auto clampByte = [](int value) {
			return static_cast<std::uint8_t>(std::clamp(value, 0, 255));
		};
		const std::size_t offset = (static_cast<std::size_t>(y) * frame.yw + x) * 4;
		rgba[offset] = clampByte((scaled + 409 * redDifference + 128) >> 8);
		rgba[offset + 1] = clampByte((scaled - 100 * blueDifference - 208 * redDifference + 128) >> 8);
		rgba[offset + 2] = clampByte((scaled + 516 * blueDifference + 128) >> 8);
		rgba[offset + 3] = 255;
	}
	return rgba;
}
} // namespace

int LoveRuntime::videoNewVideoStream(lua_State *state)
{
	auto *runtime = runtimeFromUpvalue(state);
	const std::string filename = luaL_checkstring(state, 1);
	pushNewVideoStream(state, makeVideoStream(state, runtime, filename));
	return 1;
}

void LoveRuntime::registerImageType()
{
	// Love's Image wrapper installs the inherited Texture API directly on the
	// Image metatable. Canvas still uses the existing Dora adapter until its
	// own Texture migration, so avoid registering a competing standalone
	// Texture metatable here.
	::love::graphics::luaopen_image(_state);
}

void LoveRuntime::registerCanvasType()
{
	::love::graphics::luaopen_canvas(_state);
}

void LoveRuntime::registerCompressedImageDataType()
{
	::love::image::luaopen_compressedimagedata(_state);
}

void LoveRuntime::registerQuadType()
{
	::love::graphics::luaopen_quad(_state);
}

void LoveRuntime::registerMeshType()
{
	::love::graphics::luaopen_mesh(_state);
}

void LoveRuntime::registerSpriteBatchType()
{
	::love::graphics::luaopen_spritebatch(_state);
}

void LoveRuntime::registerParticleSystemType()
{
	::love::graphics::luaopen_particlesystem(_state);
}

void LoveRuntime::registerTextType()
{
	::love::graphics::luaopen_text(_state);
}

void LoveRuntime::registerShaderType()
{
	::love::graphics::luaopen_shader(_state);
}

void LoveRuntime::registerFontType()
{
	::love::graphics::luaopen_font(_state);
}

void LoveRuntime::registerAudioSourceType()
{
	::love::audio::luaopen_source(_state);
	::love::luax_gettypemetatable(_state, AudioSourceUserdata::type);
	lua_pushcfunction(_state, audioSourceEqual);
	lua_setfield(_state, -2, "__eq");
	lua_pop(_state, 1);
}

void LoveRuntime::registerVideoTypes()
{
	::love::video::luaopen_videostream(_state);
	::love::graphics::luaopen_video(_state);
}

void LoveRuntime::registerRecordingDeviceType()
{
	static const luaL_Reg functions[] = {
			{"start", recordingDeviceStart},
			{"stop", recordingDeviceStop},
			{"getData", recordingDeviceGetData},
			{"getSampleCount", recordingDeviceGetSampleCount},
			{"getSampleRate", recordingDeviceGetSampleRate},
			{"getBitDepth", recordingDeviceGetBitDepth},
			{"getChannelCount", recordingDeviceGetChannelCount},
			{"getName", recordingDeviceGetName},
			{"isRecording", recordingDeviceIsRecording},
			{nullptr, nullptr},
		};
	::love::luax_register_type(_state, &RecordingDeviceUserdata::type, functions, nullptr);
	::love::luax_gettypemetatable(_state, RecordingDeviceUserdata::type);
	lua_pushcfunction(_state, recordingDeviceEqual);
	lua_setfield(_state, -2, "__eq");
	lua_pop(_state, 1);
}

void LoveRuntime::registerThreadTypes()
{
	::love::thread::luaopen_thread(_state);
	::love::thread::luaopen_channel(_state);
}

void LoveRuntime::registerPhysicsTypes()
{
	::love::physics::luaopen_world(_state);
	::love::physics::luaopen_body(_state);
	::love::physics::luaopen_contact(_state);
	::love::physics::luaopen_fixture(_state);
	::love::physics::luaopen_shape(_state);
	::love::physics::luaopen_joint(_state);
	struct PhysicsTypeOverride {
		::love::Type *type;
		lua_CFunction typeFunction;
		lua_CFunction typeOfFunction;
	};
	for (const auto &[type, typeFunction, typeOfFunction] : {
		PhysicsTypeOverride{&::love::physics::Shape::type, physicsShapeObjectType, physicsShapeObjectTypeOf},
		PhysicsTypeOverride{&::love::physics::Joint::type, physicsJointObjectType, physicsJointObjectTypeOf},
	})
	{
		::love::luax_gettypemetatable(_state, *type);
		lua_pushcfunction(_state, typeFunction); lua_setfield(_state, -2, "type");
		lua_pushcfunction(_state, typeOfFunction); lua_setfield(_state, -2, "typeOf");
		lua_pop(_state, 1);
	}
}

void LoveRuntime::resetGraphicsTransform() noexcept
{
	_graphicsTransform = {};
}

void LoveRuntime::multiplyGraphicsTransform(float a, float b, float c, float d, float tx, float ty) noexcept
{
	const GraphicsTransform current = _graphicsTransform;
	_graphicsTransform.a = current.a * a + current.c * b;
	_graphicsTransform.b = current.b * a + current.d * b;
	_graphicsTransform.c = current.a * c + current.c * d;
	_graphicsTransform.d = current.b * c + current.d * d;
	_graphicsTransform.tx = current.a * tx + current.c * ty + current.tx;
	_graphicsTransform.ty = current.b * tx + current.d * ty + current.ty;
}

std::vector<float> LoveRuntime::transformGraphicsPoints(const std::vector<float> &points) const
{
	std::vector<float> transformed;
	transformed.reserve(points.size());
	for (std::size_t i = 0; i < points.size(); i += 2)
	{
		const float x = points[i];
		const float y = points[i + 1];
		transformed.push_back(_graphicsTransform.a * x + _graphicsTransform.c * y + _graphicsTransform.tx);
		transformed.push_back(_graphicsTransform.b * x + _graphicsTransform.d * y + _graphicsTransform.ty);
	}
	return transformed;
}

bool LoveRuntime::isGraphicsTransformIdentity() const noexcept
{
	return _graphicsTransform.a == 1.0f && _graphicsTransform.b == 0.0f
		&& _graphicsTransform.c == 0.0f && _graphicsTransform.d == 1.0f
		&& _graphicsTransform.tx == 0.0f && _graphicsTransform.ty == 0.0f
		&& _graphicsTransform.pixelScale == 1.0f;
}

void LoveRuntime::registerLoveModule()
{
	initializeLoveFloatTypes();
	lua_newtable(_state);
	lua_pushliteral(_state, "11.5");
	lua_setfield(_state, -2, "_version");
	lua_pushinteger(_state, 11);
	lua_setfield(_state, -2, "_version_major");
	lua_pushinteger(_state, 5);
	lua_setfield(_state, -2, "_version_minor");
	lua_pushinteger(_state, 0);
	lua_setfield(_state, -2, "_version_revision");
	lua_pushcfunction(_state, loveRun);
	lua_setfield(_state, -2, "run");
	lua_pushcfunction(_state, loveGetVersion);
	lua_setfield(_state, -2, "getVersion");

	lua_newtable(_state);
	static constexpr std::array<const char *, 31> HandlerNames = {
		"directorydropped", "displayrotated", "filedropped", "focus", "gamepadaxis",
		"gamepadpressed", "gamepadreleased", "joystickadded", "joystickaxis",
		"joystickhat", "joystickpressed", "joystickreleased", "joystickremoved",
		"keypressed", "keyreleased", "lowmemory", "mousefocus", "mousemoved",
		"mousepressed", "mousereleased", "quit", "resize", "textedited", "textinput",
		"threaderror", "touchmoved", "touchpressed", "touchreleased", "visible",
		"wheelmoved", "localechanged"};
	for (const auto *name : HandlerNames)
	{
		lua_pushstring(_state, name);
		lua_pushcclosure(_state, loveHandler, 1);
		lua_setfield(_state, -2, name);
	}
	lua_setfield(_state, -2, "handlers");

	// Graphics is a real state-local Love module even while its public wrapper
	// migration is being completed in slices. The module owns no window,
	// swapchain, present loop, or renderer; those remain in the injected Dora
	// GraphicsBackend. Future upstream wrappers resolve this adapter through the
	// current state's REGISTRY_MODULES instead of Module::instances[].
	lua_pushvalue(_state, -1);
	lua_setglobal(_state, "love");
	auto *graphicsModule = new DoraLoveGraphics(this);
	const ::love::WrappedModule wrappedGraphics = {
		graphicsModule, "graphics", &DoraLoveGraphics::type, nullptr, nullptr,
	};
	::love::luax_register_module(_state, wrappedGraphics);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} graphicsFunctions[] = {
		{"clear", ::love::graphics::w_clear},
		{"discard", ::love::graphics::w_discard},
		{"flushBatch", ::love::graphics::w_flushBatch},
		{"setBackgroundColor", ::love::graphics::w_setBackgroundColor},
		{"getBackgroundColor", ::love::graphics::w_getBackgroundColor},
		{"setDefaultFilter", ::love::graphics::w_setDefaultFilter},
		{"getDefaultFilter", ::love::graphics::w_getDefaultFilter},
		{"setDefaultMipmapFilter", ::love::graphics::w_setDefaultMipmapFilter},
		{"getDefaultMipmapFilter", ::love::graphics::w_getDefaultMipmapFilter},
		{"setColor", ::love::graphics::w_setColor},
		{"getColor", ::love::graphics::w_getColor},
		{"setLineWidth", ::love::graphics::w_setLineWidth},
		{"getLineWidth", ::love::graphics::w_getLineWidth},
		{"setLineStyle", ::love::graphics::w_setLineStyle},
		{"getLineStyle", ::love::graphics::w_getLineStyle},
		{"setLineJoin", ::love::graphics::w_setLineJoin},
		{"getLineJoin", ::love::graphics::w_getLineJoin},
		{"setWireframe", ::love::graphics::w_setWireframe},
		{"isWireframe", ::love::graphics::w_isWireframe},
		{"setPointSize", ::love::graphics::w_setPointSize},
		{"getPointSize", ::love::graphics::w_getPointSize},
		{"getDimensions", ::love::graphics::w_getDimensions},
		{"getWidth", ::love::graphics::w_getWidth},
		{"getHeight", ::love::graphics::w_getHeight},
		{"getPixelDimensions", ::love::graphics::w_getPixelDimensions},
		{"getPixelWidth", ::love::graphics::w_getPixelWidth},
		{"getPixelHeight", ::love::graphics::w_getPixelHeight},
		{"getDPIScale", ::love::graphics::w_getDPIScale},
		{"getSupported", ::love::graphics::w_getSupported},
		{"getTextureTypes", ::love::graphics::w_getTextureTypes},
		{"getImageFormats", ::love::graphics::w_getImageFormats},
		{"getTextureFormats", ::love::graphics::w_getTextureFormats},
		{"getRendererInfo", ::love::graphics::w_getRendererInfo},
		{"getSystemLimits", ::love::graphics::w_getSystemLimits},
		{"getStats", ::love::graphics::w_getStats},
		{"captureScreenshot", ::love::graphics::w_captureScreenshot},
		{"rectangle", ::love::graphics::w_rectangle},
		{"circle", ::love::graphics::w_circle},
		{"arc", ::love::graphics::w_arc},
		{"line", ::love::graphics::w_line},
		{"ellipse", ::love::graphics::w_ellipse},
		{"polygon", ::love::graphics::w_polygon},
		{"points", ::love::graphics::w_points},
		{"present", ::love::graphics::w_present},
		{"push", ::love::graphics::w_push},
		{"pop", ::love::graphics::w_pop},
		{"getStackDepth", ::love::graphics::w_getStackDepth},
		{"origin", ::love::graphics::w_origin},
		{"translate", ::love::graphics::w_translate},
		{"rotate", ::love::graphics::w_rotate},
		{"scale", ::love::graphics::w_scale},
		{"shear", ::love::graphics::w_shear},
		{"applyTransform", ::love::graphics::w_applyTransform},
		{"replaceTransform", ::love::graphics::w_replaceTransform},
		{"transformPoint", ::love::graphics::w_transformPoint},
		{"inverseTransformPoint", ::love::graphics::w_inverseTransformPoint},
		{"isActive", ::love::graphics::w_isActive},
		{"isCreated", ::love::graphics::w_isCreated},
		{"isGammaCorrect", ::love::graphics::w_isGammaCorrect},
		{"reset", ::love::graphics::w_reset},
		{"newImage", ::love::graphics::w_newImage},
		{"_newVideo", ::love::graphics::w_newVideo},
		{"newArrayImage", ::love::graphics::w_newArrayImage},
		{"newCubeImage", ::love::graphics::w_newCubeImage},
		{"newVolumeImage", ::love::graphics::w_newVolumeImage},
		{"newCanvas", ::love::graphics::w_newCanvas},
		{"getCanvasFormats", ::love::graphics::w_getCanvasFormats},
		{"setCanvas", ::love::graphics::w_setCanvas},
		{"getCanvas", ::love::graphics::w_getCanvas},
		{"newQuad", ::love::graphics::w_newQuad},
		{"newMesh", ::love::graphics::w_newMesh},
		{"newSpriteBatch", ::love::graphics::w_newSpriteBatch},
		{"newParticleSystem", ::love::graphics::w_newParticleSystem},
		{"newText", ::love::graphics::w_newText},
		{"newTextBatch", ::love::graphics::w_newText},
		{"newShader", ::love::graphics::w_newShader},
		{"validateShader", ::love::graphics::w_validateShader},
		{"setShader", ::love::graphics::w_setShader},
		{"getShader", ::love::graphics::w_getShader},
		{"draw", ::love::graphics::w_draw},
		{"drawLayer", ::love::graphics::w_drawLayer},
		{"newFont", ::love::graphics::w_newFont},
		{"setNewFont", ::love::graphics::w_setNewFont},
		{"newImageFont", ::love::graphics::w_newImageFont},
		{"setFont", ::love::graphics::w_setFont},
		{"getFont", ::love::graphics::w_getFont},
		{"print", ::love::graphics::w_print},
		{"printf", ::love::graphics::w_printf},
		{"setBlendMode", ::love::graphics::w_setBlendMode},
		{"getBlendMode", ::love::graphics::w_getBlendMode},
		{"setScissor", ::love::graphics::w_setScissor},
		{"getScissor", ::love::graphics::w_getScissor},
		{"intersectScissor", ::love::graphics::w_intersectScissor},
		{"setColorMask", ::love::graphics::w_setColorMask},
		{"getColorMask", ::love::graphics::w_getColorMask},
		{"setDepthMode", ::love::graphics::w_setDepthMode},
		{"getDepthMode", ::love::graphics::w_getDepthMode},
		{"setMeshCullMode", ::love::graphics::w_setMeshCullMode},
		{"getMeshCullMode", ::love::graphics::w_getMeshCullMode},
		{"setFrontFaceWinding", ::love::graphics::w_setFrontFaceWinding},
		{"getFrontFaceWinding", ::love::graphics::w_getFrontFaceWinding},
		{"stencil", ::love::graphics::w_stencil},
		{"setStencilTest", ::love::graphics::w_setStencilTest},
		{"getStencilTest", ::love::graphics::w_getStencilTest},
		{"setStencilMode", ::love::graphics::w_setStencilMode},
		{"getStencilMode", ::love::graphics::w_getStencilMode},
		{"drawInstanced", ::love::graphics::w_drawInstanced},
	};
	for (const auto &entry : graphicsFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_pop(_state, 1); // state-local graphics module table
	::love::graphics::installVideoConstructorWrapper(_state);

	// Upstream module wrappers resolve and populate the process-visible `love`
	// table while they open. Publish this same table before the first wrapper so
	// its state-local module registry remains reachable after initialization.
	::love::image::luaopen_love_image(_state);
	lua_pushnil(_state);
	lua_setfield(_state, -2, "newCubeFaces");
	lua_setfield(_state, -2, "image");
	::love::data::luaopen_love_data(_state);
	lua_setfield(_state, -2, "data");
	::love::image::luaopen_imagedata(_state);
	::love::math::luaopen_love_math(_state);
	lua_setfield(_state, -2, "math");

	::love::filesystem::luaopen_love_filesystem(_state);
	for (const char *internal : {"init", "setFused", "setSource", "_setAndroidSaveExternal", "setSymlinksEnabled",
		"areSymlinksEnabled", "getCRequirePath", "setCRequirePath"})
	{
		lua_pushnil(_state);
		lua_setfield(_state, -2, internal);
	}
	// Keep Dora's generated-source map and Lua 5.5 bytecode diagnostics at the
	// chunk boundary while all other argument and object handling comes from
	// the upstream filesystem wrapper.
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, filesystemLoad, 1);
	lua_setfield(_state, -2, "load");
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, filesystemSetRequirePath, 1);
	lua_setfield(_state, -2, "setRequirePath");
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, filesystemSetIdentity, 1);
	lua_setfield(_state, -2, "setIdentity");
	lua_setfield(_state, -2, "filesystem");

	::love::font::luaopen_love_font(_state);
	lua_setfield(_state, -2, "font");

	::love::sound::luaopen_love_sound(_state);
	lua_setfield(_state, -2, "sound");

	::love::window::luaopen_love_window(_state);
	for (const auto &[name, function] : std::initializer_list<std::pair<const char *, lua_CFunction>> {
		{"getWidth", ::love::graphics::w_getWidth},
		{"getHeight", ::love::graphics::w_getHeight},
		{"getDimensions", ::love::graphics::w_getDimensions},
	})
	{
		lua_pushcfunction(_state, function);
		lua_setfield(_state, -2, name);
	}
	lua_setfield(_state, -2, "window");

	::love::event::luaopen_love_event(_state);
	lua_setfield(_state, -2, "event");

	::love::keyboard::luaopen_love_keyboard(_state);
	lua_setfield(_state, -2, "keyboard");

	::love::mouse::luaopen_love_mouse(_state);
	lua_setfield(_state, -2, "mouse");

	::love::touch::luaopen_love_touch(_state);
	lua_setfield(_state, -2, "touch");

	::love::joystick::luaopen_love_joystick(_state);
	lua_setfield(_state, -2, "joystick");

	::love::timer::luaopen_love_timer(_state);
	lua_setfield(_state, -2, "timer");

	lua_newtable(_state);
	const struct
	{
		const char *name;
		lua_CFunction function;
	} audioFunctions[] = {
		{"newSource", audioNewSource},
		{"newQueueableSource", audioNewQueueableSource},
		{"play", audioPlay},
		{"pause", audioPause},
		{"stop", audioStop},
		{"getActiveSourceCount", audioGetActiveSourceCount},
		{"getSourceCount", audioGetActiveSourceCount},
		{"setVolume", audioSetVolume},
		{"getVolume", audioGetVolume},
		{"setMixWithSystem", audioSetMixWithSystem},
		{"setPosition", audioSetPosition},
		{"getPosition", audioGetPosition},
		{"setOrientation", audioSetOrientation},
		{"getOrientation", audioGetOrientation},
		{"setVelocity", audioSetVelocity},
		{"getVelocity", audioGetVelocity},
		{"setDopplerScale", audioSetDopplerScale},
		{"getDopplerScale", audioGetDopplerScale},
		{"setDistanceModel", audioSetDistanceModel},
		{"getDistanceModel", audioGetDistanceModel},
		{"setEffect", audioSetEffect},
		{"getEffect", audioGetEffect},
		{"getActiveEffects", audioGetActiveEffects},
		{"getMaxSceneEffects", audioGetMaxSceneEffects},
		{"getMaxSourceEffects", audioGetMaxSourceEffects},
		{"getRecordingDevices", audioGetRecordingDevices},
		{"isEffectsSupported", audioIsEffectsSupported},
	};
	for (const auto &entry : audioFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "audio");

	lua_newtable(_state);
	lua_pushlightuserdata(_state, this);
	lua_pushcclosure(_state, videoNewVideoStream, 1);
	lua_setfield(_state, -2, "newVideoStream");
	lua_setfield(_state, -2, "video");

	::love::system::luaopen_love_system(_state);
	lua_setfield(_state, -2, "system");

	::love::thread::luaopen_love_thread(_state);
	lua_setfield(_state, -2, "thread");

	lua_newtable(_state);
	const struct { const char *name; lua_CFunction function; } physicsFunctions[] = {
		{"setMeter", physicsSetMeter}, {"getMeter", physicsGetMeter},
		{"getDistance", physicsGetDistance},
		{"newWorld", physicsNewWorld}, {"newBody", physicsNewBody},
		{"newFixture", physicsNewFixture}, {"newCircleShape", physicsNewCircleShape},
		{"newRectangleShape", physicsNewRectangleShape}, {"newPolygonShape", physicsNewPolygonShape},
		{"newEdgeShape", physicsNewEdgeShape}, {"newChainShape", physicsNewChainShape},
		{"newDistanceJoint", physicsNewDistanceJoint},
		{"newRevoluteJoint", physicsNewRevoluteJoint},
		{"newPrismaticJoint", physicsNewPrismaticJoint},
		{"newWeldJoint", physicsNewWeldJoint},
		{"newFrictionJoint", physicsNewFrictionJoint},
		{"newRopeJoint", physicsNewRopeJoint},
		{"newPulleyJoint", physicsNewPulleyJoint},
		{"newWheelJoint", physicsNewWheelJoint},
		{"newMouseJoint", physicsNewMouseJoint},
		{"newMotorJoint", physicsNewMotorJoint},
		{"newGearJoint", physicsNewGearJoint},
	};
	for (const auto &entry : physicsFunctions)
	{
		lua_pushlightuserdata(_state, this);
		lua_pushcclosure(_state, entry.function, 1);
		lua_setfield(_state, -2, entry.name);
	}
	lua_setfield(_state, -2, "physics");
	lua_setglobal(_state, "love");

	luaL_getsubtable(_state, LUA_REGISTRYINDEX, LUA_PRELOAD_TABLE);
	lua_pushcfunction(_state, openLoveModule);
	lua_setfield(_state, -2, "love");
	lua_pushcfunction(_state, openLoveGraphicsModule);
	lua_setfield(_state, -2, "love.graphics");
	lua_pushcfunction(_state, openLoveImageModule);
	lua_setfield(_state, -2, "love.image");
	lua_pushcfunction(_state, openLoveFontModule);
	lua_setfield(_state, -2, "love.font");
	lua_pushcfunction(_state, openLoveSoundModule);
	lua_setfield(_state, -2, "love.sound");
	lua_pushcfunction(_state, openLoveMathModule);
	lua_setfield(_state, -2, "love.math");
	lua_pushcfunction(_state, openLoveDataModule);
	lua_setfield(_state, -2, "love.data");
	lua_pushcfunction(_state, openLoveWindowModule);
	lua_setfield(_state, -2, "love.window");
	lua_pushcfunction(_state, openLoveEventModule);
	lua_setfield(_state, -2, "love.event");
	lua_pushcfunction(_state, openLoveFilesystemModule);
	lua_setfield(_state, -2, "love.filesystem");
	lua_pushcfunction(_state, openLoveKeyboardModule);
	lua_setfield(_state, -2, "love.keyboard");
	lua_pushcfunction(_state, openLoveMouseModule);
	lua_setfield(_state, -2, "love.mouse");
	lua_pushcfunction(_state, openLoveTouchModule);
	lua_setfield(_state, -2, "love.touch");
	lua_pushcfunction(_state, openLoveJoystickModule);
	lua_setfield(_state, -2, "love.joystick");
	lua_pushcfunction(_state, openLoveTimerModule);
	lua_setfield(_state, -2, "love.timer");
	lua_pushcfunction(_state, openLoveAudioModule);
	lua_setfield(_state, -2, "love.audio");
	lua_pushcfunction(_state, openLoveVideoModule);
	lua_setfield(_state, -2, "love.video");
	lua_pushcfunction(_state, openLoveSystemModule);
	lua_setfield(_state, -2, "love.system");
	lua_pushcfunction(_state, openLoveThreadModule);
	lua_setfield(_state, -2, "love.thread");
	lua_pushcfunction(_state, openLovePhysicsModule);
	lua_setfield(_state, -2, "love.physics");
	lua_pop(_state, 1);
}
