/// <summary>
/// An array data structure that supports various operations.
/// </summary>
object class Array
{
	/// <summary>
	/// The number of items in the array.
	/// </summary>
	readonly common size_t count;
	/// <summary>
	/// Whether the array is empty or not.
	/// </summary>
	readonly boolean bool empty;
	/// <summary>
	/// Adds all items from another array to the end of this array.
	/// </summary>
	/// <param name="other">Another array object.</param>
	void addRange(Array* other);
	/// <summary>
	/// Removes all items from this array that are also in another array.
	/// </summary>
	/// <param name="other">Another array object.</param>
	void removeFrom(Array* other);
	/// <summary>
	/// Removes all items from the array.
	/// </summary>
	void clear();
	/// <summary>
	/// Reverses the order of the items in the array.
	/// </summary>
	void reverse();
	/// <summary>
	/// Removes any empty slots from the end of the array.
	/// This method is used to release the unused memory this array holds.
	/// </summary>
	void shrink();
	/// <summary>
	/// Swaps the items at two given indices.
	/// </summary>
	/// <param name="indexA">The first index.</param>
	/// <param name="indexB">The second index.</param>
	void swap(int indexA, int indexB);
	/// <summary>
	/// Removes the item at the given index.
	/// </summary>
	/// <param name="index">The index to remove.</param>
	/// <returns>`true` if an item was removed, `false` otherwise.</returns>
	bool removeAt(int index);
	/// <summary>
	/// Removes the item at the given index without preserving the order of the array.
	/// </summary>
	/// <param name="index">The index to remove.</param>
	/// <returns>`true` if an item was removed, `false` otherwise.</returns>
	bool fastRemoveAt(int index);
	/// <summary>
	/// Creates a new array object
	/// </summary>
	static Array* create();
};

/// <summary>
/// A struct for storing pairs of string keys and various values.
/// </summary>
object class Dictionary
{
	/// <summary>
	/// The number of items in the dictionary.
	/// </summary>
	readonly common int count;
	/// <summary>
	/// The keys of the items in the dictionary.
	/// </summary>
	readonly common VecStr keys;
	/// <summary>
	/// Removes all the items from the dictionary.
	/// </summary>
	void clear();
	/// <summary>
	/// Creates instance of the "Dictionary".
	/// </summary>
	static Dictionary* create();
};

/// <summary>
/// A rectangle object with a left-bottom origin position and a size.
/// </summary>
value struct Rect
{
	/// <summary>
	/// The position of the origin of the rectangle.
	/// </summary>
	Vec2 origin;
	/// <summary>
	/// The dimensions of the rectangle.
	/// </summary>
	Size size;
	/// <summary>
	/// The x-coordinate of the origin of the rectangle.
	/// </summary>
	common float x;
	/// <summary>
	/// The y-coordinate of the origin of the rectangle.
	/// </summary>
	common float y;
	/// <summary>
	/// The width of the rectangle.
	/// </summary>
	common float width;
	/// <summary>
	/// The height of the rectangle.
	/// </summary>
	common float height;
	/// <summary>
	/// The left edge in x-axis of the rectangle.
	/// </summary>
	common float left;
	/// <summary>
	/// The right edge in x-axis of the rectangle.
	/// </summary>
	common float right;
	/// <summary>
	/// The x-coordinate of the center of the rectangle.
	/// </summary>
	common float centerX;
	/// <summary>
	/// The y-coordinate of the center of the rectangle.
	/// </summary>
	common float centerY;
	/// <summary>
	/// The bottom edge in y-axis of the rectangle.
	/// </summary>
	common float bottom;
	/// <summary>
	/// The top edge in y-axis of the rectangle.
	/// </summary>
	common float top;
	/// <summary>
	/// The lower bound (left-bottom) of the rectangle.
	/// </summary>
	common Vec2 lowerBound;
	/// <summary>
	/// The upper bound (right-top) of the rectangle.
	/// </summary>
	common Vec2 upperBound;
	/// <summary>
	/// Sets the properties of the rectangle.
	/// </summary>
	/// <param name="x">The x-coordinate of the origin of the rectangle.</param>
	/// <param name="y">The y-coordinate of the origin of the rectangle.</param>
	/// <param name="width">The width of the rectangle.</param>
	/// <param name="height">The height of the rectangle.</param>
	void set(float x, float y, float width, float height);
	/// <summary>
	/// Checks if a point is inside the rectangle.
	/// </summary>
	/// <param name="point">The point to check, represented by a Vec2 object.</param>
	/// <returns>Whether or not the point is inside the rectangle.</returns>
	bool containsPoint(Vec2 point) const;
	/// <summary>
	/// Checks if the rectangle intersects with another rectangle.
	/// </summary>
	/// <param name="rect">The other rectangle to check for intersection with, represented by a Rect object.</param>
	/// <returns>Whether or not the rectangles intersect.</returns>
	bool intersectsRect(Rect rect) const;
	/// <summary>
	/// Checks if two rectangles are equal.
	/// </summary>
	/// <param name="other">The other rectangle to compare to, represented by a Rect object.</param>
	/// <returns>Whether or not the two rectangles are equal.</returns>
	bool operator== @ equals(Rect other) const;
	/// <summary>
	/// Creates a new rectangle object using a Vec2 object for the origin and a Size object for the size.
	/// </summary>
	/// <param name="origin">The origin of the rectangle, represented by a Vec2 object.</param>
	/// <param name="size">The size of the rectangle, represented by a Size object.</param>
	/// <returns>A new rectangle object.</returns>
	static Rect create(Vec2 origin, Size size);
	/// <summary>
	/// Gets a rectangle object with all properties set to 0.
	/// </summary>
	static outside Rect Rect_GetZero @ zero();
};

/// <summary>
/// A struct representing an application.
/// </summary>
singleton class Application @ App
{
	/// <summary>
	/// The current passed frame number.
	/// </summary>
	readonly common uint32_t frame;
	/// <summary>
	/// The size of the main frame buffer texture used for rendering.
	/// </summary>
	readonly common Size bufferSize;
	/// <summary>
	/// The logic visual size of the screen.
	/// The visual size only changes when application window size changes.
	/// And it won't be affacted by the view buffer scaling factor.
	/// </summary>
	readonly common Size visualSize;
	/// <summary>
	/// The ratio of the pixel density displayed by the device
	/// Can be calculated as the size of the rendering buffer divided by the size of the application window.
	/// </summary>
	readonly common float devicePixelRatio;
	/// <summary>
	/// The platform the game engine is running on.
	/// </summary>
	readonly common string platform;
	/// <summary>
	/// The version string of the game engine.
	/// Should be in format of "v0.0.0".
	/// </summary>
	readonly common string version;
	/// <summary>
	/// The dependencies of the game engine.
	/// </summary>
	readonly common string deps;
	/// <summary>
	/// The time in seconds since the last frame update.
	/// </summary>
	readonly common double deltaTime;
	/// <summary>
	/// The elapsed time since current frame was started, in seconds.
	/// </summary>
	readonly common double elapsedTime;
	/// <summary>
	/// The total time the game engine has been running until last frame ended, in seconds.
	/// Should be a contant number when invoked in a same frame for multiple times.
	/// </summary>
	readonly common double totalTime;
	/// <summary>
	/// The total time the game engine has been running until this field being accessed, in seconds.
	/// Should be a increasing number when invoked in a same frame for multiple times.
	/// </summary>
	readonly common double runningTime;
	/// <summary>
	/// A random number generated by a random number engine based on Mersenne Twister algorithm.
	/// So that the random number generated by a same seed should be consistent on every platform.
	/// </summary>
	readonly common uint64_t rand;
	/// <summary>
	/// The maximum valid frames per second the game engine is allowed to run at.
	/// The max FPS is being inferred by the device screen max refresh rate.
	/// </summary>
	readonly common uint32_t maxFPS @ max_fps;
	/// <summary>
	/// Whether the game engine is running in debug mode.
	/// </summary>
	readonly boolean bool debugging;
	/// <summary>
	/// The system locale string, in format like: `zh-Hans`, `en`.
	/// </summary>
	common string locale;
	/// <summary>
	/// The theme color for Dora SSR.
	/// </summary>
	common Color themeColor;
	/// <summary>
	/// The random number seed.
	/// </summary>
	common uint32_t seed;
	/// <summary>
	/// The target frames per second the game engine is supposed to run at.
	/// Only works when `fpsLimited` is set to true.
	/// </summary>
	common uint32_t targetFPS @ target_fps;
	/// <summary>
	/// The application window size.
	/// May differ from visual size due to the different DPIs of display devices.
	/// It is not available to set this property on platform Android and iOS.
	/// </summary>
	common Size winSize;
	/// <summary>
	/// The application window position.
	/// It is not available to set this property on platform Android and iOS.
	/// </summary>
	common Vec2 winPosition;
	/// <summary>
	/// Whether the game engine is limiting the frames per second.
	/// Set `fpsLimited` to true, will make engine run in a busy loop to track the  precise frame time to switch to the next frame. And this behavior can lead to 100% CPU usage. This is usually common practice on Windows PCs for better CPU usage occupation. But it also results in extra heat and power consumption.
	/// </summary>
	boolean bool fPSLimited @ fpsLimited;
	/// <summary>
	/// Whether the game engine is currently idled.
	/// Set `idled` to true, will make game logic thread use a sleep time and going idled for next frame to come. Due to the imprecision in sleep time. This idled state may cause game engine over slept for a few frames to lost.
	/// `idled` state can reduce some CPU usage.
	/// </summary>
	boolean bool idled;
	/// <summary>
	/// Whether the game engine is running in full screen mode.
	/// It is not available to set this property on platform Android and iOS.
	/// </summary>
	boolean bool fullScreen;
	/// <summary>
	/// Whether the game engine window is always on top. Default is true.
	/// It is not available to set this property on platform Android and iOS.
	/// </summary>
	boolean bool alwaysOnTop;
	/// <summary>
	/// Shuts down the game engine.
	/// It is not working and acts as a dummy function for platform Android and iOS to follow the specification of how mobile platform applications should operate.
	/// </summary>
	void shutdown();
};

/// <summary>
/// A struct representing an entity for an ECS game system.
/// </summary>
object class Entity
{
	/// <summary>
	/// The number of all running entities.
	/// </summary>
	static readonly common uint32_t count;
	/// <summary>
	/// The index of the entity.
	/// </summary>
	readonly common int index;
	/// <summary>
	/// Clears all entities.
	/// </summary>
	static void clear();
	/// <summary>
	/// Removes a property of the entity.
	/// This function will trigger events for Observer objects.
	/// </summary>
	/// <param name="key">The name of the property to remove.</param>
	void remove(string key);
	/// <summary>
	/// Destroys the entity.
	/// </summary>
	void destroy();
	/// <summary>
	/// Creates a new entity.
	/// </summary>
	static Entity* create();
};

/// <summary>
/// A struct representing a group of entities in the ECS game systems.
/// </summary>
object class EntityGroup @ Group
{
	/// <summary>
	/// The number of entities in the group.
	/// </summary>
	readonly common int count;
	/// <summary>
	/// The first entity in the group.
	/// </summary>
	optional readonly common Entity* first;
	/// <summary>
	/// Finds the first entity in the group that satisfies a predicate function.
	/// </summary>
	/// <param name="predicate">The predicate function to test each entity with.</param>
	/// <returns>The first entity that satisfies the predicate, or None if no entity does.</returns>
	optional Entity* find(function<def_false bool(Entity* e)> predicate) const;
	/// <summary>
	/// A method that creates a new group with the specified component names.
	/// </summary>
	/// <param name="components">A vector listing the names of the components to include in the group.</param>
	/// <returns>The new group.</returns>
	static EntityGroup* create(VecStr components);
};

/// <summary>
/// A struct representing an observer of entity changes in the game systems.
/// </summary>
object class EntityObserver @ Observer
{
	/// <summary>
	/// A method that creates a new observer with the specified component filter and action to watch for.
	/// </summary>
	/// <param name="event_">The type of event to watch for.</param>
	/// <param name="components">A vector listing the names of the components to filter entities by.</param>
	/// <returns>The new observer.</returns>
	static EntityObserver* create(EntityEvent event_, VecStr components);
};

/// <summary>
/// Helper struct for file path operations.
/// </summary>
singleton struct Path
{
	/// <summary>
	/// Extracts the file extension from a given file path.
	/// # Example
	/// Input: "/a/b/c.TXT" Output: "txt"
	/// </summary>
	/// <param name="path">The input file path.</param>
	/// <returns>The extension of the input file.</returns>
	static string getExt(string path);
	/// <summary>
	/// Extracts the parent path from a given file path.
	/// # Example
	/// Input: "/a/b/c.TXT" Output: "/a/b"
	/// </summary>
	/// <param name="path">The input file path.</param>
	/// <returns>The parent path of the input file.</returns>
	static string getPath(string path);
	/// <summary>
	/// Extracts the file name without extension from a given file path.
	/// # Example
	/// Input: "/a/b/c.TXT" Output: "c"
	/// </summary>
	/// <param name="path">The input file path.</param>
	/// <returns>The name of the input file without extension.</returns>
	static string getName(string path);
	/// <summary>
	/// Extracts the file name from a given file path.
	/// # Example
	/// Input: "/a/b/c.TXT" Output: "c.TXT"
	/// </summary>
	/// <param name="path">The input file path.</param>
	/// <returns>The name of the input file.</returns>
	static string getFilename(string path);
	/// <summary>
	/// Computes the relative path from the target file to the input file.
	/// # Example
	/// Input: "/a/b/c.TXT", target: "/a" Output: "b/c.TXT"
	/// </summary>
	/// <param name="path">The input file path.</param>
	/// <param name="target">The target file path.</param>
	/// <returns>The relative path from the input file to the target file.</returns>
	static string getRelative(string path, string target);
	/// <summary>
	/// Changes the file extension in a given file path.
	/// # Example
	/// Input: "/a/b/c.TXT", "lua" Output: "/a/b/c.lua"
	/// </summary>
	/// <param name="path">The input file path.</param>
	/// <param name="newExt">The new file extension to replace the old one.</param>
	/// <returns>The new file path.</returns>
	static string replaceExt(string path, string newExt);
	/// <summary>
	/// Changes the filename in a given file path.
	/// # Example
	/// Input: "/a/b/c.TXT", "d" Output: "/a/b/d.TXT"
	/// </summary>
	/// <param name="path">The input file path.</param>
	/// <param name="newFile">The new filename to replace the old one.</param>
	/// <returns>The new file path.</returns>
	static string replaceFilename(string path, string newFile);
	/// <summary>
	/// Joins the given segments into a new file path.
	/// # Example
	/// Input: "a", "b", "c.TXT" Output: "a/b/c.TXT"
	/// </summary>
	/// <param name="segments">The segments to be joined as a new file path.</param>
	/// <returns>The new file path.</returns>
	static string concatVector @ concat(VecStr paths);
};

value struct WorkSheet
{
	bool read(Array* row);
};

value struct WorkBook
{
	WorkSheet getSheet(string name);
};

/// <summary>
/// The `Content` is a static struct that manages file searching,
/// </summary>
/// <summary>
/// loading and other operations related to resources.
/// </summary>
singleton class Content
{
	/// <summary>
	/// An array of directories to search for resource files.
	/// </summary>
	common VecStr searchPaths;
	/// <summary>
	/// The path to the directory containing read-only resources. Can only be altered by the user on platform Windows, MacOS and Linux.
	/// </summary>
	common string assetPath;
	/// <summary>
	/// The path to the directory where files can be written. Can only be altered by the user on platform Windows, MacOS and Linux. Default is the same as `appPath`.
	/// </summary>
	common string writablePath;
	/// <summary>
	/// The path to the directory for the application storage.
	/// </summary>
	readonly common string appPath;
	/// <summary>
	/// Saves the specified content to a file with the specified filename.
	/// </summary>
	/// <param name="filename">The name of the file to save.</param>
	/// <param name="content">The content to save to the file.</param>
	/// <returns>`true` if the content saves to file successfully, `false` otherwise.</returns>
	bool save(string filename, string content);
	/// <summary>
	/// Checks if a file with the specified filename exists.
	/// </summary>
	/// <param name="filename">The name of the file to check.</param>
	/// <returns>`true` if the file exists, `false` otherwise.</returns>
	bool exist(string filename);
	/// <summary>
	/// Creates a new directory with the specified path.
	/// </summary>
	/// <param name="path">The path of the directory to create.</param>
	/// <returns>`true` if the directory was created, `false` otherwise.</returns>
	bool createFolder @ mkdir(string path);
	/// <summary>
	/// Checks if the specified path is a directory.
	/// </summary>
	/// <param name="path">The path to check.</param>
	/// <returns>`true` if the path is a directory, `false` otherwise.</returns>
	bool isFolder @ isdir(string path);
	/// <summary>
	/// Checks if the specified path is an absolute path.
	/// </summary>
	/// <param name="path">The path to check.</param>
	/// <returns>`true` if the path is an absolute path, `false` otherwise.</returns>
	bool isAbsolutePath(string path);
	/// <summary>
	/// Copies the file or directory at the specified source path to the target path.
	/// </summary>
	/// <param name="src">The path of the file or directory to copy.</param>
	/// <param name="dst">The path to copy the file or directory to.</param>
	/// <returns>`true` if the file or directory was successfully copied to the target path, `false` otherwise.</returns>
	bool copy(string src, string dst);
	/// <summary>
	/// Moves the file or directory at the specified source path to the target path.
	/// </summary>
	/// <param name="src">The path of the file or directory to move.</param>
	/// <param name="dst">The path to move the file or directory to.</param>
	/// <returns>`true` if the file or directory was successfully moved to the target path, `false` otherwise.</returns>
	bool move @ moveTo(string src, string dst);
	/// <summary>
	/// Removes the file or directory at the specified path.
	/// </summary>
	/// <param name="path">The path of the file or directory to remove.</param>
	/// <returns>`true` if the file or directory was successfully removed, `false` otherwise.</returns>
	bool remove(string path);
	/// <summary>
	/// Gets the full path of a file with the specified filename.
	/// </summary>
	/// <param name="filename">The name of the file to get the full path of.</param>
	/// <returns>The full path of the file.</returns>
	string getFullPath(string filename);
	/// <summary>
	/// Adds a new search path to the end of the list.
	/// </summary>
	/// <param name="path">The search path to add.</param>
	void addSearchPath(string path);
	/// <summary>
	/// Inserts a search path at the specified index.
	/// </summary>
	/// <param name="index">The index at which to insert the search path.</param>
	/// <param name="path">The search path to insert.</param>
	void insertSearchPath(int index, string path);
	/// <summary>
	/// Removes the specified search path from the list.
	/// </summary>
	/// <param name="path">The search path to remove.</param>
	void removeSearchPath(string path);
	/// <summary>
	/// Clears the search path cache of the map of relative paths to full paths.
	/// </summary>
	void clearPathCache();
	/// <summary>
	/// Gets the names of all subdirectories in the specified directory.
	/// </summary>
	/// <param name="path">The path of the directory to search.</param>
	/// <returns>An array of the names of all subdirectories in the specified directory.</returns>
	VecStr getDirs(string path);
	/// <summary>
	/// Gets the names of all files in the specified directory.
	/// </summary>
	/// <param name="path">The path of the directory to search.</param>
	/// <returns>An array of the names of all files in the specified directory.</returns>
	VecStr getFiles(string path);
	/// <summary>
	/// Gets the names of all files in the specified directory and its subdirectories.
	/// </summary>
	/// <param name="path">The path of the directory to search.</param>
	/// <returns>An array of the names of all files in the specified directory and its subdirectories.</returns>
	VecStr getAllFiles(string path);
	/// <summary>
	/// Asynchronously loads the content of the file with the specified filename.
	/// </summary>
	/// <param name="filename">The name of the file to load.</param>
	/// <param name="callback">The function to call with the content of the file once it is loaded.</param>
	/// <returns>The content of the loaded file.</returns>
	void loadAsync(string filename, function<void(string content)> callback);
	/// <summary>
	/// Asynchronously copies a file or a folder from the source path to the destination path.
	/// </summary>
	/// <param name="srcFile">The path of the file or folder to copy.</param>
	/// <param name="targetFile">The destination path of the copied files.</param>
	/// <param name="callback">The function to call with a boolean indicating whether the file or folder was copied successfully.</param>
	/// <returns>`true` if the file or folder was copied successfully, `false` otherwise.</returns>
	void copyAsync(string srcFile, string targetFile, function<void(bool success)> callback);
	/// <summary>
	/// Asynchronously saves the specified content to a file with the specified filename.
	/// </summary>
	/// <param name="filename">The name of the file to save.</param>
	/// <param name="content">The content to save to the file.</param>
	/// <param name="callback">The function to call with a boolean indicating whether the content was saved successfully.</param>
	/// <returns>`true` if the content was saved successfully, `false` otherwise.</returns>
	void saveAsync(string filename, string content, function<void(bool success)> callback);
	/// <summary>
	/// Asynchronously compresses the specified folder to a ZIP archive with the specified filename.
	/// </summary>
	/// <param name="folderPath">The path of the folder to compress, should be under the asset writable path.</param>
	/// <param name="zipFile">The name of the ZIP archive to create.</param>
	/// <param name="filter">An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.</param>
	/// <param name="callback">The function to call with a boolean indicating whether the folder was compressed successfully.</param>
	/// <returns>`true` if the folder was compressed successfully, `false` otherwise.</returns>
	void zipAsync(string folderPath, string zipFile, function<def_false bool(string file)> filter, function<void(bool success)> callback);
	/// <summary>
	/// Asynchronously decompresses a ZIP archive to the specified folder.
	/// </summary>
	/// <param name="zipFile">The name of the ZIP archive to decompress, should be a file under the asset writable path.</param>
	/// <param name="folderPath">The path of the folder to decompress to, should be under the asset writable path.</param>
	/// <param name="filter">An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.</param>
	/// <param name="callback">The function to call with a boolean indicating whether the archive was decompressed successfully.</param>
	/// <returns>`true` if the folder was decompressed successfully, `false` otherwise.</returns>
	void unzipAsync(string zipFile, string folderPath, function<def_false bool(string file)> filter, function<void(bool success)> callback);

	outside WorkBook content_wasm_load_excel @ load_excel(string filename);
};

/// <summary>
/// A scheduler that manages the execution of scheduled tasks.
/// </summary>
object class Scheduler
{
	/// <summary>
	/// The time scale factor for the scheduler.
	/// This factor is applied to deltaTime that the scheduled functions will receive.
	/// </summary>
	common float timeScale;
	/// <summary>
	/// The target frame rate (in frames per second) for a fixed update mode.
	/// The fixed update will ensure a constant frame rate, and the operation handled in a fixed update can use a constant delta time value.
	/// It is used for preventing weird behavior of a physics engine or synchronizing some states via network communications.
	/// </summary>
	common int fixedFPS @ fixed_fps;
	/// <summary>
	/// Used for manually updating the scheduler if it is created by the user.
	/// </summary>
	/// <param name="deltaTime">The time in seconds since the last frame update.</param>
	/// <returns>`true` if the scheduler was stoped, `false` otherwise.</returns>
	bool update(double deltaTime);
	/// <summary>
	/// Creates a new Scheduler object.
	/// </summary>
	static Scheduler* create();
};

/// <summary>
/// A struct for Camera object in the game engine.
/// </summary>
object class Camera
{
	/// <summary>
	/// The name of the Camera.
	/// </summary>
	readonly common string name;
};

/// <summary>
/// A struct for 2D camera object in the game engine.
/// </summary>
object class Camera2D : public Camera
{
	/// <summary>
	/// The rotation angle of the camera in degrees.
	/// </summary>
	common float rotation;
	/// <summary>
	/// The factor by which to zoom the camera. If set to 1.0, the view is normal sized. If set to 2.0, items will appear double in size.
	/// </summary>
	common float zoom;
	/// <summary>
	/// The position of the camera in the game world.
	/// </summary>
	common Vec2 position;
	/// <summary>
	/// Creates a new Camera2D object with the given name.
	/// </summary>
	/// <param name="name">The name of the Camera2D object.</param>
	/// <returns>A new instance of the Camera2D object.</returns>
	static Camera2D* create(string name = "");
};

/// <summary>
/// A struct for an orthographic camera object in the game engine.
/// </summary>
object class CameraOtho : public Camera
{
	/// <summary>
	/// The position of the camera in the game world.
	/// </summary>
	common Vec2 position;
	/// <summary>
	/// Creates a new CameraOtho object with the given name.
	/// </summary>
	/// <param name="name">The name of the CameraOtho object.</param>
	/// <returns>A new instance of the CameraOtho object.</returns>
	static CameraOtho* create(string name = "");
};

/// <summary>
/// A struct representing a shader pass.
/// </summary>
object class Pass
{
	/// <summary>
	/// Whether this Pass should be a grab pass.
	/// A grab pass will render a portion of game scene into a texture frame buffer.
	/// Then use this texture frame buffer as an input for next render pass.
	/// </summary>
	boolean bool grabPass;
	/// <summary>
	/// Sets the value of shader parameters.
	/// </summary>
	/// <param name="name">The name of the parameter to set.</param>
	/// <param name="val">The numeric value to set.</param>
	void set @ set(string name, float val);
	/// <summary>
	/// Sets the values of shader parameters.
	/// </summary>
	/// <param name="name">The name of the parameter to set.</param>
	/// <param name="val1">The first numeric value to set.</param>
	/// <param name="val2">An optional second numeric value to set.</param>
	/// <param name="val3">An optional third numeric value to set.</param>
	/// <param name="val4">An optional fourth numeric value to set.</param>
	void set @ setVec4(string name, float val1, float val2 = 0.0f, float val3 = 0.0f, float val4 = 0.0f);
	/// <summary>
	/// Another function that sets the values of shader parameters.
	/// Works the same as:
	/// pass.set("varName", color.r / 255.0, color.g / 255.0, color.b / 255.0, color.opacity);
	/// </summary>
	/// <param name="name">The name of the parameter to set.</param>
	/// <param name="val">The Color object to set.</param>
	void set @ setColor(string name, Color val);
	/// <summary>
	/// Creates a new Pass object.
	/// </summary>
	/// <param name="vertShader">The vertex shader in binary form file string.</param>
	/// <param name="fragShader">The fragment shader file string. A shader file string must be one of the formats:</param>
	/// <returns>A new Pass object.</returns>
	static Pass* create(string vertShader, string fragShader);
};

/// <summary>
/// A struct for managing multiple render pass objects.
/// </summary>
/// <summary>
/// Effect objects allow you to combine multiple passes to create more complex shader effects.
/// </summary>
object class Effect
{
	/// <summary>
	/// Adds a Pass object to this Effect.
	/// </summary>
	/// <param name="pass">The Pass object to add.</param>
	void add(Pass* pass);
	/// <summary>
	/// Retrieves a Pass object from this Effect by index.
	/// </summary>
	/// <param name="index">The index of the Pass object to retrieve.</param>
	/// <returns>The Pass object at the given index.</returns>
	outside optional Pass* Effect_GetPass @ get(size_t index) const;
	/// <summary>
	/// Removes all Pass objects from this Effect.
	/// </summary>
	void clear();
	/// <summary>
	/// A method that allows you to create a new Effect object.
	/// </summary>
	/// <param name="vertShader">The vertex shader file string.</param>
	/// <param name="fragShader">The fragment shader file string. A shader file string must be one of the formats:</param>
	/// <returns>A new Effect object.</returns>
	static Effect* create(string vertShader, string fragShader);
};

/// <summary>
/// A struct that is a specialization of Effect for rendering 2D sprites.
/// </summary>
object class SpriteEffect : public Effect
{
	/// <summary>
	/// A method that allows you to create a new SpriteEffect object.
	/// </summary>
	/// <param name="vertShader">The vertex shader file string.</param>
	/// <param name="fragShader">The fragment shader file string. A shader file string must be one of the formats:</param>
	/// <returns>A new SpriteEffect object.</returns>
	static SpriteEffect* create(string vertShader, string fragShader);
};

/// <summary>
/// A struct manages the game scene trees and provides access to root scene nodes for different game uses.
/// </summary>
singleton class Director
{
	/// <summary>
	/// The background color for the game world.
	/// </summary>
	common Color clearColor;
	/// <summary>
	/// The root node for 2D user interface elements like buttons and labels.
	/// </summary>
	readonly common Node* uI @ ui;
	/// <summary>
	/// The root node for 3D user interface elements with 3D projection effect.
	/// </summary>
	readonly common Node* uI3D @ ui_3d;
	/// <summary>
	/// The root node for the starting point of a game.
	/// </summary>
	readonly common Node* entry;
	/// <summary>
	/// The root node for post-rendering scene tree.
	/// </summary>
	readonly common Node* postNode;
	/// <summary>
	/// The current active camera in Director's camera stack.
	/// </summary>
	readonly common Camera* currentCamera;
	/// <summary>
	/// Whether or not to enable frustum culling.
	/// </summary>
	boolean bool frustumCulling;
	/// <summary>
	/// Schedule a function to be called every frame.
	/// </summary>
	/// <param name="updateFunc">The function to call every frame.</param>
	outside void Director_Schedule @ schedule(function<def_true bool(double deltaTime)> updateFunc);
	/// <summary>
	/// Schedule a function to be called every frame for processing post game logic.
	/// </summary>
	/// <param name="updateFunc">The function to call every frame.</param>
	outside void Director_SchedulePosted @ schedulePosted(function<def_true bool(double deltaTime)> updateFunc);
	/// <summary>
	/// Adds a new camera to Director's camera stack and sets it to the current camera.
	/// </summary>
	/// <param name="camera">The camera to add.</param>
	void pushCamera(Camera* camera);
	/// <summary>
	/// Removes the current camera from Director's camera stack.
	/// </summary>
	void popCamera();
	/// <summary>
	/// Removes a specified camera from Director's camera stack.
	/// </summary>
	/// <param name="camera">The camera to remove.</param>
	/// <returns>`true` if the camera was removed, `false` otherwise.</returns>
	bool removeCamera(Camera* camera);
	/// <summary>
	/// Removes all cameras from Director's camera stack.
	/// </summary>
	void clearCamera();
	/// <summary>
	/// Cleans up all resources managed by the Director, including scene trees and cameras.
	/// </summary>
	outside void Director_Cleanup @ cleanup();
};

/// <summary>
/// A struct that provides access to the 3D graphic view.
/// </summary>
singleton class View
{
	/// <summary>
	/// The size of the view in pixels.
	/// </summary>
	readonly common Size size;
	/// <summary>
	/// The standard distance of the view from the origin.
	/// </summary>
	readonly common float standardDistance;
	/// <summary>
	/// The aspect ratio of the view.
	/// </summary>
	readonly common float aspectRatio;
	/// <summary>
	/// The distance to the near clipping plane.
	/// </summary>
	common float nearPlaneDistance;
	/// <summary>
	/// The distance to the far clipping plane.
	/// </summary>
	common float farPlaneDistance;
	/// <summary>
	/// The field of view of the view in degrees.
	/// </summary>
	common float fieldOfView;
	/// <summary>
	/// The scale factor of the view.
	/// </summary>
	common float scale;
	/// <summary>
	/// The post effect applied to the view.
	/// </summary>
	optional common SpriteEffect* postEffect;
	/// <summary>
	/// Whether or not vertical sync is enabled.
	/// </summary>
	boolean bool vSync @ vsync;
};

value class ActionDef {
	/// <summary>
	/// Creates a new action definition object to change a property of a node.
	/// </summary>
	/// <param name="duration">The duration of the action.</param>
	/// <param name="start">The starting value of the property.</param>
	/// <param name="stop">The ending value of the property.</param>
	/// <param name="prop">The property to change.</param>
	/// <param name="easing">The easing function to use.</param>
	/// <returns>A new ActionDef object.</returns>
	static outside ActionDef ActionDef_Prop @ prop(float duration, float start, float stop, Property prop, EaseType easing);
	/// <summary>
	/// Creates a new action definition object to change the color of a node.
	/// </summary>
	/// <param name="duration">The duration of the action.</param>
	/// <param name="start">The starting color.</param>
	/// <param name="stop">The ending color.</param>
	/// <param name="easing">The easing function to use.</param>
	/// <returns>A new ActionDef object.</returns>
	static outside ActionDef ActionDef_Tint @ tint(float duration, Color3 start, Color3 stop, EaseType easing);
	/// <summary>
	/// Creates a new action definition object to rotate a node by smallest angle.
	/// </summary>
	/// <param name="duration">The duration of the action.</param>
	/// <param name="start">The starting angle.</param>
	/// <param name="stop">The ending angle.</param>
	/// <param name="easing">The easing function to use.</param>
	/// <returns>A new ActionDef object.</returns>
	static outside ActionDef ActionDef_Roll @ roll(float duration, float start, float stop, EaseType easing);
	/// <summary>
	/// Creates a new action definition object to run a group of actions in parallel.
	/// </summary>
	/// <param name="defs">The actions to run in parallel.</param>
	/// <returns>A new ActionDef object.</returns>
	static outside ActionDef ActionDef_Spawn @ spawn(VecActionDef defs);
	/// <summary>
	/// Creates a new action definition object to run a group of actions in sequence.
	/// </summary>
	/// <param name="defs">The actions to run in sequence.</param>
	/// <returns>A new ActionDef object.</returns>
	static outside ActionDef ActionDef_Sequence @ sequence(VecActionDef defs);
	/// <summary>
	/// Creates a new action definition object to delay the execution of following action.
	/// </summary>
	/// <param name="duration">The duration of the delay.</param>
	/// <returns>A new ActionDef object.</returns>
	static outside ActionDef ActionDef_Delay @ delay(float duration);
	/// <summary>
	/// Creates a new action definition object to show a node.
	/// </summary>
	static outside ActionDef ActionDef_Show @ show();
	/// <summary>
	/// Creates a new action definition object to hide a node.
	/// </summary>
	static outside ActionDef ActionDef_Hide @ hide();
	/// <summary>
	/// Creates a new action definition object to emit an event.
	/// </summary>
	/// <param name="eventName">The name of the event to emit.</param>
	/// <param name="msg">The message to send with the event.</param>
	/// <returns>A new ActionDef object.</returns>
	static outside ActionDef ActionDef_Emit @ event(string eventName, string msg);
	/// <summary>
	/// Creates a new action definition object to move a node.
	/// </summary>
	/// <param name="duration">The duration of the action.</param>
	/// <param name="start">The starting position.</param>
	/// <param name="stop">The ending position.</param>
	/// <param name="easing">The easing function to use.</param>
	/// <returns>A new ActionDef object.</returns>
	static outside ActionDef ActionDef_Move @ move_to(float duration, Vec2 start, Vec2 stop, EaseType easing);
	/// <summary>
	/// Creates a new action definition object to scale a node.
	/// </summary>
	/// <param name="duration">The duration of the action.</param>
	/// <param name="start">The starting scale.</param>
	/// <param name="stop">The ending scale.</param>
	/// <param name="easing">The easing function to use.</param>
	/// <returns>A new ActionDef object.</returns>
	static outside ActionDef ActionDef_Scale @ scale(float duration, float start, float stop, EaseType easing);
	/// <summary>
	/// Creates a new action definition object to do a frame animation. Can only be performed on a Sprite node.
	/// </summary>
	/// <param name="clipStr">The name of the image clip, which is a sprite sheet. Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.</param>
	/// <param name="duration">The duration of the action.</param>
	/// <returns>A new ActionDef object.</returns>
	static outside ActionDef ActionDef_Frame @ frame(string clipStr, float duration);
	/// <summary>
	/// Creates a new action definition object to do a frame animation with frames count for each frame. Can only be performed on a Sprite node.
	/// </summary>
	/// <param name="clipStr">The name of the image clip, which is a sprite sheet. Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.</param>
	/// <param name="duration">The duration of the action.</param>
	/// <param name="frames">The number of frames for each frame.</param>
	/// <returns>A new Action object.</returns>
	static outside ActionDef ActionDef_Frame @ frame_with_frames(string clipStr, float duration, VecUint32 frames);
};

/// <summary>
/// Represents an action that can be run on a node.
/// </summary>
object class Action
{
	/// <summary>
	/// The duration of the action.
	/// </summary>
	readonly common float duration;
	/// <summary>
	/// Whether the action is currently running.
	/// </summary>
	readonly boolean bool running;
	/// <summary>
	/// Whether the action is currently paused.
	/// </summary>
	readonly boolean bool paused;
	/// <summary>
	/// Whether the action should be run in reverse.
	/// </summary>
	boolean bool reversed;
	/// <summary>
	/// The speed at which the action should be run.
	/// Set to 1.0 to get normal speed, Set to 2.0 to get two times faster.
	/// </summary>
	common float speed;
	/// <summary>
	/// Pauses the action.
	/// </summary>
	void pause();
	/// <summary>
	/// Resumes the action.
	/// </summary>
	void resume();
	/// <summary>
	/// Updates the state of the Action.
	/// </summary>
	/// <param name="elapsed">The amount of time in seconds that has elapsed to update action to.</param>
	/// <param name="reversed">Whether or not to update the Action in reverse.</param>
	void updateTo(float elapsed, bool reversed = false);
	/// <summary>
	/// Creates a new Action object.
	/// </summary>
	/// <param name="def">The definition of the action.</param>
	/// <returns>A new Action object.</returns>
	static Action* create(ActionDef def);
};

/// <summary>
/// A grabber which is used to render a part of the scene to a texture
/// </summary>
/// <summary>
/// by a grid of vertices.
/// </summary>
object class Grabber
{
	/// <summary>
	/// The camera used to render the texture.
	/// </summary>
	optional common Camera* camera;
	/// <summary>
	/// The sprite effect applied to the texture.
	/// </summary>
	optional common SpriteEffect* effect;
	/// <summary>
	/// The blend function for the grabber.
	/// </summary>
	common BlendFunc blendFunc;
	/// <summary>
	/// The clear color used to clear the texture.
	/// </summary>
	common Color clearColor;
	/// <summary>
	/// Sets the position of a vertex in the grabber grid.
	/// </summary>
	/// <param name="x">The x-index of the vertex in the grabber grid.</param>
	/// <param name="y">The y-index of the vertex in the grabber grid.</param>
	/// <param name="pos">The new position of the vertex, represented by a Vec2 object.</param>
	/// <param name="z">An optional argument representing the new z-coordinate of the vertex.</param>
	void setPos(int x, int y, Vec2 pos, float z = 0.0f);
	/// <summary>
	/// Gets the position of a vertex in the grabber grid.
	/// </summary>
	/// <param name="x">The x-index of the vertex in the grabber grid.</param>
	/// <param name="y">The y-index of the vertex in the grabber grid.</param>
	/// <returns>The position of the vertex.</returns>
	Vec2 getPos(int x, int y) const;
	/// <summary>
	/// Sets the color of a vertex in the grabber grid.
	/// </summary>
	/// <param name="x">The x-index of the vertex in the grabber grid.</param>
	/// <param name="y">The y-index of the vertex in the grabber grid.</param>
	/// <param name="color">The new color of the vertex, represented by a Color object.</param>
	void setColor(int x, int y, Color color);
	/// <summary>
	/// Gets the color of a vertex in the grabber grid.
	/// </summary>
	/// <param name="x">The x-index of the vertex in the grabber grid.</param>
	/// <param name="y">The y-index of the vertex in the grabber grid.</param>
	/// <returns>The color of the vertex.</returns>
	Color getColor(int x, int y) const;
	/// <summary>
	/// Sets the UV coordinates of a vertex in the grabber grid.
	/// </summary>
	/// <param name="x">The x-index of the vertex in the grabber grid.</param>
	/// <param name="y">The y-index of the vertex in the grabber grid.</param>
	/// <param name="offset">The new UV coordinates of the vertex, represented by a Vec2 object.</param>
	void moveUV @ move_uv(int x, int y, Vec2 offset);
};

/// <summary>
/// Struct used for building a hierarchical tree structure of game objects.
/// </summary>
object class Node
{
	/// <summary>
	/// The order of the node in the parent's children array.
	/// </summary>
	common int order;
	/// <summary>
	/// The rotation angle of the node in degrees.
	/// </summary>
	common float angle;
	/// <summary>
	/// The X-axis rotation angle of the node in degrees.
	/// </summary>
	common float angleX;
	/// <summary>
	/// The Y-axis rotation angle of the node in degrees.
	/// </summary>
	common float angleY;
	/// <summary>
	/// The X-axis scale factor of the node.
	/// </summary>
	common float scaleX;
	/// <summary>
	/// The Y-axis scale factor of the node.
	/// </summary>
	common float scaleY;
	/// <summary>
	/// The X-axis position of the node.
	/// </summary>
	common float x;
	/// <summary>
	/// The Y-axis position of the node.
	/// </summary>
	common float y;
	/// <summary>
	/// The Z-axis position of the node.
	/// </summary>
	common float z;
	/// <summary>
	/// The position of the node as a Vec2 object.
	/// </summary>
	common Vec2 position;
	/// <summary>
	/// The X-axis skew angle of the node in degrees.
	/// </summary>
	common float skewX;
	/// <summary>
	/// The Y-axis skew angle of the node in degrees.
	/// </summary>
	common float skewY;
	/// <summary>
	/// Whether the node is visible.
	/// </summary>
	boolean bool visible;
	/// <summary>
	/// The anchor point of the node as a Vec2 object.
	/// </summary>
	common Vec2 anchor;
	/// <summary>
	/// The width of the node.
	/// </summary>
	common float width;
	/// <summary>
	/// The height of the node.
	/// </summary>
	common float height;
	/// <summary>
	/// The size of the node as a Size object.
	/// </summary>
	common Size size;
	/// <summary>
	/// The tag of the node as a string.
	/// </summary>
	common string tag;
	/// <summary>
	/// The opacity of the node, should be 0 to 1.0.
	/// </summary>
	common float opacity;
	/// <summary>
	/// The color of the node as a Color object.
	/// </summary>
	common Color color;
	/// <summary>
	/// The color of the node as a Color3 object.
	/// </summary>
	common Color3 color3;
	/// <summary>
	/// Whether to pass the opacity value to child nodes.
	/// </summary>
	boolean bool passOpacity;
	/// <summary>
	/// Whether to pass the color value to child nodes.
	/// </summary>
	boolean bool passColor3;
	/// <summary>
	/// The target node acts as a parent node for transforming this node.
	/// </summary>
	optional common Node* transformTarget;
	/// <summary>
	/// The scheduler used for scheduling update and action callbacks.
	/// </summary>
	common Scheduler* scheduler;
	/// <summary>
	/// The children of the node as an Array object, could be None.
	/// </summary>
	optional readonly common Array* children;
	/// <summary>
	/// The parent of the node, could be None.
	/// </summary>
	optional readonly common Node* parent;
	/// <summary>
	/// Whether the node is currently running in a scene tree.
	/// </summary>
	readonly boolean bool running;
	/// <summary>
	/// Whether the node is currently scheduling a function for updates.
	/// </summary>
	readonly boolean bool scheduled;
	/// <summary>
	/// The number of actions currently running on the node.
	/// </summary>
	readonly common int actionCount;
	/// <summary>
	/// Additional data stored on the node as a Dictionary object.
	/// </summary>
	readonly common Dictionary* userData @ data;
	/// <summary>
	/// Whether touch events are enabled on the node.
	/// </summary>
	boolean bool touchEnabled;
	/// <summary>
	/// Whether the node should swallow touch events.
	/// </summary>
	boolean bool swallowTouches;
	/// <summary>
	/// Whether the node should swallow mouse wheel events.
	/// </summary>
	boolean bool swallowMouseWheel;
	/// <summary>
	/// Whether keyboard events are enabled on the node.
	/// </summary>
	boolean bool keyboardEnabled;
	/// <summary>
	/// Whether controller events are enabled on the node.
	/// </summary>
	boolean bool controllerEnabled;
	/// <summary>
	/// Whether to group the node's rendering with all its recursive children.
	/// </summary>
	boolean bool renderGroup;
	/// <summary>
	/// Whether debug graphic should be displayed for the node.
	/// </summary>
	boolean bool showDebug;
	/// <summary>
	/// The rendering order number for group rendering. Nodes with lower rendering orders are rendered earlier.
	/// </summary>
	common int renderOrder;
	/// <summary>
	/// Adds a child node to the current node.
	/// </summary>
	/// <param name="child">The child node to add.</param>
	/// <param name="order">The drawing order of the child node.</param>
	/// <param name="tag">The tag of the child node.</param>
	void addChild @ addChildWithOrderTag(Node* child, int order, string tag);
	/// <summary>
	/// Adds a child node to the current node.
	/// </summary>
	/// <param name="child">The child node to add.</param>
	/// <param name="order">The drawing order of the child node.</param>
	void addChild @ addChildWithOrder(Node* child, int order);
	/// <summary>
	/// Adds a child node to the current node.
	/// </summary>
	/// <param name="child">The child node to add.</param>
	void addChild(Node* child);
	/// <summary>
	/// Adds the current node to a parent node.
	/// </summary>
	/// <param name="parent">The parent node to add the current node to.</param>
	/// <param name="order">The drawing order of the current node.</param>
	/// <param name="tag">The tag of the current node.</param>
	/// <returns>The current node.</returns>
	Node* addTo @ addToWithOrderTag(Node* parent, int order, string tag);
	/// <summary>
	/// Adds the current node to a parent node.
	/// </summary>
	/// <param name="parent">The parent node to add the current node to.</param>
	/// <param name="order">The drawing order of the current node.</param>
	/// <returns>The current node.</returns>
	Node* addTo @ addToWithOrder(Node* parent, int order);
	/// <summary>
	/// Adds the current node to a parent node.
	/// </summary>
	/// <param name="parent">The parent node to add the current node to.</param>
	/// <returns>The current node.</returns>
	Node* addTo(Node* parent);
	/// <summary>
	/// Removes a child node from the current node.
	/// </summary>
	/// <param name="child">The child node to remove.</param>
	/// <param name="cleanup">Whether to cleanup the child node.</param>
	void removeChild(Node* child, bool cleanup = true);
	/// <summary>
	/// Removes a child node from the current node by tag.
	/// </summary>
	/// <param name="tag">The tag of the child node to remove.</param>
	/// <param name="cleanup">Whether to cleanup the child node.</param>
	void removeChildByTag(string tag, bool cleanup = true);
	/// <summary>
	/// Removes all child nodes from the current node.
	/// </summary>
	/// <param name="cleanup">Whether to cleanup the child nodes.</param>
	void removeAllChildren(bool cleanup = true);
	/// <summary>
	/// Removes the current node from its parent node.
	/// </summary>
	/// <param name="cleanup">Whether to cleanup the current node.</param>
	void removeFromParent(bool cleanup = true);
	/// <summary>
	/// Moves the current node to a new parent node without triggering node events.
	/// </summary>
	/// <param name="parent">The new parent node to move the current node to.</param>
	void moveToParent(Node* parent);
	/// <summary>
	/// Cleans up the current node.
	/// </summary>
	void cleanup();
	/// <summary>
	/// Gets a child node by tag.
	/// </summary>
	/// <param name="tag">The tag of the child node to get.</param>
	/// <returns>The child node, or `None` if not found.</returns>
	optional Node* getChildByTag(string tag);
	/// <summary>
	/// Schedules a main function to run every frame. Call this function again to replace the previous scheduled main function or coroutine.
	/// </summary>
	/// <param name="updateFunc">The function to be called. If the function returns `true`, it will not be called again.</param>
	void schedule(function<def_true bool(double deltaTime)> updateFunc);
	/// <summary>
	/// Unschedules the current node's scheduled main function.
	/// </summary>
	void unschedule();
	/// <summary>
	/// Converts a point from world space to node space.
	/// </summary>
	/// <param name="worldPoint">The point in world space, represented by a Vec2 object.</param>
	/// <returns>The converted point in world space.</returns>
	Vec2 convertToNodeSpace(Vec2 worldPoint);
	/// <summary>
	/// Converts a point from node space to world space.
	/// </summary>
	/// <param name="nodePoint">The point in node space, represented by a Vec2 object.</param>
	/// <returns>The converted point in world space.</returns>
	Vec2 convertToWorldSpace(Vec2 nodePoint);
	/// <summary>
	/// Converts a point from node space to world space.
	/// </summary>
	/// <param name="nodePoint">The point in node space, represented by a Vec2 object.</param>
	/// <param name="callback">The function to call with the converted point in world space.</param>
	/// <returns>The converted point in world space.</returns>
	void convertToWindowSpace(Vec2 nodePoint, function<void(Vec2 result)> callback);
	/// <summary>
	/// Calls the given function for each child node of this node.
	/// </summary>
	/// <param name="visitorFunc">The function to call for each child node. The function should return a boolean value indicating whether to continue the iteration. Return true to stop iteration.</param>
	/// <returns>`false` if all children have been visited, `true` if the iteration was interrupted by the function.</returns>
	bool eachChild(function<def_true bool(Node* child)> visitorFunc);
	/// <summary>
	/// Traverses the node hierarchy starting from this node and calls the given function for each visited node. The nodes without `TraverseEnabled` flag are not visited.
	/// </summary>
	/// <param name="visitorFunc">The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal. Return true to stop iteration.</param>
	/// <returns>`false` if all nodes have been visited, `true` if the traversal was interrupted by the function.</returns>
	bool traverse(function<def_true bool(Node* child)> visitorFunc);
	/// <summary>
	/// Traverses the entire node hierarchy starting from this node and calls the given function for each visited node.
	/// </summary>
	/// <param name="visitorFunc">The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal.</param>
	/// <returns>`false` if all nodes have been visited, `true` if the traversal was interrupted by the function.</returns>
	bool traverseAll(function<def_true bool(Node* child)> visitorFunc);
	/// <summary>
	/// Runs an action defined by the given action definition on this node.
	/// </summary>
	/// <param name="actionDef">The action definition to run.</param>
	/// <param name="looped">Whether to loop the action.</param>
	/// <returns>The duration of the newly running action in seconds.</returns>
	outside float Node_RunActionDefDuration @ run_action_def(ActionDef actionDef, bool looped);
	/// <summary>
	/// Runs an action on this node.
	/// </summary>
	/// <param name="action">The action to run.</param>
	/// <param name="looped">Whether to loop the action.</param>
	/// <returns>The duration of the newly running action in seconds.</returns>
	float runAction @ runAction(Action* action, bool looped = false);
	/// <summary>
	/// Stops all actions running on this node.
	/// </summary>
	void stopAllActions();
	/// <summary>
	/// Runs an action defined by the given action definition right after clearing all the previous running actions.
	/// </summary>
	/// <param name="actionDef">The action definition to run.</param>
	/// <param name="looped">Whether to loop the action.</param>
	/// <returns>The duration of the newly running action in seconds.</returns>
	outside float Node_PerformDefDuration @ perform_def(ActionDef actionDef, bool looped);
	/// <summary>
	/// Runs an action on this node right after clearing all the previous running actions.
	/// </summary>
	/// <param name="action">The action to run.</param>
	/// <param name="looped">Whether to loop the action.</param>
	/// <returns>The duration of the newly running action in seconds.</returns>
	float perform(Action* action, bool looped = false);
	/// <summary>
	/// Stops the given action running on this node.
	/// </summary>
	/// <param name="action">The action to stop.</param>
	void stopAction(Action* action);
	/// <summary>
	/// Vertically aligns all child nodes within the node using the given size and padding.
	/// </summary>
	/// <param name="padding">The amount of padding to use between each child node.</param>
	/// <returns>The size of the node after alignment.</returns>
	Size alignItemsVertically(float padding = 10.0f);
	/// <summary>
	/// Vertically aligns all child nodes within the node using the given size and padding.
	/// </summary>
	/// <param name="size">The size to use for alignment.</param>
	/// <param name="padding">The amount of padding to use between each child node.</param>
	/// <returns>The size of the node after alignment.</returns>
	Size alignItemsVertically @ alignItemsVerticallyWithSize(Size size, float padding = 10.0f);
	/// <summary>
	/// Horizontally aligns all child nodes within the node using the given size and padding.
	/// </summary>
	/// <param name="padding">The amount of padding to use between each child node.</param>
	/// <returns>The size of the node after alignment.</returns>
	Size alignItemsHorizontally(float padding = 10.0f);
	/// <summary>
	/// Horizontally aligns all child nodes within the node using the given size and padding.
	/// </summary>
	/// <param name="size">The size to hint for alignment.</param>
	/// <param name="padding">The amount of padding to use between each child node.</param>
	/// <returns>The size of the node after alignment.</returns>
	Size alignItemsHorizontally @ alignItemsHorizontallyWithSize(Size size, float padding = 10.0f);
	/// <summary>
	/// Aligns all child nodes within the node using the given size and padding.
	/// </summary>
	/// <param name="padding">The amount of padding to use between each child node.</param>
	/// <returns>The size of the node after alignment.</returns>
	Size alignItems(float padding = 10.0f);
	/// <summary>
	/// Aligns all child nodes within the node using the given size and padding.
	/// </summary>
	/// <param name="size">The size to use for alignment.</param>
	/// <param name="padding">The amount of padding to use between each child node.</param>
	/// <returns>The size of the node after alignment.</returns>
	Size alignItems @ alignItemsWithSize(Size size, float padding = 10.0f);
	/// <summary>
	/// Moves and changes child nodes' visibility based on their position in parent's area.
	/// </summary>
	/// <param name="delta">The distance to move its children, represented by a Vec2 object.</param>
	void moveAndCullItems(Vec2 delta);
	/// <summary>
	/// Attaches the input method editor (IME) to the node.
	/// Makes node recieving "AttachIME", "DetachIME", "TextInput", "TextEditing" events.
	/// </summary>
	void attachIME @ attach_ime();
	/// <summary>
	/// Detaches the input method editor (IME) from the node.
	/// </summary>
	void detachIME @ detach_ime();
	/// <summary>
	/// Creates a texture grabber for the specified node.
	/// </summary>
	/// <returns>A Grabber object with gridX == 1 and gridY == 1.</returns>
	outside Grabber* Node_StartGrabbing @ grab();
	/// <summary>
	/// Creates a texture grabber for the specified node with a specified grid size.
	/// </summary>
	/// <param name="gridX">The number of horizontal grid cells to divide the grabber into.</param>
	/// <param name="gridY">The number of vertical grid cells to divide the grabber into.</param>
	/// <returns>A Grabber object.</returns>
	Grabber* grab @ grabWithSize(uint32_t gridX, uint32_t gridY);
	/// <summary>
	/// Removes the texture grabber for the specified node.
	/// </summary>
	outside void Node_StopGrabbing @ stop_grab();
	/// <summary>
	/// Associates the given handler function with the node event.
	/// </summary>
	/// <param name="eventName">The name of the node event.</param>
	/// <param name="handler">The handler function to associate with the node event.</param>
	void slot(string eventName, function<void(Event* e)> handler);
	/// <summary>
	/// Associates the given handler function with a global event.
	/// </summary>
	/// <param name="eventName">The name of the global event.</param>
	/// <param name="handler">The handler function to associate with the event.</param>
	void gslot(string eventName, function<void(Event* e)> handler);
	/// <summary>
	/// Emits an event to a node, triggering the event handler associated with the event name.
	/// </summary>
	/// <param name="name">The name of the event.</param>
	/// <param name="stack">The argument stack to be passed to the event handler.</param>
	outside void Node_Emit @ emit(string name, CallStack* stack);
	/// <summary>
	/// Schedules a function to run every frame. Call this function again to schedule multiple functions.
	/// </summary>
	/// <param name="updateFunc">The function to run every frame. If the function returns `true`, it will not be called again.</param>
	void onUpdate(function<def_true bool(double deltaTime)> updateFunc);
	/// <summary>
	/// Registers a callback for event triggered when the node is entering the rendering phase. The callback is called every frame, and ensures that its call order is consistent with the rendering order of the scene tree, such as rendering child nodes after their parent nodes. Recommended for calling vector drawing functions.
	/// </summary>
	/// <param name="renderFunc">The function to call when the node is entering the rendering phase, returns true to stop.</param>
	/// <returns>True to stop the function from running.</returns>
	void onRender(function<def_true bool(double deltaTime)> renderFunc);
	/// <summary>
	/// Creates a new instance of the `Node` struct.
	/// </summary>
	static Node* create();
};

/// <summary>
/// A struct represents a 2D texture.
/// </summary>
object class Texture2D
{
	/// <summary>
	/// The width of the texture, in pixels.
	/// </summary>
	readonly common int width;
	/// <summary>
	/// The height of the texture, in pixels.
	/// </summary>
	readonly common int height;
	/// <summary>
	/// Creates a texture object from the given file.
	/// </summary>
	/// <param name="filename">The file name of the texture.</param>
	/// <returns>The texture object.</returns>
	static outside optional Texture2D* Texture2D_Create @ createFile(string filename);
};

/// <summary>
/// A struct to render texture in game scene tree hierarchy.
/// </summary>
object class Sprite : public Node
{
	/// <summary>
	/// Whether the depth buffer should be written to when rendering the sprite.
	/// </summary>
	boolean bool depthWrite;
	/// <summary>
	/// The alpha reference value for alpha testing. Pixels with alpha values less than or equal to this value will be discarded.
	/// Only works with `sprite.effect = SpriteEffect::new("builtin:vs_sprite", "builtin:fs_spritealphatest");`.
	/// </summary>
	common float alphaRef;
	/// <summary>
	/// The texture rectangle for the sprite.
	/// </summary>
	common Rect textureRect;
	/// <summary>
	/// The texture for the sprite.
	/// </summary>
	optional readonly common Texture2D* texture;
	/// <summary>
	/// The blend function for the sprite.
	/// </summary>
	common BlendFunc blendFunc;
	/// <summary>
	/// The sprite shader effect.
	/// </summary>
	common SpriteEffect* effect;
	/// <summary>
	/// The texture wrapping mode for the U (horizontal) axis.
	/// </summary>
	common TextureWrap uWrap @ uwrap;
	/// <summary>
	/// The texture wrapping mode for the V (vertical) axis.
	/// </summary>
	common TextureWrap vWrap @ vwrap;
	/// <summary>
	/// The texture filtering mode for the sprite.
	/// </summary>
	common TextureFilter filter;
	/// <summary>
	/// Removes the sprite effect and sets the default effect.
	/// </summary>
	outside void Sprite_SetEffectNullptr @ set_effect_as_default();
	/// <summary>
	/// A method for creating a Sprite object.
	/// </summary>
	/// <returns>A new instance of the Sprite class.</returns>
	static Sprite* create();
	/// <summary>
	/// A method for creating a Sprite object.
	/// </summary>
	/// <param name="texture">The texture to be used for the sprite.</param>
	/// <param name="textureRect">An optional rectangle defining the portion of the texture to use for the sprite. If not provided, the whole texture will be used for rendering.</param>
	/// <returns>A new instance of the Sprite class.</returns>
	static Sprite* create @ createTextureRect(Texture2D* texture, Rect textureRect);
	/// <summary>
	/// A method for creating a Sprite object.
	/// </summary>
	/// <param name="texture">The texture to be used for the sprite.</param>
	/// <returns>A new instance of the Sprite class.</returns>
	static Sprite* create @ createTexture(Texture2D* texture);
	/// <summary>
	/// A method for creating a Sprite object.
	/// </summary>
	/// <param name="clipStr">The string containing format for loading a texture file. Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.</param>
	/// <returns>A new instance of the Sprite class. If the texture file is not found, it will return `None`.</returns>
	static optional Sprite* from @ createFile(string clipStr);
};

/// <summary>
/// A struct used to render a texture as a grid of sprites, where each sprite can be positioned, colored, and have its UV coordinates manipulated.
/// </summary>
object class Grid : public Node
{
	/// <summary>
	/// The number of columns in the grid. And there are `gridX + 1` vertices horizontally for rendering.
	/// </summary>
	readonly common uint32_t gridX;
	/// <summary>
	/// The number of rows in the grid. And there are `gridY + 1` vertices vertically for rendering.
	/// </summary>
	readonly common uint32_t gridY;
	/// <summary>
	/// Whether depth writes are enabled.
	/// </summary>
	boolean bool depthWrite;
	/// <summary>
	/// The blend function for the grid.
	/// </summary>
	common BlendFunc blendFunc;
	/// <summary>
	/// The sprite effect applied to the grid.
	/// Default is `SpriteEffect::new("builtin:vs_sprite", "builtin:fs_sprite")`.
	/// </summary>
	common SpriteEffect* effect;
	/// <summary>
	/// The rectangle within the texture that is used for the grid.
	/// </summary>
	common Rect textureRect;
	/// <summary>
	/// The texture used for the grid.
	/// </summary>
	optional common Texture2D* texture;
	/// <summary>
	/// Sets the position of a vertex in the grid.
	/// </summary>
	/// <param name="x">The x-coordinate of the vertex in the grid.</param>
	/// <param name="y">The y-coordinate of the vertex in the grid.</param>
	/// <param name="pos">The new position of the vertex, represented by a Vec2 object.</param>
	/// <param name="z">The new z-coordinate of the vertex.</param>
	void setPos(int x, int y, Vec2 pos, float z = 0.0f);
	/// <summary>
	/// Gets the position of a vertex in the grid.
	/// </summary>
	/// <param name="x">The x-coordinate of the vertex in the grid.</param>
	/// <param name="y">The y-coordinate of the vertex in the grid.</param>
	/// <returns>The current position of the vertex.</returns>
	Vec2 getPos(int x, int y) const;
	/// <summary>
	/// Sets the color of a vertex in the grid.
	/// </summary>
	/// <param name="x">The x-coordinate of the vertex in the grid.</param>
	/// <param name="y">The y-coordinate of the vertex in the grid.</param>
	/// <param name="color">The new color of the vertex, represented by a Color object.</param>
	void setColor(int x, int y, Color color);
	/// <summary>
	/// Gets the color of a vertex in the grid.
	/// </summary>
	/// <param name="x">The x-coordinate of the vertex in the grid.</param>
	/// <param name="y">The y-coordinate of the vertex in the grid.</param>
	/// <returns>The current color of the vertex.</returns>
	Color getColor(int x, int y) const;
	/// <summary>
	/// Moves the UV coordinates of a vertex in the grid.
	/// </summary>
	/// <param name="x">The x-coordinate of the vertex in the grid.</param>
	/// <param name="y">The y-coordinate of the vertex in the grid.</param>
	/// <param name="offset">The offset by which to move the UV coordinates, represented by a Vec2 object.</param>
	void moveUV @ move_uv(int x, int y, Vec2 offset);
	/// <summary>
	/// Creates a new Grid with the specified dimensions and grid size.
	/// </summary>
	/// <param name="width">The width of the grid.</param>
	/// <param name="height">The height of the grid.</param>
	/// <param name="gridX">The number of columns in the grid.</param>
	/// <param name="gridY">The number of rows in the grid.</param>
	/// <returns>The new Grid instance.</returns>
	static Grid* create(float width, float height, uint32_t gridX, uint32_t gridY);
	/// <summary>
	/// Creates a new Grid with the specified texture, texture rectangle, and grid size.
	/// </summary>
	/// <param name="texture">The texture to use for the grid.</param>
	/// <param name="textureRect">The rectangle within the texture to use for the grid.</param>
	/// <param name="gridX">The number of columns in the grid.</param>
	/// <param name="gridY">The number of rows in the grid.</param>
	/// <returns>The new Grid instance.</returns>
	static Grid* create @ createTextureRect(Texture2D* texture, Rect textureRect, uint32_t gridX, uint32_t gridY);
	/// <summary>
	/// Creates a new Grid with the specified texture, texture rectangle, and grid size.
	/// </summary>
	/// <param name="texture">The texture to use for the grid.</param>
	/// <param name="gridX">The number of columns in the grid.</param>
	/// <param name="gridY">The number of rows in the grid.</param>
	/// <returns>The new Grid instance.</returns>
	static Grid* create @ createTexture(Texture2D* texture, uint32_t gridX, uint32_t gridY);
	/// <summary>
	/// Creates a new Grid with the specified clip string and grid size.
	/// </summary>
	/// <param name="clipStr">The clip string to use for the grid. Can be "Image/file.png" and "Image/items.clip|itemA".</param>
	/// <param name="gridX">The number of columns in the grid.</param>
	/// <param name="gridY">The number of rows in the grid.</param>
	/// <returns>The new Grid instance.</returns>
	static optional Grid* from @ createFile(string clipStr, uint32_t gridX, uint32_t gridY);
};

/// <summary>
/// Represents a touch input or mouse click event.
/// </summary>
object class Touch
{
	/// <summary>
	/// Whether touch input is enabled or not.
	/// </summary>
	boolean bool enabled;
	/// <summary>
	/// Whether this is the first touch event when multi-touches exist.
	/// </summary>
	readonly boolean bool first;
	/// <summary>
	/// The unique identifier assigned to this touch event.
	/// </summary>
	readonly common int id;
	/// <summary>
	/// The amount and direction of movement since the last touch event.
	/// </summary>
	readonly common Vec2 delta;
	/// <summary>
	/// The location of the touch event in the node's local coordinate system.
	/// </summary>
	readonly common Vec2 location;
	/// <summary>
	/// The location of the touch event in the world coordinate system.
	/// </summary>
	readonly common Vec2 worldLocation;
};

/// <summary>
/// A struct that defines a set of easing functions for use in animations.
/// </summary>
singleton struct Ease
{
	/// <summary>
	/// Applies an easing function to a given value over a given amount of time.
	/// </summary>
	/// <param name="easing">The easing function to apply.</param>
	/// <param name="time">The amount of time to apply the easing function over, should be between 0 and 1.</param>
	/// <returns>The result of applying the easing function to the value.</returns>
	static float func(EaseType easing, float time);
};

/// <summary>
/// A node for rendering text using a TrueType font.
/// </summary>
object class Label : public Node
{
	/// <summary>
	/// The text alignment setting.
	/// </summary>
	common TextAlign alignment;
	/// <summary>
	/// The alpha threshold value. Pixels with alpha values below this value will not be drawn.
	/// Only works with `label.effect = SpriteEffect::new("builtin:vs_sprite", "builtin:fs_spritealphatest")`.
	/// </summary>
	common float alphaRef;
	/// <summary>
	/// The width of the text used for text wrapping.
	/// Set to `Label::AutomaticWidth` to disable wrapping.
	/// Default is `Label::AutomaticWidth`.
	/// </summary>
	common float textWidth;
	/// <summary>
	/// The gap in pixels between characters.
	/// </summary>
	common float spacing;
	/// <summary>
	/// The gap in pixels between lines of text.
	/// </summary>
	common float lineGap;
	/// <summary>
	/// The color of the outline, only works with SDF label.
	/// </summary>
	common Color outlineColor;
	/// <summary>
	/// The width of the outline, only works with SDF label.
	/// </summary>
	common float outlineWidth;
	/// <summary>
	/// The smooth value of the text, only works with SDF label, default is (0.7, 0.7).
	/// </summary>
	common Vec2 smooth;
	/// <summary>
	/// The text to be rendered.
	/// </summary>
	common string text;
	/// <summary>
	/// The blend function for the label.
	/// </summary>
	common BlendFunc blendFunc;
	/// <summary>
	/// Whether depth writing is enabled. (Default is false)
	/// </summary>
	boolean bool depthWrite;
	/// <summary>
	/// Whether the label is using batched rendering.
	/// When using batched rendering the `label.get_character()` function will no longer work, but it provides better rendering performance. Default is true.
	/// </summary>
	boolean bool batched;
	/// <summary>
	/// The sprite effect used to render the text.
	/// </summary>
	common SpriteEffect* effect;
	/// <summary>
	/// The number of characters in the label.
	/// </summary>
	readonly common int characterCount;
	/// <summary>
	/// Returns the sprite for the character at the specified index.
	/// </summary>
	/// <param name="index">The index of the character sprite to retrieve.</param>
	/// <returns>The sprite for the character, or `None` if the index is out of range.</returns>
	optional Sprite* getCharacter(int index);
	/// <summary>
	/// The value to use for automatic width calculation
	/// </summary>
	static readonly float AutomaticWidth @ automaticWidth;
	/// <summary>
	/// Creates a new Label object with the specified font name and font size.
	/// </summary>
	/// <param name="fontName">The name of the font to use for the label. Can be font file path with or without file extension.</param>
	/// <param name="fontSize">The size of the font to use for the label.</param>
	/// <param name="sdf">Whether to use SDF rendering or not. With SDF rendering, the outline feature will be enabled.</param>
	/// <returns>The new Label object.</returns>
	static optional Label* create(string fontName, uint32_t fontSize, bool sdf = false);
	/// <summary>
	/// Creates a new Label object with the specified font string.
	/// </summary>
	/// <param name="fontStr">The font string to use for the label. Should be in the format "fontName;fontSize;sdf", where `sdf` should be "true" or "false".</param>
	/// <returns>The new Label object.</returns>
	static optional Label* create @ with_str(string fontStr);
};

/// <summary>
/// A RenderTarget is a buffer that allows you to render a Node into a texture.
/// </summary>
object class RenderTarget
{
	/// <summary>
	/// The width of the rendering target.
	/// </summary>
	readonly common uint16_t width;
	/// <summary>
	/// The height of the rendering target.
	/// </summary>
	readonly common uint16_t height;
	/// <summary>
	/// The camera used for rendering the scene.
	/// </summary>
	optional common Camera* camera;
	/// <summary>
	/// The texture generated by the rendering target.
	/// </summary>
	readonly common Texture2D* texture;
	/// <summary>
	/// Renders a node to the target without replacing its previous contents.
	/// </summary>
	/// <param name="target">The node to be rendered onto the render target.</param>
	void render(Node* target);
	/// <summary>
	/// Clears the previous color, depth and stencil values on the render target.
	/// </summary>
	/// <param name="color">The clear color used to clear the render target.</param>
	/// <param name="depth">Optional. The value used to clear the depth buffer of the render target. Default is 1.</param>
	/// <param name="stencil">Optional. The value used to clear the stencil buffer of the render target. Default is 0.</param>
	void renderWithClear @ renderClear(Color color, float depth = 1.0f, uint8_t stencil = 0.0f);
	/// <summary>
	/// Renders a node to the target after clearing the previous color, depth and stencil values on it.
	/// </summary>
	/// <param name="target">The node to be rendered onto the render target.</param>
	/// <param name="color">The clear color used to clear the render target.</param>
	/// <param name="depth">The value used to clear the depth buffer of the render target. Default can be 1.</param>
	/// <param name="stencil">The value used to clear the stencil buffer of the render target. Default can be 0.</param>
	void renderWithClear @ renderClearWithTarget(Node* target, Color color, float depth = 1.0f, uint8_t stencil = 0.0f);
	/// <summary>
	/// Saves the contents of the render target to a PNG file asynchronously.
	/// </summary>
	/// <param name="filename">The name of the file to save the contents to.</param>
	/// <param name="handler">The function to call when the save operation is complete. The function will be passed a boolean value indicating whether the save operation was successful.</param>
	void saveAsync(string filename, function<void(bool success)> handler);
	static RenderTarget* create(uint16_t width, uint16_t height);
};

/// <summary>
/// A Node that can clip its children based on the alpha values of its stencil.
/// </summary>
object class ClipNode : public Node
{
	/// <summary>
	/// The stencil Node that defines the clipping shape.
	/// </summary>
	common Node* stencil;
	/// <summary>
	/// The minimum alpha threshold for a pixel to be visible. Value ranges from 0 to 1.
	/// </summary>
	common float alphaThreshold;
	/// <summary>
	/// Whether to invert the clipping area.
	/// </summary>
	boolean bool inverted;
	/// <summary>
	/// Creates a new ClipNode object.
	/// </summary>
	/// <param name="stencil">The stencil Node that defines the clipping shape.</param>
	static ClipNode* create(Node* stencil);
};

value struct VertexColor
{
	Vec2 vertex;
	Color color;
	static VertexColor create(Vec2 vec, Color color);
};

/// <summary>
/// A scene node that draws simple shapes such as dots, lines, and polygons.
/// </summary>
object class DrawNode : public Node
{
	/// <summary>
	/// Whether to write to the depth buffer when drawing (default is false).
	/// </summary>
	boolean bool depthWrite;
	/// <summary>
	/// The blend function for the draw node.
	/// </summary>
	common BlendFunc blendFunc;
	/// <summary>
	/// Draws a dot at a specified position with a specified radius and color.
	/// </summary>
	/// <param name="pos">The position of the dot.</param>
	/// <param name="radius">The radius of the dot.</param>
	/// <param name="color">The color of the dot.</param>
	void drawDot(Vec2 pos, float radius, Color color);
	/// <summary>
	/// Draws a line segment between two points with a specified radius and color.
	/// </summary>
	/// <param name="from">The starting point of the line.</param>
	/// <param name="to">The ending point of the line.</param>
	/// <param name="radius">The radius of the line.</param>
	/// <param name="color">The color of the line.</param>
	void drawSegment(Vec2 from, Vec2 to, float radius, Color color);
	/// <summary>
	/// Draws a polygon defined by a list of vertices with a specified fill color and border.
	/// </summary>
	/// <param name="verts">The vertices of the polygon.</param>
	/// <param name="fillColor">The fill color of the polygon.</param>
	/// <param name="borderWidth">The width of the border.</param>
	/// <param name="borderColor">The color of the border.</param>
	void drawPolygon(VecVec2 verts, Color fillColor, float borderWidth, Color borderColor);
	/// <summary>
	/// Draws a set of vertices as triangles, each vertex with its own color.
	/// </summary>
	/// <param name="verts">The list of vertices and their colors. Each element is a tuple where the first element is a `Vec2` and the second element is a `Color`.</param>
	void drawVertices(VecVertexColor verts);
	/// <summary>
	/// Clears all previously drawn shapes from the node.
	/// </summary>
	void clear();
	/// <summary>
	/// Creates a new DrawNode object.
	/// </summary>
	static DrawNode* create();
};

/// <summary>
/// A struct provides functionality for drawing lines using vertices.
/// </summary>
object class Line : public Node
{
	/// <summary>
	/// Whether the depth should be written. (Default is false)
	/// </summary>
	boolean bool depthWrite;
	/// <summary>
	/// The blend function for the line node.
	/// </summary>
	common BlendFunc blendFunc;
	/// <summary>
	/// Adds vertices to the line.
	/// </summary>
	/// <param name="verts">A vector of vertices to add to the line.</param>
	/// <param name="color">Optional. The color of the line.</param>
	void add(VecVec2 verts, Color color);
	/// <summary>
	/// Sets vertices of the line.
	/// </summary>
	/// <param name="verts">A vector of vertices to set.</param>
	/// <param name="color">Optional. The color of the line.</param>
	void set(VecVec2 verts, Color color);
	/// <summary>
	/// Clears all the vertices of line.
	/// </summary>
	void clear();
	/// <summary>
	/// Creates and returns a new empty Line object.
	/// </summary>
	static Line* create();
	/// <summary>
	/// Creates and returns a new Line object.
	/// </summary>
	/// <param name="verts">A vector of vertices to add to the line.</param>
	/// <param name="color">The color of the line.</param>
	static Line* create @ createVecColor(VecVec2 verts, Color color);
};

/// <summary>
/// Represents a particle system node that emits and animates particles.
/// </summary>
object class ParticleNode @ Particle : public Node
{
	/// <summary>
	/// Whether the particle system is active.
	/// </summary>
	readonly boolean bool active;
	/// <summary>
	/// Starts emitting particles.
	/// </summary>
	void start();
	/// <summary>
	/// Stops emitting particles and wait for all active particles to end their lives.
	/// </summary>
	void stop();
	/// <summary>
	/// Creates a new Particle object from a particle system file.
	/// </summary>
	/// <param name="filename">The file path of the particle system file.</param>
	static optional ParticleNode* create(string filename);
};

/// <summary>
/// An interface for an animation model system.
/// </summary>
object class Playable : public Node
{
	/// <summary>
	/// The look of the animation.
	/// </summary>
	common string look;
	/// <summary>
	/// The play speed of the animation.
	/// </summary>
	common float speed;
	/// <summary>
	/// The recovery time of the animation, in seconds.
	/// Used for doing transitions from one animation to another animation.
	/// </summary>
	common float recovery;
	/// <summary>
	/// Whether the animation is flipped horizontally.
	/// </summary>
	boolean bool fliped;
	/// <summary>
	/// The current playing animation name.
	/// </summary>
	readonly common string current;
	/// <summary>
	/// The last completed animation name.
	/// </summary>
	readonly common string lastCompleted;
	/// <summary>
	/// Gets a key point on the animation model by its name.
	/// </summary>
	/// <param name="name">The name of the key point to get.</param>
	Vec2 getKeyPoint @ getKey(string name);
	/// <summary>
	/// Plays an animation from the model.
	/// </summary>
	/// <param name="name">The name of the animation to play.</param>
	/// <param name="looping">Whether to loop the animation or not.</param>
	float play(string name, bool looping = false);
	/// <summary>
	/// Stops the currently playing animation.
	/// </summary>
	void stop();
	/// <summary>
	/// Attaches a child node to a slot on the animation model.
	/// </summary>
	/// <param name="name">The name of the slot to set.</param>
	/// <param name="item">The node to set the slot to.</param>
	void setSlot(string name, Node* item);
	/// <summary>
	/// Gets the child node attached to the animation model.
	/// </summary>
	/// <param name="name">The name of the slot to get.</param>
	optional Node* getSlot(string name);
	/// <summary>
	/// Creates a new instance of 'Playable' from the specified animation file.
	/// </summary>
	/// <param name="filename">The filename of the animation file to load. Supports DragonBone, Spine2D and Dora Model files.</param>
	static optional Playable* create(string filename);
};

/// <summary>
/// Another implementation of the 'Playable' animation interface.
/// </summary>
object class Model : public Playable
{
	/// <summary>
	/// The duration of the current animation.
	/// </summary>
	readonly common float duration;
	/// <summary>
	/// Whether the animation model will be played in reverse.
	/// </summary>
	boolean bool reversed;
	/// <summary>
	/// Whether the animation model is currently playing.
	/// </summary>
	readonly boolean bool playing;
	/// <summary>
	/// Whether the animation model is currently paused.
	/// </summary>
	readonly boolean bool paused;
	/// <summary>
	/// Checks if an animation exists in the model.
	/// </summary>
	/// <param name="name">The name of the animation to check.</param>
	/// <returns>Whether the animation exists in the model or not.</returns>
	bool hasAnimation(string name);
	/// <summary>
	/// Pauses the currently playing animation.
	/// </summary>
	void pause();
	/// <summary>
	/// Resumes the currently paused animation,
	/// </summary>
	void resume();
	/// <summary>
	/// Resumes the currently paused animation, or plays a new animation if specified.
	/// </summary>
	/// <param name="name">The name of the animation to play.</param>
	/// <param name="looping">Whether to loop the animation or not.</param>
	void resume @ resumeAnimation(string name, bool looping = false);
	/// <summary>
	/// Resets the current animation to its initial state.
	/// </summary>
	void reset();
	/// <summary>
	/// Updates the animation to the specified time, and optionally in reverse.
	/// </summary>
	/// <param name="elapsed">The time to update to.</param>
	/// <param name="reversed">Whether to play the animation in reverse.</param>
	void updateTo(float elapsed, bool reversed = false);
	/// <summary>
	/// Gets the node with the specified name.
	/// </summary>
	/// <param name="name">The name of the node to get.</param>
	Node* getNodeByName(string name);
	/// <summary>
	/// Calls the specified function for each node in the model, and stops if the function returns `false`.
	/// </summary>
	/// <param name="visitorFunc">The function to call for each node.</param>
	/// <returns>Whether the function was called for all nodes or not.</returns>
	bool eachNode(function<def_false bool(Node* node)> visitorFunc);
	/// <summary>
	/// Creates a new instance of 'Model' from the specified model file.
	/// </summary>
	/// <param name="filename">The filename of the model file to load. Can be filename with or without extension like: "Model/item" or "Model/item.model".</param>
	static optional hide Model* create(string filename);
	/// <summary>
	/// Returns a new dummy instance of 'Model' that can do nothing.
	/// </summary>
	static Model* dummy();
	/// <summary>
	/// Gets the clip file from the specified model file.
	/// </summary>
	/// <param name="filename">The filename of the model file to search.</param>
	static outside string Model_GetClipFilename @ getClipFile(string filename);
	/// <summary>
	/// Gets an array of look names from the specified model file.
	/// </summary>
	/// <param name="filename">The filename of the model file to search.</param>
	static outside VecStr Model_GetLookNames @ getLooks(string filename);
	/// <summary>
	/// Gets an array of animation names from the specified model file.
	/// </summary>
	/// <param name="filename">The filename of the model file to search.</param>
	static outside VecStr Model_GetAnimationNames @ getAnimations(string filename);
};

/// <summary>
/// An implementation of an animation system using the Spine engine.
/// </summary>
object class Spine : public Playable
{
	/// <summary>
	/// Whether hit testing is enabled.
	/// </summary>
	boolean bool hitTestEnabled;
	/// <summary>
	/// Sets the rotation of a bone in the Spine skeleton.
	/// </summary>
	/// <param name="name">The name of the bone to rotate.</param>
	/// <param name="rotation">The amount to rotate the bone, in degrees.</param>
	/// <returns>Whether the rotation was successfully set or not.</returns>
	bool setBoneRotation(string name, float rotation);
	/// <summary>
	/// Checks if a point in space is inside the boundaries of the Spine skeleton.
	/// </summary>
	/// <param name="x">The x-coordinate of the point to check.</param>
	/// <param name="y">The y-coordinate of the point to check.</param>
	/// <returns>The name of the bone at the point, or `None` if there is no bone at the point.</returns>
	string containsPoint(float x, float y);
	/// <summary>
	/// Checks if a line segment intersects the boundaries of the instance and returns the name of the bone or slot at the intersection point, or `None` if no bone or slot is found.
	/// </summary>
	/// <param name="x1">The x-coordinate of the start point of the line segment.</param>
	/// <param name="y1">The y-coordinate of the start point of the line segment.</param>
	/// <param name="x2">The x-coordinate of the end point of the line segment.</param>
	/// <param name="y2">The y-coordinate of the end point of the line segment.</param>
	/// <returns>The name of the bone or slot at the intersection point, or `None` if no bone or slot is found.</returns>
	string intersectsSegment(float x1, float y1, float x2, float y2);
	/// <summary>
	/// Creates a new instance of 'Spine' using the specified skeleton file and atlas file.
	/// </summary>
	/// <param name="skelFile">The filename of the skeleton file to load.</param>
	/// <param name="atlasFile">The filename of the atlas file to load.</param>
	static optional Spine* create @ createFiles(string skelFile, string atlasFile);
	/// <summary>
	/// Creates a new instance of 'Spine' using the specified Spine string.
	/// </summary>
	/// <param name="spineStr">The Spine file string for the new instance. A Spine file string can be a file path with the target file extension like "Spine/item" or file paths with all the related files like "Spine/item.skel|Spine/item.atlas" or "Spine/item.json|Spine/item.atlas".</param>
	static optional hide Spine* create(string spineStr);
	/// <summary>
	/// Returns a list of available looks for the specified Spine2D file string.
	/// </summary>
	/// <param name="spineStr">The Spine2D file string to get the looks for.</param>
	static outside VecStr Spine_GetLookNames @ getLooks(string spineStr);
	/// <summary>
	/// Returns a list of available animations for the specified Spine2D file string.
	/// </summary>
	/// <param name="spineStr">The Spine2D file string to get the animations for.</param>
	static outside VecStr Spine_GetAnimationNames @ getAnimations(string spineStr);
};

/// <summary>
/// An implementation of the 'Playable' record using the DragonBones animation system.
/// </summary>
object class DragonBone : public Playable
{
	/// <summary>
	/// Whether hit testing is enabled.
	/// </summary>
	boolean bool hitTestEnabled;
	/// <summary>
	/// Checks if a point is inside the boundaries of the instance and returns the name of the bone or slot at that point, or `None` if no bone or slot is found.
	/// </summary>
	/// <param name="x">The x-coordinate of the point to check.</param>
	/// <param name="y">The y-coordinate of the point to check.</param>
	/// <returns>The name of the bone or slot at the point.</returns>
	string containsPoint(float x, float y);
	/// <summary>
	/// Checks if a line segment intersects the boundaries of the instance and returns the name of the bone or slot at the intersection point, or `None` if no bone or slot is found.
	/// </summary>
	/// <param name="x1">The x-coordinate of the start point of the line segment.</param>
	/// <param name="y1">The y-coordinate of the start point of the line segment.</param>
	/// <param name="x2">The x-coordinate of the end point of the line segment.</param>
	/// <param name="y2">The y-coordinate of the end point of the line segment.</param>
	/// <returns>The name of the bone or slot at the intersection point.</returns>
	string intersectsSegment(float x1, float y1, float x2, float y2);
	/// <summary>
	/// Creates a new instance of 'DragonBone' using the specified bone file and atlas file. This function only loads the first armature.
	/// </summary>
	/// <param name="boneFile">The filename of the bone file to load.</param>
	/// <param name="atlasFile">The filename of the atlas file to load.</param>
	static optional DragonBone* create @ createFiles(string boneFile, string atlasFile);
	/// <summary>
	/// Creates a new instance of 'DragonBone' using the specified bone string.
	/// </summary>
	/// <param name="boneStr">The DragonBone file string for the new instance. A DragonBone file string can be a file path with the target file extension like "DragonBone/item" or file paths with all the related files like "DragonBone/item_ske.json|DragonBone/item_tex.json". An armature name can be added following a separator of ';'. like "DragonBone/item;mainArmature" or "DragonBone/item_ske.json|DragonBone/item_tex.json;mainArmature".</param>
	static optional hide DragonBone* create(string boneStr);
	/// <summary>
	/// Returns a list of available looks for the specified DragonBone file string.
	/// </summary>
	/// <param name="boneStr">The DragonBone file string to get the looks for.</param>
	static outside VecStr DragonBone_GetLookNames @ getLooks(string boneStr);
	/// <summary>
	/// Returns a list of available animations for the specified DragonBone file string.
	/// </summary>
	/// <param name="boneStr">The DragonBone file string to get the animations for.</param>
	static outside VecStr DragonBone_GetAnimationNames @ getAnimations(string boneStr);
};

/// <summary>
/// A node used for aligning layout elements.
/// </summary>
object class AlignNode : public Node
{
	/// <summary>
	/// Sets the layout style of the node.
	/// </summary>
	/// <param name="style">The layout style to set.</param>
	void css(string style);
	/// <summary>
	/// Creates a new AlignNode object.
	/// </summary>
	/// <param name="isWindowRoot">Whether the node is a window root node. A window root node will automatically listen for window size change events and update the layout accordingly.</param>
	static AlignNode* create(bool isWindowRoot = false);
};

/// <summary>
/// A struct for playing Effekseer effects.
/// </summary>
object class EffekNode : public Node
{
	/// <summary>
	/// Plays an effect at the specified position.
	/// </summary>
	/// <param name="filename">The filename of the effect to play.</param>
	/// <param name="pos">The xy-position to play the effect at.</param>
	/// <param name="z">The z-position of the effect.</param>
	/// <returns>The handle of the effect.</returns>
	int play(string filename, Vec2 pos = new(), float z = 0.0f);
	/// <summary>
	/// Stops an effect with the specified handle.
	/// </summary>
	/// <param name="handle">The handle of the effect to stop.</param>
	void stop(int handle);
	/// <summary>
	/// Creates a new EffekNode object.
	/// </summary>
	/// <returns>A new EffekNode object.</returns>
	static EffekNode* create();
};

/// <summary>
/// The TileNode class to render Tilemaps from TMX file in game scene tree hierarchy.
/// </summary>
object class TileNode : public Node
{
	/// <summary>
	/// Whether the depth buffer should be written to when rendering the tilemap.
	/// </summary>
	boolean bool depthWrite;
	/// <summary>
	/// The blend function for the tilemap.
	/// </summary>
	common BlendFunc blendFunc;
	/// <summary>
	/// The tilemap shader effect.
	/// </summary>
	common SpriteEffect* effect;
	/// <summary>
	/// The texture filtering mode for the tilemap.
	/// </summary>
	common TextureFilter filter;
	/// <summary>
	/// Get the layer data by name from the tilemap.
	/// </summary>
	/// <param name="layerName">The name of the layer in the TMX file.</param>
	/// <returns>The layer data as a dictionary object.</returns>
	optional Dictionary* getLayer(string layerName) const;
	/// <summary>
	/// Creates a `TileNode` object that will render the tile layers from a TMX file.
	/// </summary>
	/// <param name="tmxFile">The TMX file for the tilemap. This should be a file created with the Tiled Map Editor (http://www.mapeditor.org) and must be in XML format.</param>
	static optional TileNode* create(string tmxFile);
	/// <summary>
	/// Creates a `TileNode` object that will render the specified tile layer from a TMX file.
	/// </summary>
	/// <param name="tmxFile">The TMX file for the tilemap. This should be a file created with the Tiled Map Editor (http://www.mapeditor.org) and must be in XML format.</param>
	/// <param name="layerName">The name of the layer in the TMX file.</param>
	static optional TileNode* create @ createWithLayer(string tmxFile, string layerName);
	/// <summary>
	/// Creates a `TileNode` object that will render the specified tile layers from a TMX file.
	/// </summary>
	/// <param name="tmxFile">The TMX file for the tilemap. This should be a file created with the Tiled Map Editor (http://www.mapeditor.org) and must be in XML format.</param>
	/// <param name="layerNames">A vector of names of the layers in the TMX file.</param>
	static optional TileNode* create @ createWithLayers(string tmxFile, VecStr layerNames);
};

/// <summary>
/// A struct that represents a physics world in the game.
/// </summary>
object class PhysicsWorld : public Node
{
	/// <summary>
	/// Queries the physics world for all bodies that intersect with the specified rectangle.
	/// </summary>
	/// <param name="rect">The rectangle to query for bodies.</param>
	/// <param name="handler">A function that is called for each body found in the query. The function takes a `Body` as an argument and returns a `bool` indicating whether to continue querying for more bodies. Return `false` to continue, `true` to stop.</param>
	/// <returns>Whether the query was interrupted. `true` means interrupted, `false` otherwise.</returns>
	bool query(Rect rect, function<def_false bool(Body* body)> handler);
	/// <summary>
	/// Casts a ray through the physics world and finds the first body that intersects with the ray.
	/// </summary>
	/// <param name="start">The starting point of the ray.</param>
	/// <param name="stop">The ending point of the ray.</param>
	/// <param name="closest">Whether to stop ray casting upon the closest body that intersects with the ray. Set `closest` to `true` to get a faster ray casting search.</param>
	/// <param name="handler">A function that is called for each body found in the raycast. The function takes a `Body`, a `Vec2` representing the point where the ray intersects with the body, and a `Vec2` representing the normal vector at the point of intersection as arguments, and returns a `bool` indicating whether to continue casting the ray for more bodies. Return `false` to continue, `true` to stop.</param>
	/// <returns>Whether the raycast was interrupted. `true` means interrupted, `false` otherwise.</returns>
	bool raycast(Vec2 start, Vec2 stop, bool closest, function<def_false bool(Body* body, Vec2 point, Vec2 normal)> handler);
	/// <summary>
	/// Sets the number of velocity and position iterations to perform in the physics world.
	/// </summary>
	/// <param name="velocityIter">The number of velocity iterations to perform.</param>
	/// <param name="positionIter">The number of position iterations to perform.</param>
	void setIterations(int velocityIter, int positionIter);
	/// <summary>
	/// Sets whether two physics groups should make contact with each other or not.
	/// </summary>
	/// <param name="groupA">The first physics group.</param>
	/// <param name="groupB">The second physics group.</param>
	/// <param name="contact">Whether the two groups should make contact with each other.</param>
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	/// <summary>
	/// Gets whether two physics groups should make contact with each other or not.
	/// </summary>
	/// <param name="groupA">The first physics group.</param>
	/// <param name="groupB">The second physics group.</param>
	/// <returns>Whether the two groups should make contact with each other.</returns>
	bool getShouldContact(uint8_t groupA, uint8_t groupB);
	/// <summary>
	/// The factor used for converting physics engine meters value to pixel value.
	/// Default 100.0 is a good value since the physics engine can well simulate real life objects
	/// between 0.1 to 10 meters. Use value 100.0 we can simulate game objects
	/// between 10 to 1000 pixels that suite most games.
	/// You can change this value before any physics body creation.
	/// </summary>
	static float scaleFactor;
	/// <summary>
	/// Creates a new `PhysicsWorld` object.
	/// </summary>
	static PhysicsWorld* create();
};

object class FixtureDef { };

/// <summary>
/// A struct to describe the properties of a physics body.
/// </summary>
object class BodyDef
{
	/// <summary>
	/// The define for the type of the body.
	/// </summary>
	BodyType type;
	/// <summary>
	/// Define for the position of the body.
	/// </summary>
	Vec2 offset @ position;
	/// <summary>
	/// Define for the angle of the body.
	/// </summary>
	float angleOffset @ angle;
	/// <summary>
	/// Define for the face image or other items accepted by creating `Face` for the body.
	/// </summary>
	string face;
	/// <summary>
	/// Define for the face position of the body.
	/// </summary>
	Vec2 facePos;
	/// <summary>
	/// Define for linear damping of the body.
	/// </summary>
	common float linearDamping;
	/// <summary>
	/// Define for angular damping of the body.
	/// </summary>
	common float angularDamping;
	/// <summary>
	/// Define for initial linear acceleration of the body.
	/// </summary>
	common Vec2 linearAcceleration;
	/// <summary>
	/// Whether the body's rotation is fixed or not.
	/// </summary>
	boolean bool fixedRotation;
	/// <summary>
	/// Whether the body is a bullet or not.
	/// Set to true to add extra bullet movement check for the body.
	/// </summary>
	boolean bool bullet;
	/// <summary>
	/// Creates a polygon fixture definition with the specified dimensions and center position.
	/// </summary>
	/// <param name="center">The center point of the polygon.</param>
	/// <param name="width">The width of the polygon.</param>
	/// <param name="height">The height of the polygon.</param>
	/// <param name="angle">The angle of the polygon.</param>
	/// <param name="density">The density of the polygon.</param>
	/// <param name="friction">The friction of the polygon. Should be between 0 and 1.0.</param>
	/// <param name="restitution">The restitution of the polygon. Should be between 0 and 1.</param>
	static FixtureDef* polygon @ polygonWithCenter(
		Vec2 center,
		float width,
		float height,
		float angle = 0.0f,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Creates a polygon fixture definition with the specified dimensions.
	/// </summary>
	/// <param name="width">The width of the polygon.</param>
	/// <param name="height">The height of the polygon.</param>
	/// <param name="density">The density of the polygon.</param>
	/// <param name="friction">The friction of the polygon. Should be between 0 and 1.0.</param>
	/// <param name="restitution">The restitution of the polygon. Should be between 0 and 1.</param>
	static FixtureDef* polygon(
		float width,
		float height,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Creates a polygon fixture definition with the specified vertices.
	/// </summary>
	/// <param name="vertices">The vertices of the polygon.</param>
	/// <param name="density">The density of the polygon.</param>
	/// <param name="friction">The friction of the polygon. Should be between 0 and 1.0.</param>
	/// <param name="restitution">The restitution of the polygon. Should be between 0 and 1.0.</param>
	static FixtureDef* polygon @ polygonWithVertices(
		VecVec2 vertices,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Attaches a polygon fixture definition to the body.
	/// </summary>
	/// <param name="center">The center point of the polygon.</param>
	/// <param name="width">The width of the polygon.</param>
	/// <param name="height">The height of the polygon.</param>
	/// <param name="angle">The angle of the polygon.</param>
	/// <param name="density">The density of the polygon.</param>
	/// <param name="friction">The friction of the polygon. Should be between 0 and 1.0.</param>
	/// <param name="restitution">The restitution of the polygon. Should be between 0 and 1.0.</param>
	void attachPolygon @ attachPolygonWithCenter(
		Vec2 center,
		float width,
		float height,
		float angle = 0.0f,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Attaches a polygon fixture definition to the body.
	/// </summary>
	/// <param name="width">The width of the polygon.</param>
	/// <param name="height">The height of the polygon.</param>
	/// <param name="density">The density of the polygon.</param>
	/// <param name="friction">The friction of the polygon. Should be between 0 and 1.0.</param>
	/// <param name="restitution">The restitution of the polygon. Should be between 0 and 1.0.</param>
	void attachPolygon(
		float width,
		float height,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Attaches a polygon fixture definition to the body.
	/// </summary>
	/// <param name="vertices">The vertices of the polygon.</param>
	/// <param name="density">The density of the polygon.</param>
	/// <param name="friction">The friction of the polygon. Should be between 0 and 1.0.</param>
	/// <param name="restitution">The restitution of the polygon. Should be between 0 and 1.0.</param>
	void attachPolygon @ attachPolygonWithVertices(
		VecVec2 vertices,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Creates a concave shape definition made of multiple convex shapes.
	/// </summary>
	/// <param name="vertices">A vector containing the vertices of each convex shape that makes up the concave shape. Each convex shape in the vertices vector should end with a `Vec2(0.0, 0.0)` as separator.</param>
	/// <param name="density">The density of the shape.</param>
	/// <param name="friction">The friction coefficient of the shape. Should be between 0.0 and 1.0.</param>
	/// <param name="restitution">The restitution (elasticity) of the shape. Should be between 0.0 and 1.0.</param>
	/// <returns>The resulting fixture definition.</returns>
	static FixtureDef* multi(
		VecVec2 vertices,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Attaches a concave shape definition made of multiple convex shapes to the body.
	/// </summary>
	/// <param name="vertices">A vector containing the vertices of each convex shape that makes up the concave shape. Each convex shape in the vertices vector should end with a `Vec2(0.0, 0.0)` as separator.</param>
	/// <param name="density">The density of the concave shape.</param>
	/// <param name="friction">The friction of the concave shape. Should be between 0.0 and 1.0.</param>
	/// <param name="restitution">The restitution of the concave shape. Should be between 0.0 and 1.0.</param>
	void attachMulti(
		VecVec2 vertices,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Creates a Disk-shape fixture definition.
	/// </summary>
	/// <param name="center">The center of the circle.</param>
	/// <param name="radius">The radius of the circle.</param>
	/// <param name="density">The density of the circle.</param>
	/// <param name="friction">The friction coefficient of the circle. Should be between 0.0 and 1.0.</param>
	/// <param name="restitution">The restitution (elasticity) of the circle. Should be between 0.0 and 1.0.</param>
	/// <returns>The resulting fixture definition.</returns>
	static FixtureDef* disk @ diskWithCenter(
		Vec2 center,
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Creates a Disk-shape fixture definition.
	/// </summary>
	/// <param name="radius">The radius of the circle.</param>
	/// <param name="density">The density of the circle.</param>
	/// <param name="friction">The friction coefficient of the circle. Should be between 0.0 and 1.0.</param>
	/// <param name="restitution">The restitution (elasticity) of the circle. Should be between 0.0 and 1.0.</param>
	/// <returns>The resulting fixture definition.</returns>
	static FixtureDef* disk(
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Attaches a disk fixture definition to the body.
	/// </summary>
	/// <param name="center">The center point of the disk.</param>
	/// <param name="radius">The radius of the disk.</param>
	/// <param name="density">The density of the disk.</param>
	/// <param name="friction">The friction of the disk. Should be between 0.0 and 1.0.</param>
	/// <param name="restitution">The restitution of the disk. Should be between 0.0 and 1.0.</param>
	void attachDisk @ attachDiskWithCenter(
		Vec2 center,
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Attaches a disk fixture definition to the body.
	/// </summary>
	/// <param name="radius">The radius of the disk.</param>
	/// <param name="density">The density of the disk.</param>
	/// <param name="friction">The friction of the disk. Should be between 0.0 and 1.0.</param>
	/// <param name="restitution">The restitution of the disk. Should be between 0.0 and 1.0.</param>
	void attachDisk(
		float radius,
		float density = 0.0f,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Creates a Chain-shape fixture definition. This fixture is a free form sequence of line segments that has two-sided collision.
	/// </summary>
	/// <param name="vertices">The vertices of the chain.</param>
	/// <param name="friction">The friction coefficient of the chain. Should be between 0.0 and 1.0.</param>
	/// <param name="restitution">The restitution (elasticity) of the chain. Should be between 0.0 and 1.0.</param>
	/// <returns>The resulting fixture definition.</returns>
	static FixtureDef* chain(
		VecVec2 vertices,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Attaches a chain fixture definition to the body. The Chain fixture is a free form sequence of line segments that has two-sided collision.
	/// </summary>
	/// <param name="vertices">The vertices of the chain.</param>
	/// <param name="friction">The friction of the chain. Should be between 0.0 and 1.0.</param>
	/// <param name="restitution">The restitution of the chain. Should be between 0.0 and 1.0.</param>
	void attachChain(
		VecVec2 vertices,
		float friction = 0.4f,
		float restitution = 0.0f);
	/// <summary>
	/// Attaches a polygon sensor fixture definition to the body.
	/// </summary>
	/// <param name="tag">An integer tag for the sensor.</param>
	/// <param name="width">The width of the polygon.</param>
	/// <param name="height">The height of the polygon.</param>
	void attachPolygonSensor(
		int tag,
		float width,
		float height);
	/// <summary>
	/// Attaches a polygon sensor fixture definition to the body.
	/// </summary>
	/// <param name="tag">An integer tag for the sensor.</param>
	/// <param name="center">The center point of the polygon.</param>
	/// <param name="width">The width of the polygon.</param>
	/// <param name="height">The height of the polygon.</param>
	/// <param name="angle">Optional. The angle of the polygon.</param>
	void attachPolygonSensor @ attachPolygonSensorWithCenter(
		int tag,
		Vec2 center,
		float width,
		float height,
		float angle = 0.0f);
	/// <summary>
	/// Attaches a polygon sensor fixture definition to the body.
	/// </summary>
	/// <param name="tag">An integer tag for the sensor.</param>
	/// <param name="vertices">A vector containing the vertices of the polygon.</param>
	void attachPolygonSensor @ attachPolygonSensorWithVertices(
		int tag,
		VecVec2 vertices);
	/// <summary>
	/// Attaches a disk sensor fixture definition to the body.
	/// </summary>
	/// <param name="tag">An integer tag for the sensor.</param>
	/// <param name="center">The center of the disk.</param>
	/// <param name="radius">The radius of the disk.</param>
	void attachDiskSensor @ attachDiskSensorWithCenter(
		int tag,
		Vec2 center,
		float radius);
	/// <summary>
	/// Attaches a disk sensor fixture definition to the body.
	/// </summary>
	/// <param name="tag">An integer tag for the sensor.</param>
	/// <param name="radius">The radius of the disk.</param>
	void attachDiskSensor(
		int tag,
		float radius);
	/// <summary>
	/// Creates a new instance of `BodyDef` class.
	/// </summary>
	static BodyDef* create();
};

/// <summary>
/// A struct to represent a physics sensor object in the game world.
/// </summary>
object class Sensor
{
	/// <summary>
	/// Whether the sensor is currently enabled or not.
	/// </summary>
	boolean bool enabled;
	/// <summary>
	/// The tag for the sensor.
	/// </summary>
	readonly common int tag;
	/// <summary>
	/// The "Body" object that owns the sensor.
	/// </summary>
	readonly common Body* owner;
	/// <summary>
	/// Whether the sensor is currently sensing any other "Body" objects in the game world.
	/// </summary>
	readonly boolean bool sensed;
	/// <summary>
	/// The array of "Body" objects that are currently being sensed by the sensor.
	/// </summary>
	readonly common Array* sensedBodies;
	/// <summary>
	/// Determines whether the specified `Body` object is currently being sensed by the sensor.
	/// </summary>
	/// <param name="body">The `Body` object to check if it is being sensed.</param>
	/// <returns>`true` if the `Body` object is being sensed by the sensor, `false` otherwise.</returns>
	bool contains(Body* body);
};

/// <summary>
/// A struct represents a physics body in the world.
/// </summary>
object class Body : public Node
{
	/// <summary>
	/// The physics world that the body belongs to.
	/// </summary>
	readonly common PhysicsWorld* physicsWorld @ world;
	/// <summary>
	/// The definition of the body.
	/// </summary>
	readonly common BodyDef* bodyDef;
	/// <summary>
	/// The mass of the body.
	/// </summary>
	readonly common float mass;
	/// <summary>
	/// Whether the body is used as a sensor or not.
	/// </summary>
	readonly boolean bool sensor;
	/// <summary>
	/// The x-axis velocity of the body.
	/// </summary>
	common float velocityX;
	/// <summary>
	/// The y-axis velocity of the body.
	/// </summary>
	common float velocityY;
	/// <summary>
	/// The velocity of the body as a `Vec2`.
	/// </summary>
	common Vec2 velocity;
	/// <summary>
	/// The angular rate of the body.
	/// </summary>
	common float angularRate;
	/// <summary>
	/// The collision group that the body belongs to.
	/// </summary>
	common uint8_t group;
	/// <summary>
	/// The linear damping of the body.
	/// </summary>
	common float linearDamping;
	/// <summary>
	/// The angular damping of the body.
	/// </summary>
	common float angularDamping;
	/// <summary>
	/// The reference for an owner of the body.
	/// </summary>
	common Object* owner;
	/// <summary>
	/// Whether the body is currently receiving contact events or not.
	/// </summary>
	boolean bool receivingContact;
	/// <summary>
	/// Applies a linear impulse to the body at a specified position.
	/// </summary>
	/// <param name="impulse">The linear impulse to apply.</param>
	/// <param name="pos">The position at which to apply the impulse.</param>
	void applyLinearImpulse(Vec2 impulse, Vec2 pos);
	/// <summary>
	/// Applies an angular impulse to the body.
	/// </summary>
	/// <param name="impulse">The angular impulse to apply.</param>
	void applyAngularImpulse(float impulse);
	/// <summary>
	/// Returns the sensor with the given tag.
	/// </summary>
	/// <param name="tag">The tag of the sensor to get.</param>
	/// <returns>The sensor with the given tag.</returns>
	Sensor* getSensorByTag(int tag);
	/// <summary>
	/// Removes the sensor with the specified tag from the body.
	/// </summary>
	/// <param name="tag">The tag of the sensor to remove.</param>
	/// <returns>Whether a sensor with the specified tag was found and removed.</returns>
	bool removeSensorByTag(int tag);
	/// <summary>
	/// Removes the given sensor from the body's sensor list.
	/// </summary>
	/// <param name="sensor">The sensor to remove.</param>
	/// <returns>`true` if the sensor was successfully removed, `false` otherwise.</returns>
	bool removeSensor(Sensor* sensor);
	/// <summary>
	/// Attaches a fixture to the body.
	/// </summary>
	/// <param name="fixtureDef">The fixture definition for the fixture to attach.</param>
	void attach(FixtureDef* fixtureDef);
	/// <summary>
	/// Attaches a new sensor with the given tag and fixture definition to the body.
	/// </summary>
	/// <param name="tag">The tag of the sensor to attach.</param>
	/// <param name="fixtureDef">The fixture definition of the sensor.</param>
	/// <returns>The newly attached sensor.</returns>
	Sensor* attachSensor(int tag, FixtureDef* fixtureDef);
	/// <summary>
	/// Registers a function to be called when the body begins to receive contact events. Return `false` from this function to prevent colliding.
	/// </summary>
	/// <param name="filter">The filter function to set.</param>
	void onContactFilter(function<def_false bool(Body* body)> filter);
	/// <summary>
	/// Creates a new instance of `Body`.
	/// </summary>
	/// <param name="def">The definition for the body to be created.</param>
	/// <param name="world">The physics world where the body belongs.</param>
	/// <param name="pos">The initial position of the body.</param>
	/// <param name="rot">The initial rotation angle of the body in degrees.</param>
	static Body* create(BodyDef* def, PhysicsWorld* world, Vec2 pos = new(), float rot = 0.0f);
};

/// <summary>
/// A struct that defines the properties of a joint to be created.
/// </summary>
object class JointDef
{
	/// <summary>
	/// The center point of the joint, in local coordinates.
	/// </summary>
	Vec2 center;
	/// <summary>
	/// The position of the joint, in world coordinates.
	/// </summary>
	Vec2 position;
	/// <summary>
	/// The angle of the joint, in degrees.
	/// </summary>
	float angle;
	/// <summary>
	/// Creates a distance joint definition.
	/// </summary>
	/// <param name="collision">Whether or not the physics body connected to joint will collide with each other.</param>
	/// <param name="bodyA">The name of first physics body to connect with the joint.</param>
	/// <param name="bodyB">The name of second physics body to connect with the joint.</param>
	/// <param name="anchorA">The position of the joint on the first physics body.</param>
	/// <param name="anchorB">The position of the joint on the second physics body.</param>
	/// <param name="frequency">The frequency of the joint, in Hertz.</param>
	/// <param name="damping">The damping ratio of the joint.</param>
	/// <returns>The new joint definition.</returns>
	static JointDef* distance(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float frequency = 0.0f,
		float damping = 0.0f);
	/// <summary>
	/// Creates a friction joint definition.
	/// </summary>
	/// <param name="collision">Whether or not the physics body connected to joint will collide with each other.</param>
	/// <param name="bodyA">The first physics body to connect with the joint.</param>
	/// <param name="bodyB">The second physics body to connect with the joint.</param>
	/// <param name="worldPos">The position of the joint in the game world.</param>
	/// <param name="maxForce">The maximum force that can be applied to the joint.</param>
	/// <param name="maxTorque">The maximum torque that can be applied to the joint.</param>
	/// <returns>The new friction joint definition.</returns>
	static JointDef* friction(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float maxForce,
		float maxTorque);
	/// <summary>
	/// Creates a gear joint definition.
	/// </summary>
	/// <param name="collision">Whether or not the physics bodies connected to the joint can collide with each other.</param>
	/// <param name="jointA">The first joint to connect with the gear joint.</param>
	/// <param name="jointB">The second joint to connect with the gear joint.</param>
	/// <param name="ratio">The gear ratio.</param>
	/// <returns>The new gear joint definition.</returns>
	static JointDef* gear(
		bool collision,
		string jointA,
		string jointB,
		float ratio = 1.0f);
	/// <summary>
	/// Creates a new spring joint definition.
	/// </summary>
	/// <param name="collision">Whether the connected bodies should collide with each other.</param>
	/// <param name="bodyA">The first body connected to the joint.</param>
	/// <param name="bodyB">The second body connected to the joint.</param>
	/// <param name="linearOffset">Position of body-B minus the position of body-A, in body-A's frame.</param>
	/// <param name="angularOffset">Angle of body-B minus angle of body-A.</param>
	/// <param name="maxForce">The maximum force the joint can exert.</param>
	/// <param name="maxTorque">The maximum torque the joint can exert.</param>
	/// <param name="correctionFactor">Correction factor. 0.0 = no correction, 1.0 = full correction.</param>
	/// <returns>The created joint definition.</returns>
	static JointDef* spring(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor = 1.0f);
	/// <summary>
	/// Creates a new prismatic joint definition.
	/// </summary>
	/// <param name="collision">Whether the connected bodies should collide with each other.</param>
	/// <param name="bodyA">The first body connected to the joint.</param>
	/// <param name="bodyB">The second body connected to the joint.</param>
	/// <param name="worldPos">The world position of the joint.</param>
	/// <param name="axisAngle">The axis angle of the joint.</param>
	/// <param name="lowerTranslation">Lower translation limit.</param>
	/// <param name="upperTranslation">Upper translation limit.</param>
	/// <param name="maxMotorForce">Maximum motor force.</param>
	/// <param name="motorSpeed">Motor speed.</param>
	/// <returns>The created prismatic joint definition.</returns>
	static JointDef* prismatic(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float axisAngle,
		float lowerTranslation = 0.0f,
		float upperTranslation = 0.0f,
		float maxMotorForce = 0.0f,
		float motorSpeed = 0.0f);
	/// <summary>
	/// Creates a pulley joint definition.
	/// </summary>
	/// <param name="collision">Whether or not the connected bodies will collide with each other.</param>
	/// <param name="bodyA">The first physics body to connect.</param>
	/// <param name="bodyB">The second physics body to connect.</param>
	/// <param name="anchorA">The position of the anchor point on the first body.</param>
	/// <param name="anchorB">The position of the anchor point on the second body.</param>
	/// <param name="groundAnchorA">The position of the ground anchor point on the first body in world coordinates.</param>
	/// <param name="groundAnchorB">The position of the ground anchor point on the second body in world coordinates.</param>
	/// <param name="ratio">The pulley ratio.</param>
	/// <returns>The pulley joint definition.</returns>
	static JointDef* pulley(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		Vec2 groundAnchorA,
		Vec2 groundAnchorB,
		float ratio = 1.0f);
	/// <summary>
	/// Creates a revolute joint definition.
	/// </summary>
	/// <param name="collision">Whether or not the connected bodies will collide with each other.</param>
	/// <param name="bodyA">The first physics body to connect.</param>
	/// <param name="bodyB">The second physics body to connect.</param>
	/// <param name="worldPos">The position in world coordinates where the joint will be created.</param>
	/// <param name="lowerAngle">The lower angle limit in radians.</param>
	/// <param name="upperAngle">The upper angle limit in radians.</param>
	/// <param name="maxMotorTorque">The maximum torque that can be applied to the joint to achieve the target speed.</param>
	/// <param name="motorSpeed">The desired speed of the joint.</param>
	/// <returns>The revolute joint definition.</returns>
	static JointDef* revolute(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float lowerAngle = 0.0f,
		float upperAngle = 0.0f,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f);
	/// <summary>
	/// Creates a rope joint definition.
	/// </summary>
	/// <param name="collision">Whether or not the connected bodies will collide with each other.</param>
	/// <param name="bodyA">The first physics body to connect.</param>
	/// <param name="bodyB">The second physics body to connect.</param>
	/// <param name="anchorA">The position of the anchor point on the first body.</param>
	/// <param name="anchorB">The position of the anchor point on the second body.</param>
	/// <param name="maxLength">The maximum distance between the anchor points.</param>
	/// <returns>The rope joint definition.</returns>
	static JointDef* rope(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float maxLength);
	/// <summary>
	/// Creates a weld joint definition.
	/// </summary>
	/// <param name="collision">Whether or not the bodies connected to the joint can collide with each other.</param>
	/// <param name="bodyA">The first body to be connected by the joint.</param>
	/// <param name="bodyB">The second body to be connected by the joint.</param>
	/// <param name="worldPos">The position in the world to connect the bodies together.</param>
	/// <param name="frequency">The frequency at which the joint should be stiff.</param>
	/// <param name="damping">The damping rate of the joint.</param>
	/// <returns>The newly created weld joint definition.</returns>
	static JointDef* weld(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float frequency = 0.0f,
		float damping = 0.0f);
	/// <summary>
	/// Creates a wheel joint definition.
	/// </summary>
	/// <param name="collision">Whether or not the bodies connected to the joint can collide with each other.</param>
	/// <param name="bodyA">The first body to be connected by the joint.</param>
	/// <param name="bodyB">The second body to be connected by the joint.</param>
	/// <param name="worldPos">The position in the world to connect the bodies together.</param>
	/// <param name="axisAngle">The angle of the joint axis in radians.</param>
	/// <param name="maxMotorTorque">The maximum torque the joint motor can exert.</param>
	/// <param name="motorSpeed">The target speed of the joint motor.</param>
	/// <param name="frequency">The frequency at which the joint should be stiff.</param>
	/// <param name="damping">The damping rate of the joint.</param>
	/// <returns>The newly created wheel joint definition.</returns>
	static JointDef* wheel(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float axisAngle,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f,
		float frequency = 2.0f,
		float damping = 0.7f);
};

/// <summary>
/// A struct that can be used to connect physics bodies together.
/// </summary>
object class Joint
{
	/// <summary>
	/// Creates a distance joint between two physics bodies.
	/// </summary>
	/// <param name="can_collide">Whether or not the physics body connected to joint will collide with each other.</param>
	/// <param name="body_a">The first physics body to connect with the joint.</param>
	/// <param name="body_b">The second physics body to connect with the joint.</param>
	/// <param name="anchor_a">The position of the joint on the first physics body.</param>
	/// <param name="anchor_b">The position of the joint on the second physics body.</param>
	/// <param name="frequency">The frequency of the joint, in Hertz.</param>
	/// <param name="damping">The damping ratio of the joint.</param>
	/// <returns>The new distance joint.</returns>
	static Joint* distance(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float frequency = 0.0f,
		float damping = 0.0f);
	/// <summary>
	/// Creates a friction joint between two physics bodies.
	/// </summary>
	/// <param name="can_collide">Whether or not the physics body connected to joint will collide with each other.</param>
	/// <param name="body_a">The first physics body to connect with the joint.</param>
	/// <param name="body_b">The second physics body to connect with the joint.</param>
	/// <param name="world_pos">The position of the joint in the game world.</param>
	/// <param name="max_force">The maximum force that can be applied to the joint.</param>
	/// <param name="max_torque">The maximum torque that can be applied to the joint.</param>
	/// <returns>The new friction joint.</returns>
	static Joint* friction(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float maxForce,
		float maxTorque);
	/// <summary>
	/// Creates a gear joint between two other joints.
	/// </summary>
	/// <param name="can_collide">Whether or not the physics bodies connected to the joint can collide with each other.</param>
	/// <param name="joint_a">The first joint to connect with the gear joint.</param>
	/// <param name="joint_b">The second joint to connect with the gear joint.</param>
	/// <param name="ratio">The gear ratio.</param>
	/// <returns>The new gear joint.</returns>
	static Joint* gear(
		bool collision,
		Joint* jointA,
		Joint* jointB,
		float ratio = 1.0f);
	/// <summary>
	/// Creates a new spring joint between the two specified bodies.
	/// </summary>
	/// <param name="collision">Whether the connected bodies should collide with each other.</param>
	/// <param name="bodyA">The first body connected to the joint.</param>
	/// <param name="bodyB">The second body connected to the joint.</param>
	/// <param name="linearOffset">Position of body-B minus the position of body-A, in body-A's frame.</param>
	/// <param name="angularOffset">Angle of body-B minus angle of body-A.</param>
	/// <param name="maxForce">The maximum force the joint can exert.</param>
	/// <param name="maxTorque">The maximum torque the joint can exert.</param>
	/// <param name="correctionFactor">Correction factor. 0.0 = no correction, 1.0 = full correction.</param>
	/// <returns>The created joint.</returns>
	static Joint* spring(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor = 1.0f);
	/// <summary>
	/// Creates a new move joint for the specified body.
	/// </summary>
	/// <param name="collision">Whether the body can collide with other bodies.</param>
	/// <param name="body">The body that the joint is attached to.</param>
	/// <param name="targetPos">The target position that the body should move towards.</param>
	/// <param name="maxForce">The maximum force the joint can exert.</param>
	/// <param name="frequency">Frequency ratio.</param>
	/// <param name="damping">Damping ratio.</param>
	/// <returns>The created move joint.</returns>
	static MoveJoint* move @ moveTarget(
		bool collision,
		Body* body,
		Vec2 targetPos,
		float maxForce,
		float frequency = 5.0f,
		float damping = 0.7f);
	/// <summary>
	/// Creates a new prismatic joint between the two specified bodies.
	/// </summary>
	/// <param name="collision">Whether the connected bodies should collide with each other.</param>
	/// <param name="bodyA">The first body connected to the joint.</param>
	/// <param name="bodyB">The second body connected to the joint.</param>
	/// <param name="worldPos">The world position of the joint.</param>
	/// <param name="axisAngle">The axis angle of the joint.</param>
	/// <param name="lowerTranslation">Lower translation limit.</param>
	/// <param name="upperTranslation">Upper translation limit.</param>
	/// <param name="maxMotorForce">Maximum motor force.</param>
	/// <param name="motorSpeed">Motor speed.</param>
	/// <returns>The created prismatic joint.</returns>
	static MotorJoint* prismatic(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float axisAngle,
		float lowerTranslation = 0.0f,
		float upperTranslation = 0.0f,
		float maxMotorForce = 0.0f,
		float motorSpeed = 0.0f);
	/// <summary>
	/// Creates a pulley joint between two physics bodies.
	/// </summary>
	/// <param name="collision">Whether or not the connected bodies will collide with each other.</param>
	/// <param name="bodyA">The first physics body to connect.</param>
	/// <param name="bodyB">The second physics body to connect.</param>
	/// <param name="anchorA">The position of the anchor point on the first body.</param>
	/// <param name="anchorB">The position of the anchor point on the second body.</param>
	/// <param name="groundAnchorA">The position of the ground anchor point on the first body in world coordinates.</param>
	/// <param name="groundAnchorB">The position of the ground anchor point on the second body in world coordinates.</param>
	/// <param name="ratio">The pulley ratio.</param>
	/// <returns>The pulley joint.</returns>
	static Joint* pulley(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		Vec2 groundAnchorA,
		Vec2 groundAnchorB,
		float ratio = 1.0f);
	/// <summary>
	/// Creates a revolute joint between two physics bodies.
	/// </summary>
	/// <param name="collision">Whether or not the connected bodies will collide with each other.</param>
	/// <param name="bodyA">The first physics body to connect.</param>
	/// <param name="bodyB">The second physics body to connect.</param>
	/// <param name="worldPos">The position in world coordinates where the joint will be created.</param>
	/// <param name="lowerAngle">The lower angle limit in radians.</param>
	/// <param name="upperAngle">The upper angle limit in radians.</param>
	/// <param name="maxMotorTorque">The maximum torque that can be applied to the joint to achieve the target speed.</param>
	/// <param name="motorSpeed">The desired speed of the joint.</param>
	/// <returns>The revolute joint.</returns>
	static MotorJoint* revolute(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float lowerAngle = 0.0f,
		float upperAngle = 0.0f,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f);
	/// <summary>
	/// Creates a rope joint between two physics bodies.
	/// </summary>
	/// <param name="collision">Whether or not the connected bodies will collide with each other.</param>
	/// <param name="bodyA">The first physics body to connect.</param>
	/// <param name="bodyB">The second physics body to connect.</param>
	/// <param name="anchorA">The position of the anchor point on the first body.</param>
	/// <param name="anchorB">The position of the anchor point on the second body.</param>
	/// <param name="maxLength">The maximum distance between the anchor points.</param>
	/// <returns>The rope joint.</returns>
	static Joint* rope(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float maxLength);
	/// <summary>
	/// Creates a weld joint between two bodies.
	/// </summary>
	/// <param name="collision">Whether or not the bodies connected to the joint can collide with each other.</param>
	/// <param name="bodyA">The first body to be connected by the joint.</param>
	/// <param name="bodyB">The second body to be connected by the joint.</param>
	/// <param name="worldPos">The position in the world to connect the bodies together.</param>
	/// <param name="frequency">The frequency at which the joint should be stiff.</param>
	/// <param name="damping">The damping rate of the joint.</param>
	/// <returns>The newly created weld joint.</returns>
	static Joint* weld(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float frequency = 0.0f,
		float damping = 0.0f);
	/// <summary>
	/// Creates a wheel joint between two bodies.
	/// </summary>
	/// <param name="collision">Whether or not the bodies connected to the joint can collide with each other.</param>
	/// <param name="bodyA">The first body to be connected by the joint.</param>
	/// <param name="bodyB">The second body to be connected by the joint.</param>
	/// <param name="worldPos">The position in the world to connect the bodies together.</param>
	/// <param name="axisAngle">The angle of the joint axis in radians.</param>
	/// <param name="maxMotorTorque">The maximum torque the joint motor can exert.</param>
	/// <param name="motorSpeed">The target speed of the joint motor.</param>
	/// <param name="frequency">The frequency at which the joint should be stiff.</param>
	/// <param name="damping">The damping rate of the joint.</param>
	/// <returns>The newly created wheel joint.</returns>
	static MotorJoint* wheel(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float axisAngle,
		float maxMotorTorque = 0.0f,
		float motorSpeed = 0.0f,
		float frequency = 2.0f,
		float damping = 0.7f);
	/// <summary>
	/// the physics world that the joint belongs to.
	/// </summary>
	readonly common PhysicsWorld* physicsWorld @ world;
	/// <summary>
	/// Destroys the joint and removes it from the physics simulation.
	/// </summary>
	void destroy();
	/// <summary>
	/// Creates a joint instance based on the given joint definition and item dictionary containing physics bodies to be connected by joint.
	/// </summary>
	/// <param name="def">The joint definition.</param>
	/// <param name="itemDict">The dictionary containing all the bodies and other required items.</param>
	/// <returns>The newly created joint.</returns>
	static Joint* create(JointDef* def, Dictionary* itemDict);
};

/// <summary>
/// A type of joint that allows a physics body to move to a specific position.
/// </summary>
object class MoveJoint : public Joint
{
	/// <summary>
	/// The current position of the move joint in the game world.
	/// </summary>
	common Vec2 position;
};

/// <summary>
/// A joint that applies a rotational or linear force to a physics body.
/// </summary>
object class MotorJoint : public Joint
{
	/// <summary>
	/// Whether or not the motor joint is enabled.
	/// </summary>
	boolean bool enabled;
	/// <summary>
	/// The force applied to the motor joint.
	/// </summary>
	common float force;
	/// <summary>
	/// The speed of the motor joint.
	/// </summary>
	common float speed;
};

/// <summary>
/// A interface for managing various game resources.
/// </summary>
singleton struct Cache
{
	/// <summary>
	/// Loads a file into the cache with a blocking operation.
	/// </summary>
	/// <param name="filename">The name of the file to load.</param>
	/// <returns>`true` if the file was loaded successfully, `false` otherwise.</returns>
	static bool load(string filename);
	/// <summary>
	/// Loads a file into the cache asynchronously.
	/// </summary>
	/// <param name="filename">The name of the file to load.</param>
	/// <param name="handler">A callback function that is invoked when the file is loaded.</param>
	static void loadAsync(string filename, function<void(bool success)> handler);
	/// <summary>
	/// Updates the content of a file loaded in the cache.
	/// If the item of filename does not exist in the cache, a new file content will be added into the cache.
	/// </summary>
	/// <param name="filename">The name of the file to update.</param>
	/// <param name="content">The new content for the file.</param>
	static void update @ updateItem(string filename, string content);
	/// <summary>
	/// Updates the texture object of the specific filename loaded in the cache.
	/// If the texture object of filename does not exist in the cache, it will be added into the cache.
	/// </summary>
	/// <param name="filename">The name of the texture to update.</param>
	/// <param name="texture">The new texture object for the file.</param>
	static void update @ updateTexture(string filename, Texture2D* texture);
	/// <summary>
	/// Unloads a resource from the cache.
	/// </summary>
	/// <param name="name">The type name of resource to unload, could be one of "Texture", "SVG", "Clip", "Frame", "Model", "Particle", "Shader", "Font", "Sound", "Spine". Or the name of the resource file to unload.</param>
	/// <returns>`true` if the resource was unloaded successfully, `false` otherwise.</returns>
	static bool unload @ unloadItemOrType(string name);
	/// <summary>
	/// Unloads all resources from the cache.
	/// </summary>
	static void unload();
	/// <summary>
	/// Removes all unused resources (not being referenced) from the cache.
	/// </summary>
	static void removeUnused();
	/// <summary>
	/// Removes all unused resources of the given type from the cache.
	/// </summary>
	/// <param name="typeName">The type of resource to remove. This could be one of "Texture", "SVG", "Clip", "Frame", "Model", "Particle", "Shader", "Font", "Sound", "Spine".</param>
	static void removeUnused @ removeUnusedByType(string typeName);
};

/// <summary>
/// A interface of an audio player.
/// </summary>
singleton class Audio
{
	/// <summary>
	/// The speed of the 3D sound.
	/// </summary>
	common float soundSpeed;
	/// <summary>
	/// The global volume of the audio. The value is between 0.0 and 1.0.
	/// </summary>
	common float globalVolume;
	/// <summary>
	/// The 3D listener as a node of the audio.
	/// </summary>
	optional common Node* listener;
	/// <summary>
	/// Plays a sound effect and returns a handler for the audio.
	/// </summary>
	/// <param name="filename">The path to the sound effect file (must be a WAV file).</param>
	/// <param name="looping">Optional. Whether to loop the sound effect. Default is `false`.</param>
	/// <returns>A handler for the audio that can be used to stop the sound effect.</returns>
	uint32_t play(string filename, bool looping = false);
	/// <summary>
	/// Stops a sound effect that is currently playing.
	/// </summary>
	/// <param name="handle">The handler for the audio that is returned by the `play` function.</param>
	void stop(uint32_t handle);
	/// <summary>
	/// Plays a streaming audio file.
	/// </summary>
	/// <param name="filename">The path to the streaming audio file (can be OGG, WAV, MP3, or FLAC).</param>
	/// <param name="looping">Whether to loop the streaming audio.</param>
	/// <param name="crossFadeTime">The time (in seconds) to crossfade between the previous and new streaming audio.</param>
	void playStream(string filename, bool looping = false, float crossFadeTime = 0.0f);
	/// <summary>
	/// Stops a streaming audio file that is currently playing.
	/// </summary>
	/// <param name="fadeTime">The time (in seconds) to fade out the streaming audio.</param>
	void stopStream(float fadeTime = 0.0f);
	/// <summary>
	/// Pauses all the current audio.
	/// </summary>
	/// <param name="pause">Whether to pause the audio.</param>
	void setPauseAllCurrent(bool pause);
	/// <summary>
	/// Sets the position of the 3D listener.
	/// </summary>
	/// <param name="atX">The X coordinate of the listener position.</param>
	/// <param name="atY">The Y coordinate of the listener position.</param>
	/// <param name="atZ">The Z coordinate of the listener position.</param>
	void setListenerAt(float atX, float atY, float atZ);
	/// <summary>
	/// Sets the up vector of the 3D listener.
	/// </summary>
	/// <param name="upX">The X coordinate of the listener up vector.</param>
	/// <param name="upY">The Y coordinate of the listener up vector.</param>
	/// <param name="upZ">The Z coordinate of the listener up vector.</param>
	void setListenerUp(float upX, float upY, float upZ);
	/// <summary>
	/// Sets the velocity of the 3D listener.
	/// </summary>
	/// <param name="velocityX">The X coordinate of the listener velocity.</param>
	/// <param name="velocityY">The Y coordinate of the listener velocity.</param>
	/// <param name="velocityZ">The Z coordinate of the listener velocity.</param>
	void setListenerVelocity(float velocityX, float velocityY, float velocityZ);
};

/// <summary>
/// A class that represents an audio bus.
/// </summary>
object class AudioBus
{
	/// <summary>
	/// The volume of the audio bus. The value is between 0.0 and 1.0.
	/// </summary>
	common float volume;
	/// <summary>
	/// The pan of the audio bus. The value is between -1.0 and 1.0.
	/// </summary>
	common float pan;
	/// <summary>
	/// The play speed of the audio bus. The value 1.0 is the normal speed. 0.5 is half speed. 2.0 is double speed.
	/// </summary>
	common float playSpeed;
	/// <summary>
	/// Fades the volume of the audio bus to the given value over the given time.
	/// </summary>
	/// <param name="time">The time to fade the volume.</param>
	/// <param name="toVolume">The target volume.</param>
	void fadeVolume(double time, float toVolume);
	/// <summary>
	/// Fades the pan of the audio bus to the given value over the given time.
	/// </summary>
	/// <param name="time">The time to fade the pan.</param>
	/// <param name="toPan">The target pan. The value is between -1.0 and 1.0.</param>
	void fadePan(double time, float toPan);
	/// <summary>
	/// Fades the play speed of the audio bus to the given value over the given time.
	/// </summary>
	/// <param name="time">The time to fade the play speed.</param>
	/// <param name="toPlaySpeed">The target play speed.</param>
	void fadePlaySpeed(double time, float toPlaySpeed);
	/// <summary>
	/// Sets the filter of the audio bus.
	/// </summary>
	/// <param name="index">The index of the filter.</param>
	/// <param name="name">The name of the filter.</param>
	void setFilter(uint32_t index, string name);
	/// <summary>
	/// Sets the filter parameter of the audio bus.
	/// </summary>
	/// <param name="index">The index of the filter.</param>
	/// <param name="attrId">The attribute ID of the filter.</param>
	/// <param name="value">The value of the filter parameter.</param>
	void setFilterParameter(uint32_t index, uint32_t attrId, float value);
	/// <summary>
	/// Gets the filter parameter of the audio bus.
	/// </summary>
	/// <param name="index">The index of the filter.</param>
	/// <param name="attrId">The attribute ID of the filter.</param>
	/// <returns>The value of the filter parameter.</returns>
	float getFilterParameter(uint32_t index, uint32_t attrId);
	/// <summary>
	/// Fades the filter parameter of the audio bus to the given value over the given time.
	/// </summary>
	/// <param name="index">The index of the filter.</param>
	/// <param name="attrId">The attribute ID of the filter.</param>
	/// <param name="to">The target value of the filter parameter.</param>
	/// <param name="time">The time to fade the filter parameter.</param>
	void fadeFilterParameter(uint32_t index, uint32_t attrId, float to, double time);
	/// <summary>
	/// Creates a new audio bus.
	/// </summary>
	/// <returns>The created audio bus.</returns>
	static AudioBus* create();
};

/// <summary>
/// A class that represents an audio source node.
/// </summary>
object class AudioSource : public Node
{
	/// <summary>
	/// The volume of the audio source. The value is between 0.0 and 1.0.
	/// </summary>
	common float volume;
	/// <summary>
	/// The pan of the audio source. The value is between -1.0 and 1.0.
	/// </summary>
	common float pan;
	/// <summary>
	/// Whether the audio source is looping.
	/// </summary>
	boolean bool looping;
	/// <summary>
	/// Whether the audio source is playing.
	/// </summary>
	readonly boolean bool playing;
	/// <summary>
	/// Seeks the audio source to the given time.
	/// </summary>
	/// <param name="startTime">The time to seek to.</param>
	void seek(double startTime);
	/// <summary>
	/// Schedules the audio source to stop at the given time.
	/// </summary>
	/// <param name="timeToStop">The time to wait before stopping the audio source.</param>
	void scheduleStop(double timeToStop);
	/// <summary>
	/// Stops the audio source.
	/// </summary>
	/// <param name="fadeTime">The time to fade out the audio source.</param>
	void stop(double fadeTime = 0.0);
	/// <summary>
	/// Plays the audio source.
	/// </summary>
	/// <returns>`true` if the audio source was played successfully, `false` otherwise.</returns>
	bool play();
	/// <summary>
	/// Plays the audio source with a delay.
	/// </summary>
	/// <param name="delayTime">The time to wait before playing the audio source.</param>
	/// <returns>`true` if the audio source was played successfully, `false` otherwise.</returns>
	bool play @ playWithDelay(double delayTime = 0.0);
	/// <summary>
	/// Plays the audio source as a background audio.
	/// </summary>
	/// <returns>`true` if the audio source was played successfully, `false` otherwise.</returns>
	bool playBackground();
	/// <summary>
	/// Plays the audio source as a 3D audio.
	/// </summary>
	/// <returns>`true` if the audio source was played successfully, `false` otherwise.</returns>
	bool play3D @ play_3d();
	/// <summary>
	/// Plays the audio source as a 3D audio with a delay.
	/// </summary>
	/// <param name="delayTime">The time to wait before playing the audio source.</param>
	/// <returns>`true` if the audio source was played successfully, `false` otherwise.</returns>
	bool play3D @ play_3d_with_delay(double delayTime = 0.0);
	/// <summary>
	/// Sets the protected state of the audio source.
	/// </summary>
	/// <param name="value">The protected state.</param>
	void setProtected(bool value);
	/// <summary>
	/// Sets the loop point of the audio source.
	/// </summary>
	/// <param name="loopStartTime">The time to start the loop.</param>
	void setLoopPoint(double loopStartTime);
	/// <summary>
	/// Sets the velocity of the audio source.
	/// </summary>
	/// <param name="vx">The X coordinate of the velocity.</param>
	/// <param name="vy">The Y coordinate of the velocity.</param>
	/// <param name="vz">The Z coordinate of the velocity.</param>
	void setVelocity(float vx, float vy, float vz);
	/// <summary>
	/// Sets the minimum and maximum distance of the audio source.
	/// </summary>
	/// <param name="min">The minimum distance.</param>
	/// <param name="max">The maximum distance.</param>
	void setMinMaxDistance(float min, float max);
	/// <summary>
	/// Sets the attenuation of the audio source.
	/// </summary>
	/// <param name="model">The attenuation model.</param>
	/// <param name="factor">The factor of the attenuation.</param>
	void setAttenuation(AttenuationModel model, float factor);
	/// <summary>
	/// Sets the Doppler factor of the audio source.
	/// </summary>
	/// <param name="factor">The factor of the Doppler effect.</param>
	void setDopplerFactor(float factor);
	/// <summary>
	/// Creates a new audio source.
	/// </summary>
	/// <param name="filename">The path to the audio file.</param>
	/// <param name="autoRemove">Whether to automatically remove the audio source when it is stopped.</param>
	/// <returns>The created audio source node.</returns>
	static optional AudioSource* create(string filename, bool autoRemove = true);
	/// <summary>
	/// Creates a new audio source.
	/// </summary>
	/// <param name="filename">The path to the audio file.</param>
	/// <param name="autoRemove">Whether to automatically remove the audio source when it is stopped.</param>
	/// <param name="bus">The audio bus to use for the audio source.</param>
	/// <returns>The created audio source node.</returns>
	static optional AudioSource* create @ createBus(string filename, bool autoRemove, AudioBus* bus);
};

/// <summary>
/// An interface for handling keyboard inputs.
/// </summary>
singleton class Keyboard
{
	/// <summary>
	/// Checks whether a key is currently pressed.
	/// </summary>
	/// <param name="name">The name of the key to check.</param>
	/// <returns>`true` if the key is pressed, `false` otherwise.</returns>
	bool isKeyDown @ _is_key_down(string name);
	/// <summary>
	/// Checks whether a key is currently released.
	/// </summary>
	/// <param name="name">The name of the key to check.</param>
	/// <returns>`true` if the key is released, `false` otherwise.</returns>
	bool isKeyUp @ _is_key_up(string name);
	/// <summary>
	/// Checks whether a key is currently being pressed.
	/// </summary>
	/// <param name="name">The name of the key to check.</param>
	/// <returns>`true` if the key is being pressed, `false` otherwise.</returns>
	bool isKeyPressed @ _is_key_pressed(string name);
	/// <summary>
	/// Updates the input method editor (IME) position hint.
	/// </summary>
	/// <param name="winPos">The position of the keyboard window.</param>
	void updateIMEPosHint @ update_ime_pos_hint(Vec2 winPos);
};

/// <summary>
/// An interface for handling mouse inputs.
/// </summary>
singleton class Mouse {
	/// <summary>
	/// The position of the mouse in the visible window.
	/// You can use `Mouse::get_position() * App::get_device_pixel_ratio()` to get the coordinate in the game world.
	/// Then use `node.convertToNodeSpace()` to convert the world coordinate to the local coordinate of the node.
	/// # Example
	/// ```
	/// var worldPos = Mouse.Position.mul(App.DevicePixelRatio);
	/// var nodePos = node.ConvertToNodeSpace(worldPos);
	/// ```
	/// </summary>
	static Vec2 getPosition();
	/// <summary>
	/// Whether the left mouse button is currently being pressed.
	/// </summary>
	static bool isLeftButtonPressed();
	/// <summary>
	/// Whether the right mouse button is currently being pressed.
	/// </summary>
	static bool isRightButtonPressed();
	/// <summary>
	/// Whether the middle mouse button is currently being pressed.
	/// </summary>
	static bool isMiddleButtonPressed();
	/// <summary>
	/// Gets the mouse wheel value.
	/// </summary>
	static Vec2 getWheel();
};

/// <summary>
/// An interface for handling game controller inputs.
/// </summary>
singleton class Controller
{
	/// <summary>
	/// Checks whether a button on the controller is currently pressed.
	/// </summary>
	/// <param name="controllerId">The ID of the controller to check. Starts from 0.</param>
	/// <param name="name">The name of the button to check.</param>
	/// <returns>`true` if the button is pressed, `false` otherwise.</returns>
	bool isButtonDown @ _is_button_down(int controllerId, string name);
	/// <summary>
	/// Checks whether a button on the controller is currently released.
	/// </summary>
	/// <param name="controllerId">The ID of the controller to check. Starts from 0.</param>
	/// <param name="name">The name of the button to check.</param>
	/// <returns>`true` if the button is released, `false` otherwise.</returns>
	bool isButtonUp @ _is_button_up(int controllerId, string name);
	/// <summary>
	/// Checks whether a button on the controller is currently being pressed.
	/// </summary>
	/// <param name="controllerId">The ID of the controller to check. Starts from 0.</param>
	/// <param name="name">The name of the button to check.</param>
	/// <returns>`true` if the button is being pressed, `false` otherwise.</returns>
	bool isButtonPressed @ _is_button_pressed(int controllerId, string name);
	/// <summary>
	/// Gets the value of an axis on the controller.
	/// </summary>
	/// <param name="controllerId">The ID of the controller to check. Starts from 0.</param>
	/// <param name="name">The name of the axis to check.</param>
	/// <returns>The value of the axis. The value is between -1.0 and 1.0.</returns>
	float getAxis @ _get_axis(int controllerId, string name);
};

/// <summary>
/// A struct used for Scalable Vector Graphics rendering.
/// </summary>
object class SVGDef @ SVG
{
	/// <summary>
	/// The width of the SVG object.
	/// </summary>
	readonly common float width;
	/// <summary>
	/// The height of the SVG object.
	/// </summary>
	readonly common float height;
	/// <summary>
	/// Renders the SVG object, should be called every frame for the render result to appear.
	/// </summary>
	void render();
	/// <summary>
	/// Creates a new SVG object from the specified SVG file.
	/// </summary>
	/// <param name="filename">The path to the SVG format file.</param>
	/// <returns>The created SVG object.</returns>
	static optional SVGDef* from @ create(string filename);
};

value struct DBParams
{
	void add(Array* params_);
	static DBParams create();
};

value struct DBRecord
{
	readonly boolean bool valid;
	bool read(Array* record);
};

value struct DBQuery
{
	void addWithParams(string sql, DBParams params_);
	void add(string sql);
	static DBQuery create();
};

/// <summary>
/// A struct that represents a database.
/// </summary>
singleton class DB
{
	/// <summary>
	/// Checks whether a database exists.
	/// </summary>
	/// <param name="dbName">The name of the database to check.</param>
	/// <returns>`true` if the database exists, `false` otherwise.</returns>
	bool existDB @ exist_db(string dbName);
	/// <summary>
	/// Checks whether a table exists in the database.
	/// </summary>
	/// <param name="tableName">The name of the table to check.</param>
	/// <returns>`true` if the table exists, `false` otherwise.</returns>
	bool exist(string tableName);
	/// <summary>
	/// Checks whether a table exists in the database.
	/// </summary>
	/// <param name="tableName">The name of the table to check.</param>
	/// <param name="schema">Optional. The name of the schema to check in.</param>
	/// <returns>`true` if the table exists, `false` otherwise.</returns>
	bool exist @ existSchema(string tableName, string schema = "");
	/// <summary>
	/// Executes an SQL statement and returns the number of rows affected.
	/// </summary>
	/// <param name="sql">The SQL statement to execute.</param>
	/// <returns>The number of rows affected by the statement.</returns>
	int exec(string sql);
	/// <summary>
	/// Executes a list of SQL statements as a single transaction.
	/// </summary>
	/// <param name="query">A list of SQL statements to execute.</param>
	/// <returns>`true` if the transaction was successful, `false` otherwise.</returns>
	outside bool DB_Transaction @ transaction(DBQuery query);
	/// <summary>
	/// Executes a list of SQL statements as a single transaction asynchronously.
	/// </summary>
	/// <param name="query">A list of SQL statements to execute.</param>
	/// <param name="callback">A callback function that is invoked when the transaction is executed, receiving the result of the transaction.</param>
	/// <returns>`true` if the transaction was successful, `false` otherwise.</returns>
	outside void DB_TransactionAsync @ transactionAsync(DBQuery query, function<void(bool result)> callback);
	/// <summary>
	/// Executes an SQL query and returns the results as a list of rows.
	/// </summary>
	/// <param name="sql">The SQL statement to execute.</param>
	/// <param name="withColumns">Whether to include column names in the result.</param>
	/// <returns>A list of rows returned by the query.</returns>
	outside DBRecord DB_Query @ query(string sql, bool withColumns);
	/// <summary>
	/// Executes an SQL query and returns the results as a list of rows.
	/// </summary>
	/// <param name="sql">The SQL statement to execute.</param>
	/// <param name="params_">A list of values to substitute into the SQL statement.</param>
	/// <param name="withColumns">Whether to include column names in the result.</param>
	/// <returns>A list of rows returned by the query.</returns>
	outside DBRecord DB_QueryWithParams @ queryWithParams(string sql, Array* params_, bool withColumns);
	/// <summary>
	/// Inserts a row of data into a table within a transaction.
	/// </summary>
	/// <param name="tableName">The name of the table to insert into.</param>
	/// <param name="values">The values to insert into the table.</param>
	/// <returns>`true` if the insertion was successful, `false` otherwise.</returns>
	outside void DB_Insert @ insert(string tableName, DBParams values);
	/// <summary>
	/// Executes an SQL statement and returns the number of rows affected.
	/// </summary>
	/// <param name="sql">The SQL statement to execute.</param>
	/// <param name="values">Lists of values to substitute into the SQL statement.</param>
	/// <returns>The number of rows affected by the statement.</returns>
	outside int32_t DB_ExecWithRecords @ execWithRecords(string sql, DBParams values);
	/// <summary>
	/// Executes an SQL query asynchronously and returns the results as a list of rows.
	/// </summary>
	/// <param name="sql">The SQL statement to execute.</param>
	/// <param name="params_">Optional. A list of values to substitute into the SQL statement.</param>
	/// <param name="withColumns">Optional. Whether to include column names in the result. Default is `false`.</param>
	/// <param name="callback">A callback function that is invoked when the query is executed, receiving the results as a list of rows.</param>
	outside void DB_QueryWithParamsAsync @ queryWithParamsAsync(string sql, Array* params_, bool withColumns, function<void(DBRecord result)> callback);
	/// <summary>
	/// Inserts a row of data into a table within a transaction asynchronously.
	/// </summary>
	/// <param name="tableName">The name of the table to insert into.</param>
	/// <param name="values">The values to insert into the table.</param>
	/// <param name="callback">A callback function that is invoked when the insertion is executed, receiving the result of the insertion.</param>
	outside void DB_InsertAsync @ insertAsync(string tableName, DBParams values, function<void(bool result)> callback);
	/// <summary>
	/// Executes an SQL statement with a list of values within a transaction asynchronously and returns the number of rows affected.
	/// </summary>
	/// <param name="sql">The SQL statement to execute.</param>
	/// <param name="values">A list of values to substitute into the SQL statement.</param>
	/// <param name="callback">A callback function that is invoked when the statement is executed, recieving the number of rows affected.</param>
	outside void DB_ExecAsync @ execAsync(string sql, DBParams values, function<void(int64_t rowChanges)> callback);
};

/// <summary>
/// A simple reinforcement learning framework that can be used to learn optimal policies for Markov decision processes using Q-learning. Q-learning is a model-free reinforcement learning algorithm that learns an optimal action-value function from experience by repeatedly updating estimates of the Q-value of state-action pairs.
/// </summary>
object class MLQLearner @ QLearner
{
	/// <summary>
	/// Updates Q-value for a state-action pair based on received reward.
	/// </summary>
	/// <param name="state">An integer representing the state.</param>
	/// <param name="action">An integer representing the action.</param>
	/// <param name="reward">A number representing the reward received for the action in the state.</param>
	void update(MLQState state, MLQAction action, double reward);
	/// <summary>
	/// Returns the best action for a given state based on the current Q-values.
	/// </summary>
	/// <param name="state">The current state.</param>
	/// <returns>The action with the highest Q-value for the given state.</returns>
	uint32_t getBestAction(MLQState state);
	/// <summary>
	/// Visits all state-action pairs and calls the provided handler function for each pair.
	/// </summary>
	/// <param name="handler">A function that is called for each state-action pair.</param>
	outside void ML_QLearnerVisitStateActionQ @ visitMatrix(function<void(MLQState state, MLQAction action, double q)> handler);
	/// <summary>
	/// Constructs a state from given hints and condition values.
	/// </summary>
	/// <param name="hints">A vector of integers representing the byte length of provided values.</param>
	/// <param name="values">The condition values as discrete values.</param>
	/// <returns>The packed state value.</returns>
	static MLQState pack(VecUint32 hints, VecUint32 values);
	/// <summary>
	/// Deconstructs a state from given hints to get condition values.
	/// </summary>
	/// <param name="hints">A vector of integers representing the byte length of provided values.</param>
	/// <param name="state">The state integer to unpack.</param>
	/// <returns>The condition values as discrete values.</returns>
	static VecUint32 unpack(VecUint32 hints, MLQState state);
	/// <summary>
	/// Creates a new QLearner object with optional parameters for gamma, alpha, and maxQ.
	/// </summary>
	/// <param name="gamma">The discount factor for future rewards.</param>
	/// <param name="alpha">The learning rate for updating Q-values.</param>
	/// <param name="maxQ">The maximum Q-value. Defaults to 100.0.</param>
	/// <returns>The newly created QLearner object.</returns>
	static QLearner* create(double gamma = 0.5, double alpha = 0.5, double maxQ = 100.0);
};

/// <summary>
/// An interface for machine learning algorithms.
/// </summary>
singleton class C45
{
	/// <summary>
	/// A function that takes CSV data as input and applies the C4.5 machine learning algorithm to build a decision tree model asynchronously.
	/// C4.5 is a decision tree algorithm that uses information gain to select the best attribute to split the data at each node of the tree. The resulting decision tree can be used to make predictions on new data.
	/// </summary>
	/// <param name="csvData">The CSV training data for building the decision tree using delimiter `,`.</param>
	/// <param name="maxDepth">The maximum depth of the generated decision tree. Set to 0 to prevent limiting the generated tree depth.</param>
	/// <param name="treeVisitor">The callback function to be called for each node of the generated decision tree.</param>
	static outside void MLBuildDecisionTreeAsync @ buildDecisionTreeAsync(string csvData, int maxDepth, function<void(double depth, string name, string op, string value)> treeVisitor);
};

/// <summary>
/// An HTTP client interface.
/// </summary>
singleton class HttpClient
{
	/// <summary>
	/// Sends a POST request to the specified URL and returns the response body.
	/// </summary>
	/// <param name="url">The URL to send the request to.</param>
	/// <param name="json">The JSON data to send in the request body.</param>
	/// <param name="timeout">The timeout in seconds for the request.</param>
	/// <param name="callback">A callback function that is called when the request is complete. The function receives the response body as a parameter.</param>
	void postAsync(string url, string json, float timeout, function<void(OptString body)> callback);
	/// <summary>
	/// Sends a POST request to the specified URL with custom headers and returns the response body.
	/// </summary>
	/// <param name="url">The URL to send the request to.</param>
	/// <param name="headers">A vector of headers to include in the request. Each header should be in the format `key: value`.</param>
	/// <param name="json">The JSON data to send in the request body.</param>
	/// <param name="timeout">The timeout in seconds for the request.</param>
	/// <param name="callback">A callback function that is called when the request is complete. The function receives the response body as a parameter.</param>
	void postAsync @ postWithHeadersAsync(string url, VecStr headers, string json, float timeout, function<void(OptString body)> callback);
	/// <summary>
	/// Sends a POST request to the specified URL with custom headers and returns the response body.
	/// </summary>
	/// <param name="url">The URL to send the request to.</param>
	/// <param name="headers">A vector of headers to include in the request. Each header should be in the format `key: value`.</param>
	/// <param name="json">The JSON data to send in the request body.</param>
	/// <param name="timeout">The timeout in seconds for the request.</param>
	/// <param name="partCallback">A callback function that is called periodically to get part of the response content. Returns `true` to stop the request.</param>
	/// <param name="callback">A callback function that is called when the request is complete. The function receives the response body as a parameter.</param>
	void postAsync @ postWithHeadersPartAsync(string url, VecStr headers, string json, float timeout, function<def_false bool(string body)> partCallback, function<void(OptString body)> callback);
	/// <summary>
	/// Sends a GET request to the specified URL and returns the response body.
	/// </summary>
	/// <param name="url">The URL to send the request to.</param>
	/// <param name="timeout">The timeout in seconds for the request.</param>
	/// <param name="callback">A callback function that is called when the request is complete. The function receives the response body as a parameter.</param>
	void getAsync(string url, float timeout, function<void(OptString body)> callback);
	/// <summary>
	/// Downloads a file asynchronously from the specified URL and saves it to the specified path.
	/// </summary>
	/// <param name="url">The URL of the file to download.</param>
	/// <param name="fullPath">The full path where the downloaded file should be saved.</param>
	/// <param name="timeout">The timeout in seconds for the request.</param>
	/// <param name="progress">A callback function that is called periodically to report the download progress.</param>
	void downloadAsync(string url, string fullPath, float timeout, function<def_true bool(bool interrupted, uint64_t current, uint64_t total)> progress);
};

namespace Platformer {

/// <summary>
/// A struct to specifies how a bullet object should interact with other game objects or units based on their relationship.
/// </summary>
value class TargetAllow
{
	/// <summary>
	/// Whether the bullet object can collide with terrain.
	/// </summary>
	boolean bool terrainAllowed;
	/// <summary>
	/// Allows or disallows the bullet object to interact with a game object or unit, based on their relationship.
	/// </summary>
	/// <param name="relation">The relationship between the bullet object and the other game object or unit.</param>
	/// <param name="allow">Whether the bullet object should be allowed to interact.</param>
	void allow(Platformer::Relation relation, bool allow);
	/// <summary>
	/// Determines whether the bullet object is allowed to interact with a game object or unit, based on their relationship.
	/// </summary>
	/// <param name="relation">The relationship between the bullet object and the other game object or unit.</param>
	/// <returns>Whether the bullet object is allowed to interact.</returns>
	bool isAllow(Platformer::Relation relation);
	/// <summary>
	/// Converts the object to a value that can be used for interaction settings.
	/// </summary>
	/// <returns>The value that can be used for interaction settings.</returns>
	uint32_t toValue();
	/// <summary>
	/// Creates a new TargetAllow object with default settings.
	/// </summary>
	static Platformer::TargetAllow create();
	/// <summary>
	/// Creates a new TargetAllow object with the specified value.
	/// </summary>
	/// <param name="value">The value to use for the new TargetAllow object.</param>
	static Platformer::TargetAllow create @ createValue(uint32_t value);
};

/// <summary>
/// Represents a definition for a visual component of a game bullet or other visual item.
/// </summary>
object class Face
{
	/// <summary>
	/// Adds a child `Face` definition to it.
	/// </summary>
	/// <param name="face">The child `Face` to add.</param>
	void addChild(Platformer::Face* face);
	/// <summary>
	/// Returns a node that can be added to a scene tree for rendering.
	/// </summary>
	/// <returns>The `Node` representing this `Face`.</returns>
	Node* toNode();
	/// <summary>
	/// Creates a new `Face` definition using the specified attributes.
	/// </summary>
	/// <param name="faceStr">A string for creating the `Face` component. Could be 'Image/file.png' and 'Image/items.clip|itemA'.</param>
	/// <param name="point">The position of the `Face` component.</param>
	/// <param name="scale">The scale of the `Face` component.</param>
	/// <param name="angle">The angle of the `Face` component.</param>
	/// <returns>The new `Face` component.</returns>
	static Face* create(string faceStr, Vec2 point, float scale = 1.0f, float angle = 0.0f);
	/// <summary>
	/// Creates a new `Face` definition using the specified attributes.
	/// </summary>
	/// <param name="createFunc">A function that returns a `Node` representing the `Face` component.</param>
	/// <param name="point">The position of the `Face` component.</param>
	/// <param name="scale">The scale of the `Face` component.</param>
	/// <param name="angle">The angle of the `Face` component.</param>
	/// <returns>The new `Face` component.</returns>
	static Face* create @ createFunc(function<Node*()> createFunc, Vec2 point = new(), float scale = 1.0f, float angle = 0.0f);
};

/// <summary>
/// A struct type that specifies the properties and behaviors of a bullet object in the game.
/// </summary>
object class BulletDef
{
	/// <summary>
	/// The tag for the bullet object.
	/// </summary>
	string tag;
	/// <summary>
	/// The effect that occurs when the bullet object ends its life.
	/// </summary>
	string endEffect;
	/// <summary>
	/// The amount of time in seconds that the bullet object remains active.
	/// </summary>
	float lifeTime;
	/// <summary>
	/// The radius of the bullet object's damage area.
	/// </summary>
	float damageRadius;
	/// <summary>
	/// Whether the bullet object should be fixed for high speeds.
	/// </summary>
	boolean bool highSpeedFix;
	/// <summary>
	/// The gravity vector that applies to the bullet object.
	/// </summary>
	common Vec2 gravity;
	/// <summary>
	/// The visual item of the bullet object.
	/// </summary>
	common Platformer::Face* face;
	/// <summary>
	/// The physics body definition for the bullet object.
	/// </summary>
	readonly common BodyDef* bodyDef;
	/// <summary>
	/// The velocity vector of the bullet object.
	/// </summary>
	readonly common Vec2 velocity;
	/// <summary>
	/// Sets the bullet object's physics body as a circle.
	/// </summary>
	/// <param name="radius">The radius of the circle.</param>
	void setAsCircle(float radius);
	/// <summary>
	/// Sets the velocity of the bullet object.
	/// </summary>
	/// <param name="angle">The angle of the velocity in degrees.</param>
	/// <param name="speed">The speed of the velocity.</param>
	void setVelocity(float angle, float speed);
	/// <summary>
	/// Creates a new bullet object definition with default settings.
	/// </summary>
	/// <returns>The new bullet object definition.</returns>
	static BulletDef* create();
};

/// <summary>
/// A struct that defines the properties and behavior of a bullet object instance in the game.
/// </summary>
object class Bullet : public Body
{
	/// <summary>
	/// The value from a `Platformer.TargetAllow` object for the bullet object.
	/// </summary>
	common uint32_t targetAllow;
	/// <summary>
	/// Whether the bullet object is facing right.
	/// </summary>
	readonly boolean bool faceRight;
	/// <summary>
	/// Whether the bullet object should stop on impact.
	/// </summary>
	boolean bool hitStop;
	/// <summary>
	/// The `Unit` object that fired the bullet.
	/// </summary>
	readonly common Platformer::Unit* emitter;
	/// <summary>
	/// The `BulletDef` object that defines the bullet's properties and behavior.
	/// </summary>
	readonly common Platformer::BulletDef* bulletDef;
	/// <summary>
	/// The `Node` object that appears as the bullet's visual item.
	/// </summary>
	common Node* face;
	/// <summary>
	/// Destroys the bullet object instance.
	/// </summary>
	void destroy();
	/// <summary>
	/// A method that creates a new `Bullet` object instance with the specified `BulletDef` and `Unit` objects.
	/// </summary>
	/// <param name="def">The `BulletDef` object that defines the bullet's properties and behavior.</param>
	/// <param name="owner">The `Unit` object that fired the bullet.</param>
	/// <returns>The new `Bullet` object instance.</returns>
	static Bullet* create(Platformer::BulletDef* def, Platformer::Unit* owner);
};

/// <summary>
/// A struct represents a visual effect object like Particle, Frame Animation or just a Sprite.
/// </summary>
object class Visual : public Node
{
	/// <summary>
	/// Whether the visual effect is currently playing or not.
	/// </summary>
	readonly boolean bool playing;
	/// <summary>
	/// Starts playing the visual effect.
	/// </summary>
	void start();
	/// <summary>
	/// Stops playing the visual effect.
	/// </summary>
	void stop();
	/// <summary>
	/// Automatically removes the visual effect from the game world when it finishes playing.
	/// </summary>
	/// <returns>The same `Visual` object that was passed in as a parameter.</returns>
	Platformer::Visual* autoRemove();
	/// <summary>
	/// Creates a new `Visual` object with the specified name.
	/// </summary>
	/// <param name="name">The name of the new `Visual` object. Could be a particle file, a frame animation file or an image file.</param>
	/// <returns>The new `Visual` object.</returns>
	static Visual* create(string name);
};

namespace Behavior {

/// <summary>
/// A blackboard object that can be used to store data for behavior tree nodes.
/// </summary>
class Blackboard
{
	/// <summary>
	/// The time since the last frame update in seconds.
	/// </summary>
	readonly common double deltaTime;
	/// <summary>
	/// The unit that the AI agent belongs to.
	/// </summary>
	readonly common Platformer::Unit* owner;
};

/// <summary>
/// A behavior tree framework for creating game AI structures.
/// </summary>
object class Leaf @ Tree
{
	/// <summary>
	/// Creates a new sequence node that executes an array of child nodes in order.
	/// </summary>
	/// <param name="nodes">A vector of child nodes.</param>
	/// <returns>A new sequence node.</returns>
	static outside Platformer::Behavior::Leaf* BSeq @ seq(VecBTree nodes);
	/// <summary>
	/// Creates a new selector node that selects and executes one of its child nodes that will succeed.
	/// </summary>
	/// <param name="nodes">A vector of child nodes.</param>
	/// <returns>A new selector node.</returns>
	static outside Platformer::Behavior::Leaf* BSel @ sel(VecBTree nodes);
	/// <summary>
	/// Creates a new condition node that executes a check handler function when executed.
	/// </summary>
	/// <param name="name">The name of the condition.</param>
	/// <param name="check">A function that takes a blackboard object and returns a boolean value.</param>
	/// <returns>A new condition node.</returns>
	static outside Platformer::Behavior::Leaf* BCon @ con(string name, function<def_false bool(Platformer::Behavior::Blackboard blackboard)> check);
	/// <summary>
	/// Creates a new action node that executes an action when executed.
	/// This node will block the execution until the action finishes.
	/// </summary>
	/// <param name="actionName">The name of the action to execute.</param>
	/// <returns>A new action node.</returns>
	static outside Platformer::Behavior::Leaf* BAct @ act(string actionName);
	/// <summary>
	/// Creates a new command node that executes a command when executed.
	/// This node will return right after the action starts.
	/// </summary>
	/// <param name="actionName">The name of the command to execute.</param>
	/// <returns>A new command node.</returns>
	static outside Platformer::Behavior::Leaf* BCommand @ command(string actionName);
	/// <summary>
	/// Creates a new wait node that waits for a specified duration when executed.
	/// </summary>
	/// <param name="duration">The duration to wait in seconds.</param>
	static outside Platformer::Behavior::Leaf* BWait @ wait(double duration);
	/// <summary>
	/// Creates a new countdown node that executes a child node continuously until a timer runs out.
	/// </summary>
	/// <param name="time">The time limit in seconds.</param>
	/// <param name="node">The child node to execute.</param>
	static outside Platformer::Behavior::Leaf* BCountdown @ countdown(double time, Platformer::Behavior::Leaf* node);
	/// <summary>
	/// Creates a new timeout node that executes a child node until a timer runs out.
	/// </summary>
	/// <param name="time">The time limit in seconds.</param>
	/// <param name="node">The child node to execute.</param>
	static outside Platformer::Behavior::Leaf* BTimeout @ timeout(double time, Platformer::Behavior::Leaf* node);
	/// <summary>
	/// Creates a new repeat node that executes a child node a specified number of times.
	/// </summary>
	/// <param name="times">The number of times to execute the child node.</param>
	/// <param name="node">The child node to execute.</param>
	static outside Platformer::Behavior::Leaf* BRepeat @ repeat(int times, Platformer::Behavior::Leaf* node);
	/// <summary>
	/// Creates a new repeat node that executes a child node repeatedly.
	/// </summary>
	/// <param name="node">The child node to execute.</param>
	static outside Platformer::Behavior::Leaf* BRepeat @ repeatForever(Platformer::Behavior::Leaf* node);
	/// <summary>
	/// Creates a new retry node that executes a child node repeatedly until it succeeds or a maximum number of retries is reached.
	/// </summary>
	/// <param name="times">The maximum number of retries.</param>
	/// <param name="node">The child node to execute.</param>
	static outside Platformer::Behavior::Leaf* BRetry @ retry(int times, Platformer::Behavior::Leaf* node);
	/// <summary>
	/// Creates a new retry node that executes a child node repeatedly until it succeeds.
	/// </summary>
	/// <param name="node">The child node to execute.</param>
	static outside Platformer::Behavior::Leaf* BRetry @ retryUntilPass(Platformer::Behavior::Leaf* node);
};

}

namespace Decision {

/// <summary>
/// A decision tree framework for creating game AI structures.
/// </summary>
object class Leaf @ Tree
{
	/// <summary>
	/// Creates a selector node with the specified child nodes.
	/// A selector node will go through the child nodes until one succeeds.
	/// </summary>
	/// <param name="nodes">An array of `Leaf` nodes.</param>
	static outside Platformer::Decision::Leaf* DSel @ sel(VecDTree nodes);
	/// <summary>
	/// Creates a sequence node with the specified child nodes.
	/// A sequence node will go through the child nodes until all nodes succeed.
	/// </summary>
	/// <param name="nodes">An array of `Leaf` nodes.</param>
	static outside Platformer::Decision::Leaf* DSeq @ seq(VecDTree nodes);
	/// <summary>
	/// Creates a condition node with the specified name and handler function.
	/// </summary>
	/// <param name="name">The name of the condition.</param>
	/// <param name="check">The check function that takes a `Unit` parameter and returns a boolean result.</param>
	static outside Platformer::Decision::Leaf* DCon @ con(string name, function<def_false bool(Platformer::Unit* unit)> check);
	/// <summary>
	/// Creates an action node with the specified action name.
	/// </summary>
	/// <param name="actionName">The name of the action to perform.</param>
	static outside Platformer::Decision::Leaf* DAct @ act(string actionName);
	/// <summary>
	/// Creates an action node with the specified handler function.
	/// </summary>
	/// <param name="handler">The handler function that takes a `Unit` parameter which is the running AI agent and returns an action.</param>
	static outside Platformer::Decision::Leaf* DAct @ actDynamic(function<string(Platformer::Unit* unit)> handler);
	/// <summary>
	/// Creates a leaf node that represents accepting the current behavior tree.
	/// Always get success result from this node.
	/// </summary>
	static outside Platformer::Decision::Leaf* DAccept @ accept();
	/// <summary>
	/// Creates a leaf node that represents rejecting the current behavior tree.
	/// Always get failure result from this node.
	/// </summary>
	static outside Platformer::Decision::Leaf* DReject @ reject();
	/// <summary>
	/// Creates a leaf node with the specified behavior tree as its root.
	/// It is possible to include a Behavior Tree as a node in a Decision Tree by using the Behave() function. This allows the AI to use a combination of decision-making and behavior execution to achieve its goals.
	/// </summary>
	/// <param name="name">The name of the behavior tree.</param>
	/// <param name="root">The root node of the behavior tree.</param>
	static outside Platformer::Decision::Leaf* DBehave @ behave(string name, Platformer::Behavior::Leaf* root);
};

/// <summary>
/// The interface to retrieve information while executing the decision tree.
/// </summary>
singleton class AI
{
	/// <summary>
	/// Gets an array of units in detection range that have the specified relation to current AI agent.
	/// </summary>
	/// <param name="relation">The relation to filter the units by.</param>
	Array* getUnitsByRelation(Platformer::Relation relation);
	/// <summary>
	/// Gets an array of units that the AI has detected.
	/// </summary>
	Array* getDetectedUnits();
	/// <summary>
	/// Gets an array of bodies that the AI has detected.
	/// </summary>
	Array* getDetectedBodies();
	/// <summary>
	/// Gets the nearest unit that has the specified relation to the AI.
	/// </summary>
	/// <param name="relation">The relation to filter the units by.</param>
	Platformer::Unit* getNearestUnit(Platformer::Relation relation);
	/// <summary>
	/// Gets the distance to the nearest unit that has the specified relation to the AI agent.
	/// </summary>
	/// <param name="relation">The relation to filter the units by.</param>
	float getNearestUnitDistance(Platformer::Relation relation);
	/// <summary>
	/// Gets an array of units that are within attack range.
	/// </summary>
	Array* getUnitsInAttackRange();
	/// <summary>
	/// Gets an array of bodies that are within attack range.
	/// </summary>
	Array* getBodiesInAttackRange();
};

}

object class WasmActionUpdate @ ActionUpdate
{
	static WasmActionUpdate* create(function<def_true bool(Platformer::Unit* owner, Platformer::UnitAction action, float deltaTime)> update);
};

/// <summary>
/// A struct that represents an action that can be performed by a "Unit".
/// </summary>
class UnitAction
{
	/// <summary>
	/// The length of the reaction time for the "UnitAction", in seconds.
	/// The reaction time will affect the AI check cycling time.
	/// </summary>
	float reaction;
	/// <summary>
	/// The length of the recovery time for the "UnitAction", in seconds.
	/// The recovery time will mainly affect how long the `Playable` animation model will do transitions between animations played by different actions.
	/// </summary>
	float recovery;
	/// <summary>
	/// The name of the "UnitAction".
	/// </summary>
	readonly common string name;
	/// <summary>
	/// Whether the "Unit" is currently performing the "UnitAction" or not.
	/// </summary>
	readonly boolean bool doing;
	/// <summary>
	/// The "Unit" that owns this "UnitAction".
	/// </summary>
	readonly common Platformer::Unit* owner;
	/// <summary>
	/// The elapsed time since the "UnitAction" was started, in seconds.
	/// </summary>
	readonly common float elapsedTime;
	/// <summary>
	/// Removes all "UnitAction" objects from the "UnitActionClass".
	/// </summary>
	static void clear();
	/// <summary>
	/// Adds a new "UnitAction" to the "UnitActionClass" with the specified name and parameters.
	/// </summary>
	/// <param name="name">The name of the "UnitAction".</param>
	/// <param name="priority">The priority level for the "UnitAction". `UnitAction` with higher priority (larger number) will replace the running lower priority `UnitAction`. If performing `UnitAction` having the same priority with the running `UnitAction` and the `UnitAction` to perform having the param 'queued' to be true, the running `UnitAction` won't be replaced.</param>
	/// <param name="reaction">The length of the reaction time for the "UnitAction", in seconds. The reaction time will affect the AI check cycling time. Set to 0.0 to make AI check run in every update.</param>
	/// <param name="recovery">The length of the recovery time for the "UnitAction", in seconds. The recovery time will mainly affect how long the `Playable` animation model will do transitions between animations played by different actions.</param>
	/// <param name="queued">Whether the "UnitAction" is currently queued or not. The queued "UnitAction" won't replace the running "UnitAction" with a same priority.</param>
	/// <param name="available">A function that takes a `Unit` object and a `UnitAction` object and returns a boolean value indicating whether the "UnitAction" is available to be performed.</param>
	/// <param name="create">A function that takes a `Unit` object and a `UnitAction` object and returns a `WasmActionUpdate` object that contains the update function for the "UnitAction".</param>
	/// <param name="stop">A function that takes a `Unit` object and a `UnitAction` object and stops the "UnitAction".</param>
	static outside void Platformer_UnitAction_Add @ add(
		string name, int priority, float reaction, float recovery, bool queued,
		function<def_false bool(Platformer::Unit* owner, Platformer::UnitAction action)> available,
		function<Platformer::WasmActionUpdate*(Platformer::Unit* owner, Platformer::UnitAction action)> create,
		function<void(Platformer::Unit* owner, Platformer::UnitAction action)> stop);
};

/// <summary>
/// A struct represents a character or other interactive item in a game scene.
/// </summary>
object class Unit : public Body
{
	/// <summary>
	/// The property that references a "Playable" object for managing the animation state and playback of the "Unit".
	/// </summary>
	common Playable* playable;
	/// <summary>
	/// The property that specifies the maximum distance at which the "Unit" can detect other "Unit" or objects.
	/// </summary>
	common float detectDistance;
	/// <summary>
	/// The property that specifies the size of the attack range for the "Unit".
	/// </summary>
	common Size attackRange;
	/// <summary>
	/// The boolean property that specifies whether the "Unit" is facing right or not.
	/// </summary>
	boolean bool faceRight;
	/// <summary>
	/// The boolean property that specifies whether the "Unit" is receiving a trace of the decision tree for debugging purposes.
	/// </summary>
	boolean bool receivingDecisionTrace;
	/// <summary>
	/// The string property that specifies the decision tree to use for the "Unit's" AI behavior.
	/// the decision tree object will be searched in The singleton instance Data.store.
	/// </summary>
	common string decisionTreeName @ decisionTree;
	/// <summary>
	/// Whether the "Unit" is currently on a surface or not.
	/// </summary>
	readonly boolean bool onSurface;
	/// <summary>
	/// The "Sensor" object for detecting ground surfaces.
	/// </summary>
	readonly common Sensor* groundSensor;
	/// <summary>
	/// The "Sensor" object for detecting other "Unit" objects or physics bodies in the game world.
	/// </summary>
	readonly common Sensor* detectSensor;
	/// <summary>
	/// The "Sensor" object for detecting other "Unit" objects within the attack senser area.
	/// </summary>
	readonly common Sensor* attackSensor;
	/// <summary>
	/// The "Dictionary" object for defining the properties and behavior of the "Unit".
	/// </summary>
	readonly common Dictionary* unitDef;
	/// <summary>
	/// The property that specifies the current action being performed by the "Unit".
	/// </summary>
	readonly common Platformer::UnitAction currentAction;
	/// <summary>
	/// The width of the "Unit".
	/// </summary>
	readonly common hide float width;
	/// <summary>
	/// The height of the "Unit".
	/// </summary>
	readonly common hide float height;
	/// <summary>
	/// The "Entity" object for representing the "Unit" in the ECS system.
	/// </summary>
	readonly common Entity* entity;
	/// <summary>
	/// Adds a new `UnitAction` to the `Unit` with the specified name, and returns the new `UnitAction`.
	/// </summary>
	/// <param name="name">The name of the new `UnitAction`.</param>
	Platformer::UnitAction attachAction(string name);
	/// <summary>
	/// Removes the `UnitAction` with the specified name from the `Unit`.
	/// </summary>
	/// <param name="name">The name of the `UnitAction` to remove.</param>
	void removeAction(string name);
	/// <summary>
	/// Removes all "UnitAction" objects from the "Unit".
	/// </summary>
	void removeAllActions();
	/// <summary>
	/// Returns the `UnitAction` with the specified name, or `None` if the `UnitAction` does not exist.
	/// </summary>
	/// <param name="name">The name of the `UnitAction` to retrieve.</param>
	optional Platformer::UnitAction getAction(string name);
	/// <summary>
	/// Calls the specified function for each `UnitAction` attached to the `Unit`.
	/// </summary>
	/// <param name="visitorFunc">A function to call for each `UnitAction`.</param>
	void eachAction(function<void(Platformer::UnitAction action)> visitorFunc);
	/// <summary>
	/// Starts the `UnitAction` with the specified name, and returns true if the `UnitAction` was started successfully.
	/// </summary>
	/// <param name="name">The name of the `UnitAction` to start.</param>
	bool start(string name);
	/// <summary>
	/// Stops the currently running "UnitAction".
	/// </summary>
	void stop();
	/// <summary>
	/// Returns true if the `Unit` is currently performing the specified `UnitAction`, false otherwise.
	/// </summary>
	/// <param name="name">The name of the `UnitAction` to check.</param>
	bool isDoing(string name);
	/// <summary>
	/// A method that creates a new `Unit` object.
	/// </summary>
	/// <param name="unitDef">A `Dictionary` object that defines the properties and behavior of the `Unit`.</param>
	/// <param name="physicsWorld">A `PhysicsWorld` object that represents the physics simulation world.</param>
	/// <param name="entity">An `Entity` object that represents the `Unit` in ECS system.</param>
	/// <param name="pos">A `Vec2` object that specifies the initial position of the `Unit`.</param>
	/// <param name="rot">A number that specifies the initial rotation of the `Unit`.</param>
	static Unit* create(Dictionary* unitDef, PhysicsWorld* physicsWorld, Entity* entity, Vec2 pos, float rot = 0.0f);
	/// <summary>
	/// A method that creates a new `Unit` object.
	/// </summary>
	/// <param name="unitDefName">A string that specifies the name of the `Unit` definition to retrieve from `Data.store` table.</param>
	/// <param name="physicsWorldName">A string that specifies the name of the `PhysicsWorld` object to retrieve from `Data.store` table.</param>
	/// <param name="entity">An `Entity` object that represents the `Unit` in ECS system.</param>
	/// <param name="pos">A `Vec2` object that specifies the initial position of the `Unit`.</param>
	/// <param name="rot">An optional number that specifies the initial rotation of the `Unit` (default is 0.0).</param>
	static Unit* create @ createStore(string unitDefName, string physicsWorldName, Entity* entity, Vec2 pos, float rot = 0.0f);
};

/// <summary>
/// A platform camera for 2D platformer games that can track a game unit's movement and keep it within the camera's view.
/// </summary>
object class PlatformCamera : public Camera
{
	/// <summary>
	/// The camera's position.
	/// </summary>
	common Vec2 position;
	/// <summary>
	/// The camera's rotation in degrees.
	/// </summary>
	common float rotation;
	/// <summary>
	/// The camera's zoom factor, 1.0 means the normal size, 2.0 mean zoom to doubled size.
	/// </summary>
	common float zoom;
	/// <summary>
	/// The rectangular area within which the camera is allowed to view.
	/// </summary>
	common Rect boundary;
	/// <summary>
	/// The ratio at which the camera should move to keep up with the target's position.
	/// For example, set to `Vec2(1.0, 1.0)`, then the camera will keep up to the target's position right away.
	/// Set to Vec2(0.5, 0.5) or smaller value, then the camera will move halfway to the target's position each frame, resulting in a smooth and gradual movement.
	/// </summary>
	common Vec2 followRatio;
	/// <summary>
	/// The offset at which the camera should follow the target.
	/// </summary>
	common Vec2 followOffset;
	/// <summary>
	/// The game unit that the camera should track.
	/// </summary>
	optional common Node* followTarget;
	/// <summary>
	/// Creates a new instance of `PlatformCamera`.
	/// </summary>
	/// <param name="name">An optional string that specifies the name of the new instance. Default is an empty string.</param>
	static PlatformCamera* create(string name = "");
};

/// <summary>
/// A struct representing a 2D platformer game world with physics simulations.
/// </summary>
object class PlatformWorld : public PhysicsWorld
{
	/// <summary>
	/// The camera used to control the view of the game world.
	/// </summary>
	readonly common Platformer::PlatformCamera* camera;
	/// <summary>
	/// Moves a child node to a new order for a different layer.
	/// </summary>
	/// <param name="child">The child node to be moved.</param>
	/// <param name="new_order">The new order of the child node.</param>
	void moveChild(Node* child, int newOrder);
	/// <summary>
	/// Gets the layer node at a given order.
	/// </summary>
	/// <param name="order">The order of the layer node to get.</param>
	Node* getLayer(int order);
	/// <summary>
	/// Sets the parallax moving ratio for a given layer to simulate 3D projection effect.
	/// </summary>
	/// <param name="order">The order of the layer to set the ratio for.</param>
	/// <param name="ratio">The new parallax ratio for the layer.</param>
	void setLayerRatio(int order, Vec2 ratio);
	/// <summary>
	/// Gets the parallax moving ratio for a given layer.
	/// </summary>
	/// <param name="order">The order of the layer to get the ratio for.</param>
	Vec2 getLayerRatio(int order);
	/// <summary>
	/// Sets the position offset for a given layer.
	/// </summary>
	/// <param name="order">The order of the layer to set the offset for.</param>
	/// <param name="offset">A `Vec2` representing the new position offset for the layer.</param>
	void setLayerOffset(int order, Vec2 offset);
	/// <summary>
	/// Gets the position offset for a given layer.
	/// </summary>
	/// <param name="order">The order of the layer to get the offset for.</param>
	Vec2 getLayerOffset(int order);
	/// <summary>
	/// Swaps the positions of two layers.
	/// </summary>
	/// <param name="orderA">The order of the first layer to swap.</param>
	/// <param name="orderB">The order of the second layer to swap.</param>
	void swapLayer(int orderA, int orderB);
	/// <summary>
	/// Removes a layer from the game world.
	/// </summary>
	/// <param name="order">The order of the layer to remove.</param>
	void removeLayer(int order);
	/// <summary>
	/// Removes all layers from the game world.
	/// </summary>
	void removeAllLayers();
	/// <summary>
	/// The method to create a new instance of `PlatformWorld`.
	/// </summary>
	static PlatformWorld* create();
};

/// <summary>
/// An interface that provides a centralized location for storing and accessing game-related data.
/// </summary>
singleton class Data
{
	/// <summary>
	/// The group key representing the first index for a player group.
	/// </summary>
	readonly common uint8_t groupFirstPlayer;
	/// <summary>
	/// The group key representing the last index for a player group.
	/// </summary>
	readonly common uint8_t groupLastPlayer;
	/// <summary>
	/// The group key that won't have any contact with other groups by default.
	/// </summary>
	readonly common uint8_t groupHide;
	/// <summary>
	/// The group key that will have contacts with player groups by default.
	/// </summary>
	readonly common uint8_t groupDetectPlayer;
	/// <summary>
	/// The group key representing terrain that will have contacts with other groups by default.
	/// </summary>
	readonly common uint8_t groupTerrain;
	/// <summary>
	/// The group key that will have contacts with other groups by default.
	/// </summary>
	readonly common uint8_t groupDetection;
	/// <summary>
	/// The dictionary that can be used to store arbitrary data associated with string keys and various values globally.
	/// </summary>
	readonly common Dictionary* store;
	/// <summary>
	/// Sets a boolean value indicating whether two groups should be in contact or not.
	/// </summary>
	/// <param name="groupA">An integer representing the first group.</param>
	/// <param name="groupB">An integer representing the second group.</param>
	/// <param name="contact">A boolean indicating whether the two groups should be in contact.</param>
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	/// <summary>
	/// Gets a boolean value indicating whether two groups should be in contact or not.
	/// </summary>
	/// <param name="groupA">An integer representing the first group.</param>
	/// <param name="groupB">An integer representing the second group.</param>
	bool getShouldContact(uint8_t groupA, uint8_t groupB);
	/// <summary>
	/// Sets the relation between two groups.
	/// </summary>
	/// <param name="groupA">An integer representing the first group.</param>
	/// <param name="groupB">An integer representing the second group.</param>
	/// <param name="relation">The relation between the two groups.</param>
	void setRelation(uint8_t groupA, uint8_t groupB, Platformer::Relation relation);
	/// <summary>
	/// Gets the relation between two groups.
	/// </summary>
	/// <param name="groupA">An integer representing the first group.</param>
	/// <param name="groupB">An integer representing the second group.</param>
	Platformer::Relation getRelation @ getRelationByGroup(uint8_t groupA, uint8_t groupB);
	/// <summary>
	/// A function that can be used to get the relation between two bodies.
	/// </summary>
	/// <param name="bodyA">The first body.</param>
	/// <param name="bodyB">The second body.</param>
	Platformer::Relation getRelation(Body* bodyA, Body* bodyB);
	/// <summary>
	/// A function that returns whether two groups have an "Enemy" relation.
	/// </summary>
	/// <param name="groupA">An integer representing the first group.</param>
	/// <param name="groupB">An integer representing the second group.</param>
	bool isEnemy @ isEnemyGroup(uint8_t groupA, uint8_t groupB);
	/// <summary>
	/// A function that returns whether two bodies have an "Enemy" relation.
	/// </summary>
	/// <param name="bodyA">The first body.</param>
	/// <param name="bodyB">The second body.</param>
	bool isEnemy(Body* bodyA, Body* bodyB);
	/// <summary>
	/// A function that returns whether two groups have a "Friend" relation.
	/// </summary>
	/// <param name="groupA">An integer representing the first group.</param>
	/// <param name="groupB">An integer representing the second group.</param>
	bool isFriend @ isFriendGroup(uint8_t groupA, uint8_t groupB);
	/// <summary>
	/// A function that returns whether two bodies have a "Friend" relation.
	/// </summary>
	/// <param name="bodyA">The first body.</param>
	/// <param name="bodyB">The second body.</param>
	bool isFriend(Body* bodyA, Body* bodyB);
	/// <summary>
	/// A function that returns whether two groups have a "Neutral" relation.
	/// </summary>
	/// <param name="groupA">An integer representing the first group.</param>
	/// <param name="groupB">An integer representing the second group.</param>
	bool isNeutral @ isNeutralGroup(uint8_t groupA, uint8_t groupB);
	/// <summary>
	/// A function that returns whether two bodies have a "Neutral" relation.
	/// </summary>
	/// <param name="bodyA">The first body.</param>
	/// <param name="bodyB">The second body.</param>
	bool isNeutral(Body* bodyA, Body* bodyB);
	/// <summary>
	/// Sets the bonus factor for a particular type of damage against a particular type of defence.
	/// The builtin "MeleeAttack" and "RangeAttack" actions use a simple formula of `finalDamage = damage * bonus`.
	/// </summary>
	/// <param name="damageType">An integer representing the type of damage.</param>
	/// <param name="defenceType">An integer representing the type of defence.</param>
	/// <param name="bonus">A number representing the bonus.</param>
	void setDamageFactor(uint16_t damageType, uint16_t defenceType, float bounus);
	/// <summary>
	/// Gets the bonus factor for a particular type of damage against a particular type of defence.
	/// </summary>
	/// <param name="damageType">An integer representing the type of damage.</param>
	/// <param name="defenceType">An integer representing the type of defence.</param>
	float getDamageFactor(uint16_t damageType, uint16_t defenceType);
	/// <summary>
	/// A function that returns whether a body is a player or not.
	/// This works the same as `Data::get_group_first_player() <= body.group and body.group <= Data::get_group_last_player()`.
	/// </summary>
	/// <param name="body">The body to check.</param>
	bool isPlayer(Body* body);
	/// <summary>
	/// A function that returns whether a body is terrain or not.
	/// This works the same as `body.group == Data.GetGroupTerrain()`.
	/// </summary>
	/// <param name="body">The body to check.</param>
	bool isTerrain(Body* body);
	/// <summary>
	/// Clears all data stored in the "Data" object, including user data in Data.store field. And reset some data to default values.
	/// </summary>
	void clear();
};

}

object class Buffer {
	common string text;
	void resize(uint32_t size);
	void zeroMemory();
	uint32_t size @ get_size() const;
};

singleton struct ImGui {

static void Binding::SetDefaultFont @ SetDefaultFont(string ttfFontFile, float fontSize);

static void Binding::ShowStats @ showStats();
static void Binding::ShowConsole @ showConsole();

static bool Binding::Begin @ _beginOpts(
	string name,
	uint32_t windowsFlags);

static void End @ _end();

static bool Binding::BeginChild @ _beginChildOpts(
	string str_id,
	Vec2 size,
	uint32_t childFlags,
	uint32_t windowFlags);

static bool Binding::BeginChild @ _beginChildWith_idOpts(
	uint32_t id,
	Vec2 size,
	uint32_t childFlags,
	uint32_t windowFlags);

static void EndChild @ _endChild();

static void Binding::SetNextWindowPosCenter @ _setNextWindowPosCenterOpts(uint32_t setCond);

static void SetNextWindowSize @ _setNextWindowSizeOpts(
	Vec2 size,
	uint32_t setCond);

static void SetNextWindowCollapsed @ _setNextWindowCollapsedOpts(
	bool collapsed,
	uint32_t setCond);

static void Binding::SetWindowPos @ _setWindowPosOpts(
	string name,
	Vec2 pos,
	uint32_t setCond);

static void Binding::SetWindowSize @ _setWindowSizeOpts(
	string name,
	Vec2 size,
	uint32_t setCond);

static void Binding::SetWindowCollapsed @ _setWindowCollapsedOpts(
	string name,
	bool collapsed,
	uint32_t setCond);

static void SetColorEditOptions @ _setColorEditOptions(uint32_t colorEditFlags);

static bool Binding::InputText @ _inputTextOpts(
	string label,
	Buffer* buffer,
	uint32_t inputTextFlags);

static bool Binding::InputTextMultiline @ _inputTextMultilineOpts(
	string label,
	Buffer* buffer,
	Vec2 size,
	uint32_t inputTextFlags);

static bool Binding::TreeNodeEx @ _treeNodeExOpts(
	string label,
	uint32_t treeNodeFlags);

static bool Binding::TreeNodeEx @ _treeNodeExWith_idOpts(
	string str_id,
	string text,
	uint32_t treeNodeFlags);

static void SetNextItemOpen @ _setNextItemOpenOpts(
	bool is_open,
	uint32_t setCond);

static bool Binding::CollapsingHeader @ _collapsingHeaderOpts(
	string label,
	uint32_t treeNodeFlags);

static bool Binding::Selectable @ _selectableOpts(
	string label,
	uint32_t selectableFlags);

static bool Binding::BeginPopupModal @ _beginPopupModalOpts(
	string name,
	uint32_t windowsFlags);

static bool Binding::BeginPopupModal @ _beginPopupModal_ret_opts(
	string name,
	CallStack* stack,
	uint32_t windowsFlags);

static bool Binding::BeginPopupContextItem @ _beginPopupContextItemOpts(
	string name,
	uint32_t popupFlags);

static bool Binding::BeginPopupContextWindow @ _beginPopupContextWindowOpts(
	string name,
	uint32_t popupFlags);

static bool Binding::BeginPopupContextVoid @ _beginPopupContextVoidOpts(
	string name,
	uint32_t popupFlags);

static void Binding::PushStyleColor @ _pushStyleColor(uint32_t name, Color color);
static void PushStyleVar @ _pushStyleFloat(uint32_t name, float val);
static void PushStyleVar @ _pushStyleVec2(uint32_t name, Vec2 val);

static void Binding::Text @ text(string text);
static void Binding::TextColored @ textColored(Color color, string text);
static void Binding::TextDisabled @ textDisabled(string text);
static void Binding::TextWrapped @ textWrapped(string text);

static void Binding::LabelText @ labelText(string label, string text);
static void Binding::BulletText @ bulletText(string text);
static bool Binding::TreeNode @ _treeNode(string str_id, string text);
static void Binding::SetTooltip @ setTooltip(string text);

static void Binding::Image @ image(string clipStr, Vec2 size);

static void Binding::Image @ imageWithBg(
	string clipStr,
	Vec2 size,
	Color bg_col,
	Color tint_col);

static bool Binding::ImageButton @ imageButtonOpts(
	string str_id,
	string clipStr,
	Vec2 size,
	Color bg_col,
	Color tint_col);

static bool Binding::ColorButton @ _colorButtonOpts(
	string desc_id,
	Color col,
	uint32_t colorEditFlags,
	Vec2 size);

static void Binding::Columns @ columns(int count);

static void Binding::Columns @ columnsOpts(
	int count,
	bool border,
	string str_id);

static bool Binding::BeginTable @ _beginTableOpts(
	string str_id,
	int column,
	Vec2 outer_size,
	float inner_width,
	uint32_t tableFlags);

static void TableNextRow @ _tableNextRowOpts(
	float min_row_height,
	uint32_t tableRowFlag);

static void Binding::TableSetupColumn @ _tableSetupColumnOpts(
	string label,
	float init_width_or_weight,
	uint32_t user_id,
	uint32_t tableColumnFlags);

static void Binding::SetStyleVar @ setStyleBool(string name, bool val);
static void Binding::SetStyleVar @ setStyleFloat(string name, float val);
static void Binding::SetStyleVar @ setStyleVec2(string name, Vec2 val);
static void Binding::SetStyleColor @ setStyleColor(string name, Color color);

static bool Binding::Begin @ _begin_ret_opts(
	string name,
	CallStack* stack,
	uint32_t windowsFlags);

static bool Binding::CollapsingHeader @ _collapsingHeader_ret_opts(
	string label,
	CallStack* stack,
	uint32_t treeNodeFlags);

static bool Binding::Selectable @ _selectable_ret_opts(
	string label,
	CallStack* stack,
	Vec2 size,
	uint32_t selectableFlags);

static bool Binding::Combo @ _comboRetOpts(
	string label,
	CallStack* stack,
	VecStr items,
	int height_in_items);

static bool Binding::DragFloat @ _dragFloatRetOpts(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max,
	string display_format,
	uint32_t sliderFlags);

static bool Binding::DragFloat2 @ _dragFloat2RetOpts(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max,
	string display_format,
	uint32_t sliderFlags);

static bool Binding::DragInt @ _dragIntRetOpts(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max,
	string display_format,
	uint32_t sliderFlags);

static bool Binding::DragInt2 @ _dragInt2RetOpts(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max,
	string display_format,
	uint32_t sliderFlags);

static bool Binding::InputFloat @ _inputFloatRetOpts(
	string label,
	CallStack* stack,
	float step,
	float step_fast,
	string display_format,
	uint32_t inputTextFlags);

static bool Binding::InputFloat2 @ _inputFloat2RetOpts(
	string label,
	CallStack* stack,
	string display_format,
	uint32_t inputTextFlags);

static bool Binding::InputInt @ _inputIntRetOpts(
	string label,
	CallStack* stack,
	int step,
	int step_fast,
	uint32_t inputTextFlags);

static bool Binding::InputInt2 @ _inputInt2RetOpts(
	string label,
	CallStack* stack,
	uint32_t inputTextFlags);

static bool Binding::SliderFloat @ _sliderFloatRetOpts(
	string label,
	CallStack* stack,
	float v_min,
	float v_max,
	string display_format,
	uint32_t sliderFlags);

static bool Binding::SliderFloat2 @ _sliderFloat2RetOpts(
	string label,
	CallStack* stack,
	float v_min,
	float v_max,
	string display_format,
	uint32_t sliderFlags);

static bool Binding::SliderInt @ _sliderIntRetOpts(
	string label,
	CallStack* stack,
	int v_min,
	int v_max,
	string format,
	uint32_t sliderFlags);

static bool Binding::SliderInt2 @ _sliderInt2RetOpts(
	string label,
	CallStack* stack,
	int v_min,
	int v_max,
	string display_format,
	uint32_t sliderFlags);

static bool Binding::DragFloatRange2 @ _dragFloatRange2RetOpts(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max,
	string format,
	string format_max,
	uint32_t sliderFlags);

static bool Binding::DragIntRange2 @ _dragIntRange2RetOpts(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max,
	string format,
	string format_max,
	uint32_t sliderFlags);

static bool Binding::VSliderFloat @ _vSliderFloatRetOpts(
	string label,
	Vec2 size,
	CallStack* stack,
	float v_min,
	float v_max,
	string format,
	uint32_t sliderFlags);

static bool Binding::VSliderInt @ _vSliderIntRetOpts(
	string label,
	Vec2 size,
	CallStack* stack,
	int v_min,
	int v_max,
	string format,
	uint32_t sliderFlags);

static bool Binding::ColorEdit3 @ _colorEdit3Ret_opts(string label, CallStack* stack, uint32_t colorEditFlags);

static bool Binding::ColorEdit4 @ _colorEdit4Ret_opts(string label, CallStack* stack, uint32_t colorEditFlags);

static void Binding::ScrollWhenDraggingOnVoid @ scrollWhenDraggingOnVoid();

static void SetNextWindowPos @ _setNextWindowPosOpts(Vec2 pos, uint32_t setCond, Vec2 pivot);
static void SetNextWindowBgAlpha(float alpha);
static void ShowDemoWindow();
static Vec2 GetContentRegionAvail();
static Vec2 GetWindowPos();
static Vec2 GetWindowSize();
static float GetWindowWidth();
static float GetWindowHeight();
static bool IsWindowCollapsed();
static void SetNextWindowSizeConstraints(Vec2 size_min, Vec2 size_max);
static void SetNextWindowContentSize(Vec2 size);
static void SetNextWindowFocus();
static float GetScrollX();
static float GetScrollY();
static float GetScrollMaxX();
static float GetScrollMaxY();
static void SetScrollX(float scroll_x);
static void SetScrollY(float scroll_y);
static void SetScrollHereY(float center_y_ratio);
static void SetScrollFromPosY(float pos_y, float center_y_ratio);
static void SetKeyboardFocusHere(int offset);
static void PopStyleColor @ _popStyleColor(int count);
static void PopStyleVar @ _popStyleVar(int count);
static void SetNextItemWidth(float item_width);
static void PushItemWidth @ _pushItemWidth(float item_width);
static void PopItemWidth @ _popItemWidth();
static float CalcItemWidth();
static void PushTextWrapPos @ _pushTextWrapPos(float wrap_pos_x);
static void PopTextWrapPos @ _popTextWrapPos();
static void PushItemFlag @ _pushItemFlag(uint32_t flag, bool enabled);
static void PopItemFlag @ _popItemFlag();
static void Separator();
static void SameLine(float pos_x, float spacing_w);
static void NewLine();
static void Spacing();
static void Dummy(Vec2 size);
static void Indent(float indent_w);
static void Unindent(float indent_w);
static void BeginGroup @ _beginGroup();
static void EndGroup @ _endGroup();
static Vec2 GetCursorPos();
static float GetCursorPosX();
static float GetCursorPosY();
static void SetCursorPos(Vec2 local_pos);
static void SetCursorPosX(float x);
static void SetCursorPosY(float y);
static Vec2 GetCursorStartPos();
static Vec2 GetCursorScreenPos();
static void SetCursorScreenPos(Vec2 pos);
static void AlignTextToFramePadding();
static float GetTextLineHeight();
static float GetTextLineHeightWithSpacing();
static void NextColumn();
static int GetColumnIndex();
static float GetColumnOffset(int column_index);
static void SetColumnOffset(int column_index, float offset_x);
static float GetColumnWidth(int column_index);
static int GetColumnsCount();
static void EndTable @ _endTable();
static bool TableNextColumn();
static bool TableSetColumnIndex(int column_n);
static void TableSetupScrollFreeze(int cols, int rows);
static void TableHeadersRow();
static void Bullet @ bulletItem();
static bool Binding::TextLink @ TextLink(string label);

static void Binding::SetWindowFocus @ SetWindowFocus(string name);
static void Binding::SeparatorText @ SeparatorText(string text);
static void Binding::TableHeader @ TableHeader(string label);
static void Binding::PushID @ _push_id(string str_id);
static void PopID @ _pop_id();
static uint32_t Binding::GetID @ get_id(string str_id);
static bool Binding::Button @ Button(string label, Vec2 size);
static bool Binding::SmallButton @ SmallButton(string label);
static bool Binding::InvisibleButton @ InvisibleButton(string str_id, Vec2 size);

static bool Binding::Checkbox @ _checkboxRet(string label, CallStack* stack);
static bool Binding::RadioButton @ _radioButtonRet(string label, CallStack* stack, int v_button);

static void Binding::PlotLines @ PlotLines(string label, VecFloat values);
static void Binding::PlotLines @ plotLinesOpts(string label, VecFloat values, int values_offset, string overlay_text, float scale_min, float scale_max, Vec2 graph_size);

static void Binding::PlotHistogram @ PlotHistogram(string label, VecFloat values);
static void Binding::PlotHistogram @ plotHistogramOpts(string label, VecFloat values, int values_offset, string overlay_text, float scale_min, float scale_max, Vec2 graph_size);

static void Binding::ProgressBar @ ProgressBar(float fraction);
static void Binding::ProgressBar @ ProgressBarOpts(float fraction, Vec2 size_arg, string overlay);

static bool Binding::ListBox @ _listBoxRetOpts(string label, CallStack* stack, VecStr items, int height_in_items);

static bool Binding::SliderAngle @ _sliderAngleRet(string label, CallStack* stack, float v_degrees_min, float v_degrees_max);

static void Binding::TreePush @ _treePush(string str_id);
static void TreePop @ _treePop();
static void Binding::Value @ Value(string prefix, bool b);
static bool Binding::MenuItem @ MenuItem(string label, string shortcut, bool selected, bool enabled);
static void Binding::OpenPopup @ OpenPopup(string str_id);
static bool Binding::BeginPopup @ _beginPopup(string str_id);
static void EndPopup @ _endPopup();

static float GetTreeNodeToLabelSpacing();
static bool Binding::BeginListBox @ _beginListBox(string label, Vec2 size);
static void EndListBox @ _endListBox();
static void BeginDisabled @ _beginDisabled();
static void EndDisabled @ _endDisabled();
static bool BeginTooltip @ _beginTooltip();
static void EndTooltip @ _endTooltip();
static bool BeginMainMenuBar @ _beginMainMenuBar();
static void EndMainMenuBar @ _endMainMenuBar();
static bool BeginMenuBar @ _beginMenuBar();
static void EndMenuBar @ _endMenuBar();
static bool Binding::BeginMenu @ _beginMenu(string label, bool enabled);
static void EndMenu @ _endMenu();
static void CloseCurrentPopup();
static void PushClipRect @ _pushClipRect(Vec2 clip_rect_min, Vec2 clip_rect_max, bool intersect_with_current_clip_rect);
static void PopClipRect @ _popClipRect();
static bool IsItemHovered();
static bool IsItemActive();
static bool IsItemClicked(int mouse_button);
static bool IsItemVisible();
static bool IsAnyItemHovered();
static bool IsAnyItemActive();
static Vec2 GetItemRectMin();
static Vec2 GetItemRectMax();
static Vec2 GetItemRectSize();
static void SetNextItemAllowOverlap();
static bool IsWindowHovered();
static bool IsWindowFocused();
static bool IsRectVisible(Vec2 size);
static bool IsMouseDown(int button);
static bool IsMouseClicked(int button, bool repeat);
static bool IsMouseDoubleClicked(int button);
static bool IsMouseReleased(int button);
static bool IsMouseHoveringRect(Vec2 r_min, Vec2 r_max, bool clip);
static bool IsMouseDragging(int button, float lock_threshold);
static Vec2 GetMousePos();
static Vec2 GetMousePosOnOpeningCurrentPopup();
static Vec2 GetMouseDragDelta(int button, float lock_threshold);
static void ResetMouseDragDelta(int button);

static bool Binding::BeginTabBar @ _beginTabBar(string str_id);
static bool Binding::BeginTabBar @ _beginTabBarOpts(string str_id, uint32_t flags);
static void EndTabBar @ _endTabBar();
static bool Binding::BeginTabItem @ _beginTabItem(string label);
static bool Binding::BeginTabItem @ _beginTabItemOpts(string label, uint32_t flags);
static bool Binding::BeginTabItem @ _beginTabItemRet(string label, CallStack* stack);
static bool Binding::BeginTabItem @ _beginTabItemRetOpts(string label, CallStack* stack, uint32_t flags);
static void EndTabItem @ _endTabItem();
static bool Binding::TabItemButton @ TabItemButton(string label);
static bool Binding::TabItemButton @ _tabItemButtonOpts(string label, uint32_t flags);
static void Binding::SetTabItemClosed @ SetTabItemClosed(string tab_or_docked_window_label);
};

value struct NVGpaint @ VGPaint { };

singleton struct nvg @ Nvg
{
	static void Save();
	static void Restore();
	static void Reset();
	static int CreateImage @ _createImage(int w, int h, string filename, int imageFlags);
	static int CreateFont(string name);
	static float TextBounds(float x, float y, string text, Rect bounds);
	static Rect TextBoxBounds(float x, float y, float breakRowWidth, string text);
	static float Text(float x, float y, string text);
	static void TextBox(float x, float y, float breakRowWidth, string text);
	static void StrokeColor(Color color);
	static void StrokePaint(NVGpaint paint);
	static void FillColor(Color color);
	static void FillPaint(NVGpaint paint);
	static void MiterLimit(float limit);
	static void StrokeWidth(float size);
	static void LineCap @ _lineCap(int cap);
	static void LineJoin @ _lineJoin(int join);
	static void GlobalAlpha(float alpha);
	static void ResetTransform();
	static void ApplyTransform(Node* node);
	static void Translate(float x, float y);
	static void Rotate(float angle);
	static void SkewX(float angle);
	static void SkewY(float angle);
	static void Scale(float x, float y);
	static Size ImageSize(int image);
	static void DeleteImage(int image);
	static NVGpaint LinearGradient(float sx, float sy, float ex, float ey, Color icol, Color ocol);
	static NVGpaint BoxGradient(float x, float y, float w, float h, float r, float f, Color icol, Color ocol);
	static NVGpaint RadialGradient(float cx, float cy, float inr, float outr, Color icol, Color ocol);
	static NVGpaint ImagePattern(float ox, float oy, float ex, float ey, float angle, int image, float alpha);
	static void Scissor(float x, float y, float w, float h);
	static void IntersectScissor(float x, float y, float w, float h);
	static void ResetScissor();
	static void BeginPath();
	static void MoveTo(float x, float y);
	static void LineTo(float x, float y);
	static void BezierTo(float c1x, float c1y, float c2x, float c2y, float x, float y);
	static void QuadTo(float cx, float cy, float x, float y);
	static void ArcTo(float x1, float y1, float x2, float y2, float radius);
	static void ClosePath();
	static void PathWinding @ _pathWinding(int dir);
	static void Arc @ _arc(float cx, float cy, float r, float a0, float a1, int dir);
	static void Rectangle @ Rect(float x, float y, float w, float h);
	static void RoundedRect(float x, float y, float w, float h, float r);
	static void RoundedRectVarying(float x, float y, float w, float h, float radTopLeft, float radTopRight, float radBottomRight, float radBottomLeft);
	static void Ellipse(float cx, float cy, float rx, float ry);
	static void Circle(float cx, float cy, float r);
	static void Fill();
	static void Stroke();
	static int FindFont(string name);
	static int AddFallbackFontId(int baseFont, int fallbackFont);
	static int AddFallbackFont(string baseFont, string fallbackFont);
	static void FontSize(float size);
	static void FontBlur(float blur);
	static void TextLetterSpacing(float spacing);
	static void TextLineHeight(float lineHeight);
	static void TextAlign @ _textAlign(int hAlign, int vAlign);
	static void FontFaceId(int font);
	static void FontFace(string font);
	static void DoraSSR @ dora_ssr();
	static Texture2D* GetDoraSSR @ get_dora_ssr(float scale);
};

/// <summary>
/// A node for rendering vector graphics.
/// </summary>
object class VGNode : public Node {
	/// <summary>
	/// The surface of the node for displaying frame buffer texture that contains vector graphics.
	/// You can get the texture of the surface by calling `vgNode.Surface.Texture`.
	/// </summary>
	readonly common Sprite* surface;
	/// <summary>
	/// The function for rendering vector graphics.
	/// </summary>
	/// <param name="renderFunc">The closure function for rendering vector graphics. You can do the rendering operations inside this closure.</param>
	void render(function<void()> renderFunc);
	/// <summary>
	/// Creates a new VGNode object with the specified width and height.
	/// </summary>
	/// <param name="width">The width of the node's frame buffer texture.</param>
	/// <param name="height">The height of the node's frame buffer texture.</param>
	/// <param name="scale">The scale factor of the VGNode.</param>
	/// <param name="edgeAA">The edge anti-aliasing factor of the VGNode.</param>
	static VGNode* create(float width, float height, float scale, int edgeAA);
};
