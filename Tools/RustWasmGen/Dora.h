/// An array data structure that supports various operations.
object class Array
{
	/// the number of items in the array.
	readonly common size_t count;
	/// whether the array is empty or not.
	readonly boolean bool empty;
	/// Adds all items from another array to the end of this array.
	///
	/// # Arguments
	///
	/// * `other` - Another array object.
	void addRange(Array* other);
	/// Removes all items from this array that are also in another array.
	///
	/// # Arguments
	///
	/// * `other` - Another array object.
	void removeFrom(Array* other);
	/// Removes all items from the array.
	void clear();
	/// Reverses the order of the items in the array.
	void reverse();
	/// Removes any empty slots from the end of the array.
	/// This method is used to release the unused memory this array holds.
	void shrink();
	/// Swaps the items at two given indices.
	///
	/// # Arguments
	///
	/// * `index_a` - The first index.
	/// * `index_b` - The second index.
	void swap(int indexA, int indexB);
	/// Removes the item at the given index.
	///
	/// # Arguments
	///
	/// * `index` - The index to remove.
	///
	/// # Returns
	///
	/// * `bool` - `true` if an item was removed, `false` otherwise.
	bool removeAt(int index);
	/// Removes the item at the given index without preserving the order of the array.
	///
	/// # Arguments
	///
	/// * `index` - The index to remove.
	///
	/// # Returns
	///
	/// * `bool` - `true` if an item was removed, `false` otherwise.
	bool fastRemoveAt(int index);
	/// Creates a new array object
	static Array* create();
};

/// A struct for storing pairs of string keys and various values.
object class Dictionary
{
	/// the number of items in the dictionary.
	readonly common int count;
	/// the keys of the items in the dictionary.
	readonly common VecStr keys;
	/// Removes all the items from the dictionary.
	void clear();
	/// Creates instance of the "Dictionary".
	static Dictionary* create();
};

/// A rectangle object with a left-bottom origin position and a size.
value struct Rect
{
	/// the position of the origin of the rectangle.
	Vec2 origin;
	/// the dimensions of the rectangle.
	Size size;
	/// the x-coordinate of the origin of the rectangle.
	common float x;
	/// the y-coordinate of the origin of the rectangle.
	common float y;
	/// the width of the rectangle.
	common float width;
	/// the height of the rectangle.
	common float height;
	/// the left edge in x-axis of the rectangle.
	common float left;
	/// the right edge in x-axis of the rectangle.
	common float right;
	/// the x-coordinate of the center of the rectangle.
	common float centerX;
	/// the y-coordinate of the center of the rectangle.
	common float centerY;
	/// the bottom edge in y-axis of the rectangle.
	common float bottom;
	/// the top edge in y-axis of the rectangle.
	common float top;
	/// the lower bound (left-bottom) of the rectangle.
	common Vec2 lowerBound;
	/// the upper bound (right-top) of the rectangle.
	common Vec2 upperBound;
	/// Sets the properties of the rectangle.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the origin of the rectangle.
	/// * `y` - The y-coordinate of the origin of the rectangle.
	/// * `width` - The width of the rectangle.
	/// * `height` - The height of the rectangle.
	void set(float x, float y, float width, float height);
	/// Checks if a point is inside the rectangle.
	///
	/// # Arguments
	///
	/// * `point` - The point to check, represented by a Vec2 object.
	///
	/// # Returns
	///
	/// * `bool` - Whether or not the point is inside the rectangle.
	bool containsPoint(Vec2 point) const;
	/// Checks if the rectangle intersects with another rectangle.
	///
	/// # Arguments
	///
	/// * `rect` - The other rectangle to check for intersection with, represented by a Rect object.
	///
	/// # Returns
	///
	/// * `bool` - Whether or not the rectangles intersect.
	bool intersectsRect(Rect rect) const;
	/// Checks if two rectangles are equal.
	///
	/// # Arguments
	///
	/// * `other` - The other rectangle to compare to, represented by a Rect object.
	///
	/// # Returns
	///
	/// * `bool` - Whether or not the two rectangles are equal.
	bool operator== @ equals(Rect other) const;
	/// Creates a new rectangle object using a Vec2 object for the origin and a Size object for the size.
	///
	/// # Arguments
	///
	/// * `origin` - The origin of the rectangle, represented by a Vec2 object.
	/// * `size` - The size of the rectangle, represented by a Size object.
	///
	/// # Returns
	///
	/// * `Rect` - A new rectangle object.
	static Rect create(Vec2 origin, Size size);
	/// Gets a rectangle object with all properties set to 0.
	static outside Rect rect_get_zero @ zero();
};

/// A struct representing an application.
singleton class Application @ App
{
	/// the current passed frame number.
	readonly common uint32_t frame;
	/// the size of the main frame buffer texture used for rendering.
	readonly common Size bufferSize;
	/// the logic visual size of the screen.
	/// The visual size only changes when application window size changes.
	/// And it won't be affacted by the view buffer scaling factor.
	readonly common Size visualSize;
	/// the ratio of the pixel density displayed by the device
	/// Can be calculated as the size of the rendering buffer divided by the size of the application window.
	readonly common float devicePixelRatio;
	/// the platform the game engine is running on.
	readonly common string platform;
	/// the version string of the game engine.
	/// Should be in format of "v0.0.0".
	readonly common string version;
	/// the dependencies of the game engine.
	readonly common string deps;
	/// the time in seconds since the last frame update.
	readonly common double deltaTime;
	/// the elapsed time since current frame was started, in seconds.
	readonly common double elapsedTime;
	/// the total time the game engine has been running until last frame ended, in seconds.
	/// Should be a contant number when invoked in a same frame for multiple times.
	readonly common double totalTime;
	/// the total time the game engine has been running until this field being accessed, in seconds.
	/// Should be a increasing number when invoked in a same frame for multiple times.
	readonly common double runningTime;
	/// a random number generated by a random number engine based on Mersenne Twister algorithm.
	/// So that the random number generated by a same seed should be consistent on every platform.
	readonly common uint32_t rand;
	/// the maximum valid frames per second the game engine is allowed to run at.
	/// The max FPS is being inferred by the device screen max refresh rate.
	readonly common uint32_t maxFPS @ max_fps;
	/// whether the game engine is running in debug mode.
	readonly boolean bool debugging;
	/// the system locale string, in format like: `zh-Hans`, `en`.
	common string locale;
	/// the theme color for Dora SSR.
	common Color themeColor;
	/// the random number seed.
	common uint32_t seed;
	/// the target frames per second the game engine is supposed to run at.
	/// Only works when `fpsLimited` is set to true.
	common uint32_t targetFPS @ target_fps;
	/// the application window size.
	/// May differ from visual size due to the different DPIs of display devices.
	/// Set `winSize` to `Size.zero` to toggle application window into full screen mode,
	/// It is not available to set this property on platform Android and iOS.
	common Size winSize;
	/// the application window position.
	/// It is not available to set this property on platform Android and iOS.
	common Vec2 winPosition;
	/// whether the game engine is limiting the frames per second.
	/// Set `fpsLimited` to true, will make engine run in a busy loop to track the  precise frame time to switch to the next frame. And this behavior can lead to 100% CPU usage. This is usually common practice on Windows PCs for better CPU usage occupation. But it also results in extra heat and power consumption.
	boolean bool fPSLimited @ fpsLimited;
	/// whether the game engine is currently idled.
	/// Set `idled` to true, will make game logic thread use a sleep time and going idled for next frame to come. Due to the imprecision in sleep time. This idled state may cause game engine over slept for a few frames to lost.
	/// `idled` state can reduce some CPU usage.
	boolean bool idled;
	/// Shuts down the game engine.
	/// It is not working and acts as a dummy function for platform Android and iOS to follow the specification of how mobile platform applications should operate.
	void shutdown();
};

/// A struct representing an entity for an ECS game system.
object class Entity
{
	/// the number of all running entities.
	static readonly common uint32_t count;
	/// the index of the entity.
	readonly common int index;
	/// Clears all entities.
	static void clear();
	/// Removes a property of the entity.
	///
	/// This function will trigger events for Observer objects.
	///
	/// # Arguments
	///
	/// * `key` - The name of the property to remove.
	void remove(string key);
	/// Destroys the entity.
	void destroy();
	/// Creates a new entity.
	static Entity* create();
};

/// A struct representing a group of entities in the ECS game systems.
object class EntityGroup @ Group
{
	/// the number of entities in the group.
	readonly common int count;
	/// Finds the first entity in the group that satisfies a predicate function.
	///
	/// # Arguments
	///
	/// * `func` - The predicate function to test each entity with.
	///
	/// # Returns
	///
	/// * `Option<Entity>` - The first entity that satisfies the predicate, or None if no entity does.
	optional Entity* find(function<bool(Entity* e)> func) const;
	/// A method that creates a new group with the specified component names.
	///
	/// # Arguments
	///
	/// * `components` - A vector listing the names of the components to include in the group.
	///
	/// # Returns
	///
	/// * `Group` - The new group.
	static EntityGroup* create(VecStr components);
};

/// A struct representing an observer of entity changes in the game systems.
object class EntityObserver @ Observer
{
	/// A method that creates a new observer with the specified component filter and action to watch for.
	///
	/// # Arguments
	///
	/// * `event` - The type of event to watch for.
	/// * `components` - A vector listing the names of the components to filter entities by.
	///
	/// # Returns
	///
	/// * `Observer` - The new observer.
	static EntityObserver* create(EntityEvent event, VecStr components);
};

/// Helper struct for file path operations.
struct Path
{
	/// Extracts the file extension from a given file path.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT" Output: "txt"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	///
	/// # Returns
	///
	/// * `String` - The extension of the input file.
	static string getExt(string path);
	/// Extracts the parent path from a given file path.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT" Output: "/a/b"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	///
	/// # Returns
	///
	/// * `String` - The parent path of the input file.
	static string getPath(string path);
	/// Extracts the file name without extension from a given file path.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT" Output: "c"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	///
	/// # Returns
	///
	/// * `String` - The name of the input file without extension.
	static string getName(string path);
	/// Extracts the file name from a given file path.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT" Output: "c.TXT"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	///
	/// # Returns
	///
	/// * `String` - The name of the input file.
	static string getFilename(string path);
	/// Computes the relative path from the target file to the input file.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT", base: "/a" Output: "b/c.TXT"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	/// * `base` - The target file path.
	///
	/// # Returns
	///
	/// * `String` - The relative path from the input file to the target file.
	static string getRelative(string path, string target);
	/// Changes the file extension in a given file path.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT", "lua" Output: "/a/b/c.lua"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	/// * `new_ext` - The new file extension to replace the old one.
	///
	/// # Returns
	///
	/// * `String` - The new file path.
	static string replaceExt(string path, string newExt);
	/// Changes the filename in a given file path.
	///
	/// # Example
	///
	/// Input: "/a/b/c.TXT", "d" Output: "/a/b/d.TXT"
	///
	/// # Arguments
	///
	/// * `path` - The input file path.
	/// * `new_file` - The new filename to replace the old one.
	///
	/// # Returns
	///
	/// * `String` - The new file path.
	static string replaceFilename(string path, string newFile);
	/// Joins the given segments into a new file path.
	///
	/// # Example
	///
	/// Input: "a", "b", "c.TXT" Output: "a/b/c.TXT"
	///
	/// # Arguments
	///
	/// * `segments` - The segments to be joined as a new file path.
	///
	/// # Returns
	///
	/// * `String` - The new file path.
	static string concatVector @ concat(VecStr paths);
};

/// The `Content` is a static struct that manages file searching,
/// loading and other operations related to resources.
singleton class Content
{
	/// an array of directories to search for resource files.
	common VecStr searchPaths;
	/// the path to the directory containing read-only resources.
	readonly common string assetPath;
	/// the path to the directory where files can be written.
	readonly common string writablePath;
	/// Saves the specified content to a file with the specified filename.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to save.
	/// * `content` - The content to save to the file.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the content saves to file successfully, `false` otherwise.
	bool save(string filename, string content);
	/// Checks if a file with the specified filename exists.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the file exists, `false` otherwise.
	bool exist(string filename);
	/// Creates a new directory with the specified path.
	///
	/// # Arguments
	///
	/// * `path` - The path of the directory to create.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the directory was created, `false` otherwise.
	bool createFolder @ mkdir(string path);
	/// Checks if the specified path is a directory.
	///
	/// # Arguments
	///
	/// * `path` - The path to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the path is a directory, `false` otherwise.
	bool isFolder @ isdir(string path);
	/// Copies the file or directory at the specified source path to the target path.
	///
	/// # Arguments
	///
	/// * `src_path` - The path of the file or directory to copy.
	/// * `dst_path` - The path to copy the file or directory to.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the file or directory was successfully copied to the target path, `false` otherwise.
	bool copy(string src, string dst);
	/// Moves the file or directory at the specified source path to the target path.
	///
	/// # Arguments
	///
	/// * `src_path` - The path of the file or directory to move.
	/// * `dst_path` - The path to move the file or directory to.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the file or directory was successfully moved to the target path, `false` otherwise.
	bool move @ moveTo(string src, string dst);
	/// Removes the file or directory at the specified path.
	///
	/// # Arguments
	///
	/// * `path` - The path of the file or directory to remove.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the file or directory was successfully removed, `false` otherwise.
	bool remove(string path);
	/// Gets the full path of a file with the specified filename.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to get the full path of.
	///
	/// # Returns
	///
	/// * `String` - The full path of the file.
	string getFullPath(string filename);
	/// Adds a new search path to the end of the list.
	///
	/// # Arguments
	///
	/// * `path` - The search path to add.
	void addSearchPath(string path);
	/// Inserts a search path at the specified index.
	///
	/// # Arguments
	///
	/// * `index` - The index at which to insert the search path.
	/// * `path` - The search path to insert.
	void insertSearchPath(int index, string path);
	/// Removes the specified search path from the list.
	///
	/// # Arguments
	///
	/// * `path` - The search path to remove.
	void removeSearchPath(string path);
	/// Clears the search path cache of the map of relative paths to full paths.
	void clearPathCache();
	/// Gets the names of all subdirectories in the specified directory.
	///
	/// # Arguments
	///
	/// * `path` - The path of the directory to search.
	///
	/// # Returns
	///
	/// * `Vec<String>` - An array of the names of all subdirectories in the specified directory.
	VecStr getDirs(string path);
	/// Gets the names of all files in the specified directory.
	///
	/// # Arguments
	///
	/// * `path` - The path of the directory to search.
	///
	/// # Returns
	///
	/// * `Vec<String>` - An array of the names of all files in the specified directory.
	VecStr getFiles(string path);
	/// Gets the names of all files in the specified directory and its subdirectories.
	///
	/// # Arguments
	///
	/// * `path` - The path of the directory to search.
	///
	/// # Returns
	///
	/// * `Vec<String>` - An array of the names of all files in the specified directory and its subdirectories.
	VecStr getAllFiles(string path);
	/// Asynchronously loads the content of the file with the specified filename.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to load.
	/// * `callback` - The function to call with the content of the file once it is loaded.
	///
	/// # Returns
	///
	/// * `String` - The content of the loaded file.
	void loadAsync(string filename, function<void(string content)> callback);
	/// Asynchronously copies a file or a folder from the source path to the destination path.
	///
	/// # Arguments
	///
	/// * `src` - The path of the file or folder to copy.
	/// * `dst` - The destination path of the copied files.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the file or folder was copied successfully, `false` otherwise.
	void copyAsync(string srcFile, string targetFile, function<void(bool success)> callback);
	/// Asynchronously saves the specified content to a file with the specified filename.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to save.
	/// * `content` - The content to save to the file.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the content was saved successfully, `false` otherwise.
	void saveAsync(string filename, string content, function<void(bool success)> callback);
	/// Asynchronously compresses the specified folder to a ZIP archive with the specified filename.
	///
	/// # Arguments
	///
	/// * `folder_path` - The path of the folder to compress, should be under the asset writable path.
	/// * `zip_file` - The name of the ZIP archive to create.
	/// * `filter` - An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the folder was compressed successfully, `false` otherwise.
	void zipAsync(string folderPath, string zipFile, function<bool(string file)> filter, function<void(bool success)> callback);
	/// Asynchronously decompresses a ZIP archive to the specified folder.
	///
	/// # Arguments
	///
	/// * `zip_file` - The name of the ZIP archive to decompress, should be a file under the asset writable path.
	/// * `folder_path` - The path of the folder to decompress to, should be under the asset writable path.
	/// * `filter` - An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the folder was decompressed successfully, `false` otherwise.
	void unzipAsync(string zipFile, string folderPath, function<bool(string file)> filter, function<void(bool success)> callback);
};

/// A scheduler that manages the execution of scheduled tasks.
object class Scheduler
{
	/// the time scale factor for the scheduler.
	/// This factor is applied to deltaTime that the scheduled functions will receive.
	common float timeScale;
	/// the target frame rate (in frames per second) for a fixed update mode.
	/// The fixed update will ensure a constant frame rate, and the operation handled in a fixed update can use a constant delta time value.
	/// It is used for preventing weird behavior of a physics engine or synchronizing some states via network communications.
	common int fixedFPS @ fixed_fps;
	/// Schedules a function to be called every frame.
	///
	/// # Arguments
	///
	/// * `handler` - The function to be called. It should take a single argument of type `f64`, which represents the delta time since the last frame. If the function returns `true`, it will not be called again.
	void schedule(function<bool(double deltaTime)> func);
	/// Creates a new Scheduler object.
	static Scheduler* create();
};

/// A struct for Camera object in the game engine.
interface object class Camera
{
	/// the name of the Camera.
	readonly common string name;
};

/// A struct for 2D camera object in the game engine.
object class Camera2D : public ICamera
{
	/// the rotation angle of the camera in degrees.
	common float rotation;
	/// the factor by which to zoom the camera. If set to 1.0, the view is normal sized. If set to 2.0, items will appear double in size.
	common float zoom;
	/// the position of the camera in the game world.
	common Vec2 position;
	/// Creates a new Camera2D object with the given name.
	///
	/// # Arguments
	///
	/// * `name` - The name of the Camera2D object.
	///
	/// # Returns
	///
	/// * `Camera2D` - A new instance of the Camera2D object.
	static Camera2D* create(string name);
};

/// A struct for an orthographic camera object in the game engine.
object class CameraOtho : public ICamera
{
	/// the position of the camera in the game world.
	common Vec2 position;
	/// Creates a new CameraOtho object with the given name.
	///
	/// # Arguments
	///
	/// * `name` - The name of the CameraOtho object.
	///
	/// # Returns
	///
	/// * `CameraOtho` - A new instance of the CameraOtho object.
	static CameraOtho* create(string name);
};

/// A struct representing a shader pass.
object class Pass
{
	/// whether this Pass should be a grab pass.
	/// A grab pass will render a portion of game scene into a texture frame buffer.
	/// Then use this texture frame buffer as an input for next render pass.
	boolean bool grabPass;
	/// Sets the value of shader parameters.
	///
	/// # Arguments
	///
	/// * `name` - The name of the parameter to set.
	/// * `var` - The numeric value to set.
	void set @ set(string name, float var);
	/// Sets the values of shader parameters.
	///
	/// # Arguments
	///
	/// * `name` - The name of the parameter to set.
	/// * `var1` - The first numeric value to set.
	/// * `var2` - An optional second numeric value to set.
	/// * `var3` - An optional third numeric value to set.
	/// * `var4` - An optional fourth numeric value to set.
	void set @ setVec4(string name, float var1, float var2, float var3, float var4);
	/// Another function that sets the values of shader parameters.
	///
	/// Works the same as:
	/// pass.set("varName", color.r / 255.0, color.g / 255.0, color.b / 255.0, color.opacity);
	///
	/// # Arguments
	///
	/// * `name` - The name of the parameter to set.
	/// * `var` - The Color object to set.
	void set @ setColor(string name, Color var);
	/// Creates a new Pass object.
	///
	/// # Arguments
	///
	/// * `vert_shader` - The vertex shader in binary form file string.
	/// * `frag_shader` - The fragment shader file string. A shader file string must be one of the formats:
	///     * "builtin:" + theBuiltinShaderName
	///     * "Shader/compiled_shader_file.bin"
	///
	/// # Returns
	///
	/// * `Pass` - A new Pass object.
	static Pass* create(string vertShader, string fragShader);
};

/// A struct for managing multiple render pass objects.
/// Effect objects allow you to combine multiple passes to create more complex shader effects.
interface object class Effect
{
	/// Adds a Pass object to this Effect.
	///
	/// # Arguments
	///
	/// * `pass` - The Pass object to add.
	void add(Pass* pass);
	/// Retrieves a Pass object from this Effect by index.
	///
	/// # Arguments
	///
	/// * `index` - The index of the Pass object to retrieve.
	///
	/// # Returns
	///
	/// * `Pass` - The Pass object at the given index.
	outside optional Pass* effect_get_pass @ get(size_t index) const;
	/// Removes all Pass objects from this Effect.
	void clear();
	/// A method that allows you to create a new Effect object.
	///
	/// # Arguments
	///
	/// * `vert_shader` - The vertex shader file string.
	/// * `frag_shader` - The fragment shader file string. A shader file string must be one of the formats:
	///     * "builtin:" + theBuiltinShaderName
	///     * "Shader/compiled_shader_file.bin"
	///
	/// # Returns
	///
	/// * `Effect` - A new Effect object.
	static Effect* create(string vertShader, string fragShader);
};

/// A struct that is a specialization of Effect for rendering 2D sprites.
object class SpriteEffect : public IEffect
{
	/// A method that allows you to create a new SpriteEffect object.
	///
	/// # Arguments
	///
	/// * `vert_shader` - The vertex shader file string.
	/// * `frag_shader` - The fragment shader file string. A shader file string must be one of the formats:
	///     * "builtin:" + theBuiltinShaderName
	///     * "Shader/compiled_shader_file.bin"
	///
	/// # Returns
	///
	/// * `SpriteEffect` - A new SpriteEffect object.
	static SpriteEffect* create(string vertShader, string fragShader);
};

/// A struct manages the game scene trees and provides access to root scene nodes for different game uses.
singleton class Director
{
	/// the background color for the game world.
	common Color clearColor;
	/// the game scheduler which is used for scheduling tasks like animations and gameplay events.
	common Scheduler* scheduler;
	/// the root node for 2D user interface elements like buttons and labels.
	readonly common Node* uI @ ui;
	/// the root node for 3D user interface elements with 3D projection effect.
	readonly common Node* uI3D @ ui_3d;
	/// the root node for the starting point of a game.
	readonly common Node* entry;
	/// the root node for post-rendering scene tree.
	readonly common Node* postNode;
	/// the system scheduler which is used for low-level system tasks, should not put any game logic in it.
	readonly common Scheduler* systemScheduler;
	/// the scheduler used for processing post game logic.
	readonly common Scheduler* postScheduler;
	/// the current active camera in Director's camera stack.
	readonly common Camera* currentCamera;
	/// Adds a new camera to Director's camera stack and sets it to the current camera.
	///
	/// # Arguments
	///
	/// * `camera` - The camera to add.
	void pushCamera(Camera* camera);
	/// Removes the current camera from Director's camera stack.
	void popCamera();
	/// Removes a specified camera from Director's camera stack.
	///
	/// # Arguments
	///
	/// * `camera` - The camera to remove.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the camera was removed, `false` otherwise.
	bool removeCamera(Camera* camera);
	/// Removes all cameras from Director's camera stack.
	void clearCamera();
	/// Cleans up all resources managed by the Director, including scene trees and cameras.
	void cleanup();
};

/// A struct that provides access to the 3D graphic view.
singleton class View
{
	/// the size of the view in pixels.
	readonly common Size size;
	/// the standard distance of the view from the origin.
	readonly common float standardDistance;
	/// the aspect ratio of the view.
	readonly common float aspectRatio;
	/// the distance to the near clipping plane.
	common float nearPlaneDistance;
	/// the distance to the far clipping plane.
	common float farPlaneDistance;
	/// the field of view of the view in degrees.
	common float fieldOfView;
	/// the scale factor of the view.
	common float scale;
	/// the post effect applied to the view.
	optional common SpriteEffect* postEffect;
	/// Removes the post effect applied to the view.
	outside void view_set_post_effect_nullptr @ set_post_effect_null();
	/// whether or not vertical sync is enabled.
	boolean bool vSync @ vsync;
};

value class ActionDef { };

/// Represents an action that can be run on a node.
object class Action
{
	/// the duration of the action.
	readonly common float duration;
	/// whether the action is currently running.
	readonly boolean bool running;
	/// whether the action is currently paused.
	readonly boolean bool paused;
	/// whether the action should be run in reverse.
	boolean bool reversed;
	/// the speed at which the action should be run.
	/// Set to 1.0 to get normal speed, Set to 2.0 to get two times faster.
	common float speed;
	/// Pauses the action.
	void pause();
	/// Resumes the action.
	void resume();
	/// Updates the state of the Action.
	///
	/// # Arguments
	///
	/// * `elapsed` - The amount of time in seconds that has elapsed to update action to.
	/// * `reversed` - Whether or not to update the Action in reverse.
	void updateTo(float elapsed, bool reversed);
	/// Creates a new Action object to change a property of a node.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the action.
	/// * `start` - The starting value of the property.
	/// * `stop` - The ending value of the property.
	/// * `prop` - The property to change.
	/// * `easing` - The easing function to use.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	static outside ActionDef action_def_prop @ prop(float duration, float start, float stop, Property prop, EaseType easing);
	/// Creates a new Action object to change the color of a node.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the action.
	/// * `start` - The starting color.
	/// * `stop` - The ending color.
	/// * `easing` - The easing function to use.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	static outside ActionDef action_def_tint @ tint(float duration, Color3 start, Color3 stop, EaseType easing);
	/// Creates a new Action object to rotate a node by smallest angle.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the action.
	/// * `start` - The starting angle.
	/// * `stop` - The ending angle.
	/// * `easing` - The easing function to use.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	static outside ActionDef action_def_roll @ roll(float duration, float start, float stop, EaseType easing);
	/// Creates a new Action object to run a group of actions in parallel.
	///
	/// # Arguments
	///
	/// * `defs` - The actions to run in parallel.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	static outside ActionDef action_def_spawn @ spawn(VecActionDef defs);
	/// Creates a new Action object to run a group of actions in sequence.
	///
	/// # Arguments
	///
	/// * `defs` - The actions to run in sequence.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	static outside ActionDef action_def_sequence @ sequence(VecActionDef defs);
	/// Creates a new Action object to delay the execution of following action.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the delay.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	static outside ActionDef action_def_delay @ delay(float duration);
	/// Creates a new Action object to show a node.
	static outside ActionDef action_def_show @ show();
	/// Creates a new Action object to hide a node.
	static outside ActionDef action_def_hide @ hide();
	/// Creates a new Action object to emit an event.
	///
	/// # Arguments
	///
	/// * `eventName` - The name of the event to emit.
	/// * `msg` - The message to send with the event.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	static outside ActionDef action_def_emit @ event(string eventName, string msg);
	/// Creates a new Action object to move a node.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the action.
	/// * `start` - The starting position.
	/// * `stop` - The ending position.
	/// * `easing` - The easing function to use.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	static outside ActionDef action_def_move @ move_to(float duration, Vec2 start, Vec2 stop, EaseType easing);
	/// Creates a new Action object to scale a node.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the action.
	/// * `start` - The starting scale.
	/// * `stop` - The ending scale.
	/// * `easing` - The easing function to use.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	static outside ActionDef action_def_scale @ scale(float duration, float start, float stop, EaseType easing);
};

/// A grabber which is used to render a part of the scene to a texture
/// by a grid of vertices.
object class Grabber
{
	/// the camera used to render the texture.
	optional common Camera* camera;
	/// the sprite effect applied to the texture.
	optional common SpriteEffect* effect;
	/// the blend function applied to the texture.
	common BlendFunc blendFunc;
	/// the clear color used to clear the texture.
	common Color clearColor;
	/// Sets the position of a vertex in the grabber grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-index of the vertex in the grabber grid.
	/// * `y` - The y-index of the vertex in the grabber grid.
	/// * `pos` - The new position of the vertex, represented by a Vec2 object.
	/// * `z` - An optional argument representing the new z-coordinate of the vertex.
	void setPos(int x, int y, Vec2 pos, float z);
	/// Gets the position of a vertex in the grabber grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-index of the vertex in the grabber grid.
	/// * `y` - The y-index of the vertex in the grabber grid.
	///
	/// # Returns
	///
	/// * `Vec2` - The position of the vertex.
	Vec2 getPos(int x, int y) const;
	/// Sets the color of a vertex in the grabber grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-index of the vertex in the grabber grid.
	/// * `y` - The y-index of the vertex in the grabber grid.
	/// * `color` - The new color of the vertex, represented by a Color object.
	void setColor(int x, int y, Color color);
	/// Gets the color of a vertex in the grabber grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-index of the vertex in the grabber grid.
	/// * `y` - The y-index of the vertex in the grabber grid.
	///
	/// # Returns
	///
	/// * `Color` - The color of the vertex.
	Color getColor(int x, int y) const;
	/// Sets the UV coordinates of a vertex in the grabber grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-index of the vertex in the grabber grid.
	/// * `y` - The y-index of the vertex in the grabber grid.
	/// * `offset` - The new UV coordinates of the vertex, represented by a Vec2 object.
	void moveUV @ move_uv(int x, int y, Vec2 offset);
};

/// Struct used for building a hierarchical tree structure of game objects.
interface object class Node
{
	/// the order of the node in the parent's children array.
	common int order;
	/// the rotation angle of the node in degrees.
	common float angle;
	/// the X-axis rotation angle of the node in degrees.
	common float angleX;
	/// the Y-axis rotation angle of the node in degrees.
	common float angleY;
	/// the X-axis scale factor of the node.
	common float scaleX;
	/// the Y-axis scale factor of the node.
	common float scaleY;
	/// the X-axis position of the node.
	common float x;
	/// the Y-axis position of the node.
	common float y;
	/// the Z-axis position of the node.
	common float z;
	/// the position of the node as a Vec2 object.
	common Vec2 position;
	/// the X-axis skew angle of the node in degrees.
	common float skewX;
	/// the Y-axis skew angle of the node in degrees.
	common float skewY;
	/// whether the node is visible.
	boolean bool visible;
	/// the anchor point of the node as a Vec2 object.
	common Vec2 anchor;
	/// the width of the node.
	common float width;
	/// the height of the node.
	common float height;
	/// the size of the node as a Size object.
	common Size size;
	/// the tag of the node as a string.
	common string tag;
	/// the opacity of the node, should be 0 to 1.0.
	common float opacity;
	/// the color of the node as a Color object.
	common Color color;
	/// the color of the node as a Color3 object.
	common Color3 color3;
	/// whether to pass the opacity value to child nodes.
	boolean bool passOpacity;
	/// whether to pass the color value to child nodes.
	boolean bool passColor3;
	/// the target node acts as a parent node for transforming this node.
	optional common Node* transformTarget;
	/// the scheduler used for scheduling update and action callbacks.
	common Scheduler* scheduler;
	/// the children of the node as an Array object, could be None.
	optional readonly common Array* children;
	/// the parent of the node, could be None.
	optional readonly common Node* parent;
	/// the bounding box of the node as a Rect object.
	readonly common Rect boundingBox;
	/// whether the node is currently running in a scene tree.
	readonly boolean bool running;
	/// whether the node is currently scheduling a function or a coroutine for updates.
	readonly boolean bool scheduled;
	/// the number of actions currently running on the node.
	readonly common int actionCount;
	/// additional data stored on the node as a Dictionary object.
	readonly common Dictionary* userData @ data;
	/// whether touch events are enabled on the node.
	boolean bool touchEnabled;
	/// whether the node should swallow touch events.
	boolean bool swallowTouches;
	/// whether the node should swallow mouse wheel events.
	boolean bool swallowMouseWheel;
	/// whether keyboard events are enabled on the node.
	boolean bool keyboardEnabled;
	/// whether controller events are enabled on the node.
	boolean bool controllerEnabled;
	/// whether to group the node's rendering with all its recursive children.
	boolean bool renderGroup;
	/// the rendering order number for group rendering. Nodes with lower rendering orders are rendered earlier.
	common int renderOrder;
	/// Adds a child node to the current node.
	///
	/// # Arguments
	///
	/// * `child` - The child node to add.
	/// * `order` - The drawing order of the child node.
	/// * `tag` - The tag of the child node.
	void addChild @ addChildWithOrderTag(Node* child, int order, string tag);
	/// Adds a child node to the current node.
	///
	/// # Arguments
	///
	/// * `child` - The child node to add.
	/// * `order` - The drawing order of the child node.
	void addChild @ addChildWithOrder(Node* child, int order);
	/// Adds a child node to the current node.
	///
	/// # Arguments
	///
	/// * `child` - The child node to add.
	void addChild(Node* child);
	/// Adds the current node to a parent node.
	///
	/// # Arguments
	///
	/// * `parent` - The parent node to add the current node to.
	/// * `order` - The drawing order of the current node.
	/// * `tag` - The tag of the current node.
	///
	/// # Returns
	///
	/// * `Node` - The current node.
	Node* addTo @ addToWithOrderTag(Node* parent, int order, string tag);
	/// Adds the current node to a parent node.
	///
	/// # Arguments
	///
	/// * `parent` - The parent node to add the current node to.
	/// * `order` - The drawing order of the current node.
	///
	/// # Returns
	///
	/// * `Node` - The current node.
	Node* addTo @ addToWithOrder(Node* parent, int order);
	/// Adds the current node to a parent node.
	///
	/// # Arguments
	///
	/// * `parent` - The parent node to add the current node to.
	///
	/// # Returns
	///
	/// * `Node` - The current node.
	Node* addTo(Node* parent);
	/// Removes a child node from the current node.
	///
	/// # Arguments
	///
	/// * `child` - The child node to remove.
	/// * `cleanup` - Whether to cleanup the child node.
	void removeChild(Node* child, bool cleanup);
	/// Removes a child node from the current node by tag.
	///
	/// # Arguments
	///
	/// * `tag` - The tag of the child node to remove.
	/// * `cleanup` - Whether to cleanup the child node.
	void removeChildByTag(string tag, bool cleanup);
	/// Removes all child nodes from the current node.
	///
	/// # Arguments
	///
	/// * `cleanup` - Whether to cleanup the child nodes.
	void removeAllChildren(bool cleanup);
	/// Removes the current node from its parent node.
	///
	/// # Arguments
	///
	/// * `cleanup` - Whether to cleanup the current node.
	void removeFromParent(bool cleanup);
	/// Moves the current node to a new parent node without triggering node events.
	///
	/// # Arguments
	///
	/// * `parent` - The new parent node to move the current node to.
	void moveToParent(Node* parent);
	/// Cleans up the current node.
	void cleanup();
	/// Gets a child node by tag.
	///
	/// # Arguments
	///
	/// * `tag` - The tag of the child node to get.
	///
	/// # Returns
	///
	/// * `Option<Node>` - The child node, or `None` if not found.
	optional Node* getChildByTag(string tag);
	/// Schedules a function to be called every frame.
	///
	/// # Arguments
	///
	/// * `func` - The function to be called. If the function returns `true`, it will not be called again.
	void schedule(function<bool(double deltaTime)> func);
	/// Unschedules the current node's scheduled function.
	void unschedule();
	/// Converts a point from world space to node space.
	///
	/// # Arguments
	///
	/// * `world_point` - The point in world space, represented by a Vec2 object.
	///
	/// # Returns
	///
	/// * `Vec2` - The converted point in world space.
	Vec2 convertToNodeSpace(Vec2 worldPoint);
	/// Converts a point from node space to world space.
	///
	/// # Arguments
	///
	/// * `node_point` - The point in node space, represented by a Vec2 object.
	///
	/// # Returns
	///
	/// * `Vec2` - The converted point in world space.
	Vec2 convertToWorldSpace(Vec2 nodePoint);
	/// Converts a point from node space to world space.
	///
	/// # Arguments
	///
	/// * `node_point` - The point in node space, represented by a Vec2 object.
	///
	/// # Returns
	///
	/// * `Vec2` - The converted point in world space.
	void convertToWindowSpace(Vec2 nodePoint, function<void(Vec2 result)> callback);
	/// Calls the given function for each child node of this node.
	///
	/// # Arguments
	///
	/// * `func` - The function to call for each child node. The function should return a boolean value indicating whether to continue the iteration. Return true to stop iteration.
	///
	/// # Returns
	///
	/// * `bool` - `false` if all children have been visited, `true` if the iteration was interrupted by the function.
	bool eachChild(function<bool(Node* child)> func);
	/// Traverses the node hierarchy starting from this node and calls the given function for each visited node. The nodes without `TraverseEnabled` flag are not visited.
	///
	/// # Arguments
	///
	/// * `func` - The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal. Return true to stop iteration.
	///
	/// # Returns
	///
	/// * `bool` - `false` if all nodes have been visited, `true` if the traversal was interrupted by the function.
	bool traverse(function<bool(Node* child)> func);
	/// Traverses the entire node hierarchy starting from this node and calls the given function for each visited node.
	///
	/// # Arguments
	///
	/// * `func` - The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal.
	///
	/// # Returns
	///
	/// * `bool` - `false` if all nodes have been visited, `true` if the traversal was interrupted by the function.
	bool traverseAll(function<bool(Node* child)> func);
	/// Runs an action defined by the given action definition on this node.
	///
	/// # Arguments
	///
	/// * `action_def` - The action definition to run.
	///
	/// # Returns
	///
	/// * `f64` - The duration of the newly running action in seconds.
	outside optional Action* node_run_action_def @ run_action(ActionDef def);
	/// Stops all actions running on this node.
	void stopAllActions();
	/// Runs an action defined by the given action definition right after clearing all the previous running actions.
	///
	/// # Arguments
	///
	/// * `action_def` - The action definition to run.
	///
	/// # Returns
	///
	/// * `f64` - The duration of the newly running action in seconds.
	outside optional Action* node_perform_def @ perform(ActionDef actionDef);
	/// Stops the given action running on this node.
	///
	/// # Arguments
	///
	/// * `action` - The action to stop.
	void stopAction(Action* action);
	/// Vertically aligns all child nodes within the node using the given size and padding.
	///
	/// # Arguments
	///
	/// * `padding` - The amount of padding to use between each child node.
	///
	/// # Returns
	///
	/// * `Size` - The size of the node after alignment.
	Size alignItemsVertically(float padding);
	/// Vertically aligns all child nodes within the node using the given size and padding.
	///
	/// # Arguments
	///
	/// * `size` - The size to use for alignment.
	/// * `padding` - The amount of padding to use between each child node.
	///
	/// # Returns
	///
	/// * `Size` - The size of the node after alignment.
	Size alignItemsVertically @ alignItemsVerticallyWithSize(Size size, float padding);
	/// Horizontally aligns all child nodes within the node using the given size and padding.
	///
	/// # Arguments
	///
	/// * `padding` - The amount of padding to use between each child node.
	///
	/// # Returns
	///
	/// * `Size` - The size of the node after alignment.
	Size alignItemsHorizontally(float padding);
	/// Horizontally aligns all child nodes within the node using the given size and padding.
	///
	/// # Arguments
	///
	/// * `size` - The size to hint for alignment.
	/// * `padding` - The amount of padding to use between each child node.
	///
	/// # Returns
	///
	/// * `Size` - The size of the node after alignment.
	Size alignItemsHorizontally @ alignItemsHorizontallyWithSize(Size size, float padding);
	/// Aligns all child nodes within the node using the given size and padding.
	///
	/// # Arguments
	///
	/// * `padding` - The amount of padding to use between each child node.
	///
	/// # Returns
	///
	/// * `Size` - The size of the node after alignment.
	Size alignItems(float padding);
	/// Aligns all child nodes within the node using the given size and padding.
	///
	/// # Arguments
	///
	/// * `size` - The size to use for alignment.
	/// * `padding` - The amount of padding to use between each child node.
	///
	/// # Returns
	///
	/// * `Size` - The size of the node after alignment.
	Size alignItems @ alignItemsWithSize(Size size, float padding);
	/// Moves and changes child nodes' visibility based on their position in parent's area.
	///
	/// # Arguments
	///
	/// * `delta` - The distance to move its children, represented by a Vec2 object.
	void moveAndCullItems(Vec2 delta);
	/// Attaches the input method editor (IME) to the node.
	/// Makes node recieving "AttachIME", "DetachIME", "TextInput", "TextEditing" events.
	void attachIME @ attach_ime();
	/// Detaches the input method editor (IME) from the node.
	void detachIME @ detach_ime();
	/// Creates a texture grabber for the specified node.
	///
	/// # Returns
	///
	/// * `Grabber` - A Grabber object.
	outside Grabber* node_start_grabbing @ grab();
	/// Creates a texture grabber for the specified node with a specified grid size.
	///
	/// # Arguments
	///
	/// * `grid_x` - The number of horizontal grid cells to divide the grabber into.
	/// * `grid_y` - The number of vertical grid cells to divide the grabber into.
	///
	/// # Returns
	///
	/// * `Grabber` - A Grabber object.
	Grabber* grab @ grabWithSize(uint32_t gridX, uint32_t gridY);
	/// Removes the texture grabber for the specified node.
	outside void node_stop_grabbing @ stop_grab();
	/// Removes the transform target for the specified node.
	outside void node_set_transform_target_nullptr @ set_transform_target_null();
	/// Associates the given handler function with the node event.
	///
	/// # Arguments
	///
	/// * `event_name` - The name of the node event.
	/// * `handler` - The handler function to associate with the node event.
	void slot(string eventName, function<void(Event* e)> func);
	/// Associates the given handler function with a global event.
	///
	/// # Arguments
	///
	/// * `event_name` - The name of the global event.
	/// * `handler` - The handler function to associate with the event.
	void gslot(string eventName, function<void(Event* e)> func);
	/// Creates a new instance of the `Node` struct.
	static Node* create();
};

/// A struct represents a 2D texture.
object class Texture2D
{
	/// the width of the texture, in pixels.
	readonly common int width;
	/// the height of the texture, in pixels.
	readonly common int height;
	/// Creates a texture object from the given file.
	///
	/// # Arguments
	///
	/// * `filename` - The file name of the texture.
	///
	/// # Returns
	///
	/// * `Texture2D` - The texture object.
	static outside optional Texture2D* texture_2d_create @ createFile(string filename);
};

/// A struct to render texture in game scene tree hierarchy.
object class Sprite : public INode
{
	/// whether the depth buffer should be written to when rendering the sprite.
	boolean bool depthWrite;
	/// the alpha reference value for alpha testing. Pixels with alpha values less than or equal to this value will be discarded.
	/// Only works with `sprite.effect = SpriteEffect::new("builtin:vs_sprite", "builtin:fs_spritealphatest");`.
	common float alphaRef;
	/// the texture rectangle for the sprite.
	common Rect textureRect;
	/// the texture for the sprite.
	optional readonly common Texture2D* texture;
	/// the blend function for the sprite.
	common BlendFunc blendFunc;
	/// the sprite shader effect.
	common SpriteEffect* effect;
	/// the texture wrapping mode for the U (horizontal) axis.
	common TextureWrap uWrap @ uwrap;
	/// the texture wrapping mode for the V (vertical) axis.
	common TextureWrap vWrap @ vwrap;
	/// the texture filtering mode for the sprite.
	common TextureFilter filter;
	/// Removes the sprite effect and sets the default effect.
	outside void sprite_set_effect_nullptr @ set_effect_as_default();
	/// A method for creating a Sprite object.
	///
	/// # Returns
	///
	/// * `Sprite` - A new instance of the Sprite class.
	static Sprite* create();
	/// A method for creating a Sprite object.
	///
	/// # Arguments
	///
	/// * `texture` - The texture to be used for the sprite.
	/// * `texture_rect` - An optional rectangle defining the portion of the texture to use for the sprite. If not provided, the whole texture will be used for rendering.
	///
	/// # Returns
	///
	/// * `Sprite` - A new instance of the Sprite class.
	static Sprite* create @ createTextureRect(Texture2D* texture, Rect textureRect);
	/// A method for creating a Sprite object.
	///
	/// # Arguments
	///
	/// * `texture` - The texture to be used for the sprite.
	///
	/// # Returns
	///
	/// * `Sprite` - A new instance of the Sprite class.
	static Sprite* create @ createTexture(Texture2D* texture);
	/// A method for creating a Sprite object.
	///
	/// # Arguments
	///
	/// * `clip_str` - The string containing format for loading a texture file. Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
	///
	/// # Returns
	///
	/// * `Option<Sprite>` - A new instance of the Sprite class. If the texture file is not found, it will return `None`.
	static optional Sprite* from @ createFile(string clipStr);
};

/// A struct used to render a texture as a grid of sprites, where each sprite can be positioned, colored, and have its UV coordinates manipulated.
object class Grid : public INode
{
	/// the number of columns in the grid. And there are `gridX + 1` vertices horizontally for rendering.
	readonly common uint32_t gridX;
	/// the number of rows in the grid. And there are `gridY + 1` vertices vertically for rendering.
	readonly common uint32_t gridY;
	/// whether depth writes are enabled.
	boolean bool depthWrite;
	/// the blending function used for the grid.
	common BlendFunc blendFunc;
	/// the sprite effect applied to the grid.
	/// Default is `SpriteEffect::new("builtin:vs_sprite", "builtin:fs_sprite")`.
	common SpriteEffect* effect;
	/// the rectangle within the texture that is used for the grid.
	common Rect textureRect;
	/// the texture used for the grid.
	optional common Texture2D* texture;
	/// Sets the position of a vertex in the grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the vertex in the grid.
	/// * `y` - The y-coordinate of the vertex in the grid.
	/// * `pos` - The new position of the vertex, represented by a Vec2 object.
	/// * `z` - The new z-coordinate of the vertex.
	void setPos(int x, int y, Vec2 pos, float z);
	/// Gets the position of a vertex in the grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the vertex in the grid.
	/// * `y` - The y-coordinate of the vertex in the grid.
	///
	/// # Returns
	///
	/// * `Vec2` - The current position of the vertex.
	Vec2 getPos(int x, int y) const;
	/// Sets the color of a vertex in the grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the vertex in the grid.
	/// * `y` - The y-coordinate of the vertex in the grid.
	/// * `color` - The new color of the vertex, represented by a Color object.
	void setColor(int x, int y, Color color);
	/// Gets the color of a vertex in the grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the vertex in the grid.
	/// * `y` - The y-coordinate of the vertex in the grid.
	///
	/// # Returns
	///
	/// * `Color` - The current color of the vertex.
	Color getColor(int x, int y) const;
	/// Moves the UV coordinates of a vertex in the grid.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the vertex in the grid.
	/// * `y` - The y-coordinate of the vertex in the grid.
	/// * `offset` - The offset by which to move the UV coordinates, represented by a Vec2 object.
	void moveUV @ move_uv(int x, int y, Vec2 offset);
	/// Creates a new Grid with the specified dimensions and grid size.
	///
	/// # Arguments
	///
	/// * `width` - The width of the grid.
	/// * `height` - The height of the grid.
	/// * `grid_x` - The number of columns in the grid.
	/// * `grid_y` - The number of rows in the grid.
	///
	/// # Returns
	///
	/// * `Grid` - The new Grid instance.
	static Grid* create(float width, float height, uint32_t gridX, uint32_t gridY);
	/// Creates a new Grid with the specified texture, texture rectangle, and grid size.
	///
	/// # Arguments
	///
	/// * `texture` - The texture to use for the grid.
	/// * `texture_rect` - The rectangle within the texture to use for the grid.
	/// * `grid_x` - The number of columns in the grid.
	/// * `grid_y` - The number of rows in the grid.
	///
	/// # Returns
	///
	/// * `Grid` - The new Grid instance.
	static Grid* create @ createTextureRect(Texture2D* texture, Rect textureRect, uint32_t gridX, uint32_t gridY);
	/// Creates a new Grid with the specified texture, texture rectangle, and grid size.
	///
	/// # Arguments
	///
	/// * `texture` - The texture to use for the grid.
	/// * `grid_x` - The number of columns in the grid.
	/// * `grid_y` - The number of rows in the grid.
	///
	/// # Returns
	///
	/// * `Grid` - The new Grid instance.
	static Grid* create @ createTexture(Texture2D* texture, uint32_t gridX, uint32_t gridY);
	/// Creates a new Grid with the specified clip string and grid size.
	///
	/// # Arguments
	///
	/// * `clip_str` - The clip string to use for the grid. Can be "Image/file.png" and "Image/items.clip|itemA".
	/// * `grid_x` - The number of columns in the grid.
	/// * `grid_y` - The number of rows in the grid.
	///
	/// # Returns
	///
	/// * `Grid` - The new Grid instance.
	static optional Grid* from @ createFile(string clipStr, uint32_t gridX, uint32_t gridY);
};

/// Represents a touch input or mouse click event.
object class Touch
{
	/// whether touch input is enabled or not.
	boolean bool enabled;
	/// whether the touch event originated from a mouse click.
	readonly boolean bool mouse @ fromMouse;
	/// whether this is the first touch event when multi-touches exist.
	readonly boolean bool first;
	/// the unique identifier assigned to this touch event.
	readonly common int id;
	/// the amount and direction of movement since the last touch event.
	readonly common Vec2 delta;
	/// the location of the touch event in the node's local coordinate system.
	readonly common Vec2 location;
	/// the location of the touch event in world coordinate system.
	readonly common Vec2 worldLocation;
};

/// A struct that defines a set of easing functions for use in animations.
singleton struct Ease
{
	/// Applies an easing function to a given value over a given amount of time.
	///
	/// # Arguments
	///
	/// * `easing` - The easing function to apply.
	/// * `time` - The amount of time to apply the easing function over, should be between 0 and 1.
	///
	/// # Returns
	///
	/// * `f32` - The result of applying the easing function to the value.
	static float func(EaseType easing, float time);
};

/// A node for rendering text using a TrueType font.
object class Label : public INode
{
	/// the text alignment setting.
	common TextAlign alignment;
	/// the alpha threshold value. Pixels with alpha values below this value will not be drawn.
	/// Only works with `label.effect = SpriteEffect::new("builtin:vs_sprite", "builtin:fs_spritealphatest")`.
	common float alphaRef;
	/// the width of the text used for text wrapping.
	/// Set to `Label::AutomaticWidth` to disable wrapping.
	/// Default is `Label::AutomaticWidth`.
	common float textWidth;
	/// the gap in pixels between characters.
	common float spacing;
	/// the gap in pixels between lines of text.
	common float lineGap;
	/// the text to be rendered.
	common string text;
	/// the blend function used to render the text.
	common BlendFunc blendFunc;
	/// whether depth writing is enabled. (Default is false)
	boolean bool depthWrite;
	/// whether the label is using batched rendering.
	/// When using batched rendering the `label.get_character()` function will no longer work, but it provides better rendering performance. Default is true.
	boolean bool batched;
	/// the sprite effect used to render the text.
	common SpriteEffect* effect;
	/// the number of characters in the label.
	readonly common int characterCount;
	/// Returns the sprite for the character at the specified index.
	///
	/// # Arguments
	///
	/// * `index` - The index of the character sprite to retrieve.
	///
	/// # Returns
	///
	/// * `Option<Sprite>` - The sprite for the character, or `None` if the index is out of range.
	optional Sprite* getCharacter(int index);
	/// the value to use for automatic width calculation
	static readonly float AutomaticWidth @ automaticWidth;
	/// Creates a new Label object with the specified font name and font size.
	///
	/// # Arguments
	///
	/// * `font_name` - The name of the font to use for the label. Can be font file path with or without file extension.
	/// * `font_size` - The size of the font to use for the label.
	///
	/// # Returns
	///
	/// * `Label` - The new Label object.
	static Label* create(string fontName, uint32_t fontSize);
};

/// A RenderTarget is a buffer that allows you to render a Node into a texture.
object class RenderTarget
{
	/// the width of the rendering target.
	readonly common uint16_t width;
	/// the height of the rendering target.
	readonly common uint16_t height;
	/// the camera used for rendering the scene.
	optional common Camera* camera;
	/// the texture generated by the rendering target.
	readonly common Texture2D* texture;
	/// Renders a node to the target without replacing its previous contents.
	///
	/// # Arguments
	///
	/// * `target` - The node to be rendered onto the render target.
	void render(Node* target);
	/// Clears the previous color, depth and stencil values on the render target.
	///
	/// # Arguments
	///
	/// * `color` - The clear color used to clear the render target.
	/// * `depth` - Optional. The value used to clear the depth buffer of the render target. Default is 1.
	/// * `stencil` - Optional. The value used to clear the stencil buffer of the render target. Default is 0.
	void renderWithClear @ renderClear(Color color, float depth, uint8_t stencil);
	/// Renders a node to the target after clearing the previous color, depth and stencil values on it.
	///
	/// # Arguments
	///
	/// * `target` - The node to be rendered onto the render target.
	/// * `color` - The clear color used to clear the render target.
	/// * `depth` - The value used to clear the depth buffer of the render target. Default can be 1.
	/// * `stencil` - The value used to clear the stencil buffer of the render target. Default can be 0.
	void renderWithClear @ renderClearWithTarget(Node* target, Color color, float depth, uint8_t stencil);
	/// Saves the contents of the render target to a PNG file asynchronously.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to save the contents to.
	void saveAsync(string filename, function<void(bool success)> handler);
	static RenderTarget* create(uint16_t width, uint16_t height);
};

/// A Node that can clip its children based on the alpha values of its stencil.
object class ClipNode : public INode
{
	/// the stencil Node that defines the clipping shape.
	common Node* stencil;
	/// the minimum alpha threshold for a pixel to be visible. Value ranges from 0 to 1.
	common float alphaThreshold;
	/// whether to invert the clipping area.
	boolean bool inverted;
	/// Creates a new ClipNode object.
	///
	/// # Arguments
	///
	/// * `stencil` - The stencil Node that defines the clipping shape. Defaults to `None`.
	///
	/// # Returns
	///
	/// * A new `ClipNode` object.
	static ClipNode* create(Node* stencil);
};

value struct VertexColor
{
	Vec2 vertex;
	Color color;
	static VertexColor create(Vec2 vec, Color color);
};

/// A scene node that draws simple shapes such as dots, lines, and polygons.
object class DrawNode : public INode
{
	/// whether to write to the depth buffer when drawing (default is false).
	boolean bool depthWrite;
	/// the blend function used to draw the shape.
	common BlendFunc blendFunc;
	/// Draws a dot at a specified position with a specified radius and color.
	///
	/// # Arguments
	///
	/// * `pos` - The position of the dot.
	/// * `radius` - The radius of the dot.
	/// * `color` - The color of the dot.
	void drawDot(Vec2 pos, float radius, Color color);
	/// Draws a line segment between two points with a specified radius and color.
	///
	/// # Arguments
	///
	/// * `from` - The starting point of the line.
	/// * `to` - The ending point of the line.
	/// * `radius` - The radius of the line.
	/// * `color` - The color of the line.
	void drawSegment(Vec2 from, Vec2 to, float radius, Color color);
	/// Draws a polygon defined by a list of vertices with a specified fill color and border.
	///
	/// # Arguments
	///
	/// * `verts` - The vertices of the polygon.
	/// * `fill_color` - The fill color of the polygon.
	/// * `border_width` - The width of the border.
	/// * `border_color` - The color of the border.
	void drawPolygon(VecVec2 verts, Color fillColor, float borderWidth, Color borderColor);
	/// Draws a set of vertices as triangles, each vertex with its own color.
	///
	/// # Arguments
	///
	/// * `verts` - The list of vertices and their colors. Each element is a tuple where the first element is a `Vec2` and the second element is a `Color`.
	void drawVertices(VecVertexColor verts);
	/// Clears all previously drawn shapes from the node.
	void clear();
	/// Creates a new DrawNode object.
	///
	/// # Returns
	///
	/// * A new `DrawNode` object.
	static DrawNode* create();
};

/// A struct provides functionality for drawing lines using vertices.
object class Line : public INode
{
	/// whether the depth should be written. (Default is false)
	boolean bool depthWrite;
	/// blend function used for rendering the line.
	common BlendFunc blendFunc;
	/// Adds vertices to the line.
	///
	/// # Arguments
	///
	/// * `verts` - A vector of vertices to add to the line.
	/// * `color` - Optional. The color of the line.
	void add(VecVec2 verts, Color color);
	/// Sets vertices of the line.
	///
	/// # Arguments
	///
	/// * `verts` - A vector of vertices to set.
	/// * `color` - Optional. The color of the line.
	void set(VecVec2 verts, Color color);
	/// Clears all the vertices of line.
	void clear();
	/// Creates and returns a new empty Line object.
	///
	/// # Returns
	///
	/// * A new `Line` object.
	static Line* create();
	/// Creates and returns a new Line object.
	///
	/// # Arguments
	///
	/// * `verts` - A vector of vertices to add to the line.
	/// * `color` - The color of the line.
	///
	/// # Returns
	///
	/// * A new `Line` object.
	static Line* create @ createVecColor(VecVec2 verts, Color color);
};

/// Represents a particle system node that emits and animates particles.
object class ParticleNode @ Particle : public INode
{
	/// whether the particle system is active.
	readonly boolean bool active;
	/// Starts emitting particles.
	void start();
	/// Stops emitting particles and wait for all active particles to end their lives.
	void stop();
	/// Creates a new Particle object from a particle system file.
	///
	/// # Arguments
	///
	/// * `filename` - The file path of the particle system file.
	///
	/// # Returns
	///
	/// * A new `Particle` object.
	static optional ParticleNode* create(string filename);
};

/// An interface for an animation model system.
interface object class Playable : public INode
{
	/// the look of the animation.
	common string look;
	/// the play speed of the animation.
	common float speed;
	/// the recovery time of the animation, in seconds.
	/// Used for doing transitions from one animation to another animation.
	common float recovery;
	/// whether the animation is flipped horizontally.
	boolean bool fliped;
	/// the current playing animation name.
	readonly common string current;
	/// the last completed animation name.
	readonly common string lastCompleted;
	/// Gets a key point on the animation model by its name.
	///
	/// # Arguments
	///
	/// * `name` - The name of the key point to get.
	///
	/// # Returns
	///
	/// * A `Vec2` representing the key point value.
	Vec2 getKeyPoint @ getKey(string name);
	/// Plays an animation from the model.
	///
	/// # Arguments
	///
	/// * `name` - The name of the animation to play.
	/// * `loop` - Whether to loop the animation or not.
	///
	/// # Returns
	///
	/// * The duration of the animation in seconds.
	float play(string name, bool looping);
	/// Stops the currently playing animation.
	void stop();
	/// Attaches a child node to a slot on the animation model.
	///
	/// # Arguments
	///
	/// * `name` - The name of the slot to set.
	/// * `item` - The node to set the slot to.
	void setSlot(string name, Node* item);
	/// Gets the child node attached to the animation model.
	///
	/// # Arguments
	///
	/// * `name` - The name of the slot to get.
	///
	/// # Returns
	///
	/// * The node in the slot, or `None` if there is no node in the slot.
	optional Node* getSlot(string name);
	/// Creates a new instance of 'Playable' from the specified animation file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the animation file to load. Supports DragonBone, Spine2D and Dora Model files.
	/// Should be one of the formats below:
	///     * "model:" + modelFile
	///     * "spine:" + spineStr
	///     * "bone:" + dragonBoneStr
	///
	/// # Returns
	///
	/// * A new instance of 'Playable'. If the file could not be loaded, then `None` is returned.
	static optional Playable* create(string filename);
};

/// Another implementation of the 'Playable' animation interface.
object class Model : public IPlayable
{
	/// the duration of the current animation.
	readonly common float duration;
	/// whether the animation model will be played in reverse.
	boolean bool reversed;
	/// whether the animation model is currently playing.
	readonly boolean bool playing;
	/// whether the animation model is currently paused.
	readonly boolean bool paused;
	/// Checks if an animation exists in the model.
	///
	/// # Arguments
	///
	/// * `name` - The name of the animation to check.
	///
	/// # Returns
	///
	/// * `bool` - Whether the animation exists in the model or not.
	bool hasAnimation(string name);
	/// Pauses the currently playing animation.
	void pause();
	/// Resumes the currently paused animation,
	void resume();
	/// Resumes the currently paused animation, or plays a new animation if specified.
	///
	/// # Arguments
	///
	/// * `name` - The name of the animation to play.
	/// * `loop` - Whether to loop the animation or not.
	void resume @ resumeAnimation(string name, bool looping);
	/// Resets the current animation to its initial state.
	void reset();
	/// Updates the animation to the specified time, and optionally in reverse.
	///
	/// # Arguments
	///
	/// * `elapsed` - The time to update to.
	/// * `reversed` - Whether to play the animation in reverse.
	void updateTo(float elapsed, bool reversed);
	/// Gets the node with the specified name.
	///
	/// # Arguments
	///
	/// * `name` - The name of the node to get.
	///
	/// # Returns
	///
	/// * The node with the specified name.
	Node* getNodeByName(string name);
	/// Calls the specified function for each node in the model, and stops if the function returns `false`.
	///
	/// # Arguments
	///
	/// * `func` - The function to call for each node.
	///
	/// # Returns
	///
	/// * `bool` - Whether the function was called for all nodes or not.
	bool eachNode(function<bool(Node* node)> func);
	/// Creates a new instance of 'Model' from the specified model file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the model file to load. Can be filename with or without extension like: "Model/item" or "Model/item.model".
	///
	/// # Returns
	///
	/// * A new instance of 'Model'.
	static Model* create(string filename);
	/// Returns a new dummy instance of 'Model' that can do nothing.
	///
	/// # Returns
	///
	/// * A new dummy instance of 'Model'.
	static Model* dummy();
	/// Gets the clip file from the specified model file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the model file to search.
	///
	/// # Returns
	///
	/// * A `String` representing the name of the clip file.
	static outside string model_get_clip_filename @ getClipFile(string filename);
	/// Gets an array of look names from the specified model file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the model file to search.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing an array of look names found in the model file.
	static outside VecStr model_get_look_names @ getLooks(string filename);
	/// Gets an array of animation names from the specified model file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the model file to search.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing an array of animation names found in the model file.
	static outside VecStr model_get_animation_names @ getAnimations(string filename);
};

/// An implementation of an animation system using the Spine engine.
object class Spine : public IPlayable
{
	/// whether to show debug graphics.
	boolean bool showDebug;
	/// whether hit testing is enabled.
	boolean bool hitTestEnabled;
	/// Sets the rotation of a bone in the Spine skeleton.
	///
	/// # Arguments
	///
	/// * `name` - The name of the bone to rotate.
	/// * `rotation` - The amount to rotate the bone, in degrees.
	///
	/// # Returns
	///
	/// * `bool` - Whether the rotation was successfully set or not.
	bool setBoneRotation(string name, float rotation);
	/// Checks if a point in space is inside the boundaries of the Spine skeleton.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the point to check.
	/// * `y` - The y-coordinate of the point to check.
	///
	/// # Returns
	///
	/// * `Option<String>` - The name of the bone at the point, or `None` if there is no bone at the point.
	string containsPoint(float x, float y);
	/// Checks if a line segment intersects the boundaries of the instance and returns the name of the bone or slot at the intersection point, or `None` if no bone or slot is found.
	///
	/// # Arguments
	///
	/// * `x1` - The x-coordinate of the start point of the line segment.
	/// * `y1` - The y-coordinate of the start point of the line segment.
	/// * `x2` - The x-coordinate of the end point of the line segment.
	/// * `y2` - The y-coordinate of the end point of the line segment.
	///
	/// # Returns
	///
	/// * `Option<String>` - The name of the bone or slot at the intersection point, or `None` if no bone or slot is found.
	string intersectsSegment(float x1, float y1, float x2, float y2);
	/// Creates a new instance of 'Spine' using the specified skeleton file and atlas file.
	///
	/// # Arguments
	///
	/// * `skel_file` - The filename of the skeleton file to load.
	/// * `atlas_file` - The filename of the atlas file to load.
	///
	/// # Returns
	///
	/// * A new instance of 'Spine' with the specified skeleton file and atlas file. Returns `None` if the skeleton file or atlas file could not be loaded.
	static Spine* create @ createFiles(string skelFile, string atlasFile);
	/// Creates a new instance of 'Spine' using the specified Spine string.
	///
	/// # Arguments
	///
	/// * `spine_str` - The Spine file string for the new instance. A Spine file string can be a file path with the target file extension like "Spine/item" or file paths with all the related files like "Spine/item.skel|Spine/item.atlas" or "Spine/item.json|Spine/item.atlas".
	///
	/// # Returns
	///
	/// * A new instance of 'Spine'. Returns `None` if the Spine file could not be loaded.
	static Spine* create(string spineStr);
	/// Returns a list of available looks for the specified Spine2D file string.
	///
	/// # Arguments
	///
	/// * `spine_str` - The Spine2D file string to get the looks for.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing the available looks.
	static outside VecStr spine_get_look_names @ getLooks(string spineStr);
	/// Returns a list of available animations for the specified Spine2D file string.
	///
	/// # Arguments
	///
	/// * `spine_str` - The Spine2D file string to get the animations for.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing the available animations.
	static outside VecStr spine_get_animation_names @ getAnimations(string spineStr);
};

/// An implementation of the 'Playable' record using the DragonBones animation system.
object class DragonBone : public IPlayable
{
	/// whether to show debug graphics.
	boolean bool showDebug;
	/// whether hit testing is enabled.
	boolean bool hitTestEnabled;
	/// Checks if a point is inside the boundaries of the instance and returns the name of the bone or slot at that point, or `None` if no bone or slot is found.
	///
	/// # Arguments
	///
	/// * `x` - The x-coordinate of the point to check.
	/// * `y` - The y-coordinate of the point to check.
	///
	/// # Returns
	///
	/// * `String` - The name of the bone or slot at the point.
	string containsPoint(float x, float y);
	/// Checks if a line segment intersects the boundaries of the instance and returns the name of the bone or slot at the intersection point, or `None` if no bone or slot is found.
	///
	/// # Arguments
	///
	/// * `x1` - The x-coordinate of the start point of the line segment.
	/// * `y1` - The y-coordinate of the start point of the line segment.
	/// * `x2` - The x-coordinate of the end point of the line segment.
	/// * `y2` - The y-coordinate of the end point of the line segment.
	///
	/// # Returns
	///
	/// * `String` - The name of the bone or slot at the intersection point.
	string intersectsSegment(float x1, float y1, float x2, float y2);
	/// Creates a new instance of 'DragonBone' using the specified bone file and atlas file. This function only loads the first armature.
	///
	/// # Arguments
	///
	/// * `bone_file` - The filename of the bone file to load.
	/// * `atlas_file` - The filename of the atlas file to load.
	///
	/// # Returns
	///
	/// * A new instance of 'DragonBone' with the specified bone file and atlas file. Returns `None` if the bone file or atlas file is not found.
	static DragonBone* create @ createFiles(string boneFile, string atlasFile);
	/// Creates a new instance of 'DragonBone' using the specified bone string.
	///
	/// # Arguments
	///
	/// * `bone_str` - The DragonBone file string for the new instance. A DragonBone file string can be a file path with the target file extension like "DragonBone/item" or file paths with all the related files like "DragonBone/item_ske.json|DragonBone/item_tex.json". An armature name can be added following a separator of ';'. like "DragonBone/item;mainArmature" or "DragonBone/item_ske.json|DragonBone/item_tex.json;mainArmature".
	///
	/// # Returns
	///
	/// * A new instance of 'DragonBone'. Returns `None` if the bone file or atlas file is not found.
	static DragonBone* create(string boneStr);
	/// Returns a list of available looks for the specified DragonBone file string.
	///
	/// # Arguments
	///
	/// * `bone_str` - The DragonBone file string to get the looks for.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing the available looks.
	static outside VecStr dragon_bone_get_look_names @ getLooks(string boneStr);
	/// Returns a list of available animations for the specified DragonBone file string.
	///
	/// # Arguments
	///
	/// * `bone_str` - The DragonBone file string to get the animations for.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing the available animations.
	static outside VecStr dragon_bone_get_animation_names @ getAnimations(string boneStr);
};

interface object class PhysicsWorld : public INode
{
	boolean bool showDebug;
	bool query(Rect rect, function<bool(Body* body)> handler);
	bool raycast(Vec2 start, Vec2 stop, bool closest, function<bool(Body* body, Vec2 point, Vec2 normal)> handler);
	void setIterations(int velocityIter, int positionIter);
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	bool getShouldContact(uint8_t groupA, uint8_t groupB);
	static float scaleFactor;
	static PhysicsWorld* create();
};

object class FixtureDef { };

object class BodyDef
{
	Vec2 offset @ position;
	float angleOffset @ angle;
	string face;
	Vec2 facePos;
	common float linearDamping;
	common float angularDamping;
	common Vec2 linearAcceleration;
	boolean bool fixedRotation;
	boolean bool bullet;
	static FixtureDef* polygon @ polygonWithCenter(
		Vec2 center,
		float width,
		float height,
		float angle,
		float density,
		float friction,
		float restitution);
	static FixtureDef* polygon(
		float width,
		float height,
		float density,
		float friction,
		float restitution);
	static FixtureDef* polygon @ polygonWithVertices(
		VecVec2 vertices,
		float density,
		float friction,
		float restitution);
	void attachPolygon @ attachPolygonCenter(
		Vec2 center,
		float width,
		float height,
		float angle,
		float density,
		float friction,
		float restitution);
	void attachPolygon(
		float width,
		float height,
		float density,
		float friction,
		float restitution);
	void attachPolygon @ attachPolygonWithVertices(
		VecVec2 vertices,
		float density,
		float friction,
		float restitution);
	static FixtureDef* multi(
		VecVec2 vertices,
		float density,
		float friction,
		float restitution);
	void attachMulti(
		VecVec2 vertices,
		float density,
		float friction,
		float restitution);
	static FixtureDef* disk @ diskWithCenter(
		Vec2 center,
		float radius,
		float density,
		float friction,
		float restitution);
	static FixtureDef* disk(
		float radius,
		float density,
		float friction,
		float restitution);
	void attachDisk @ attachDiskWithCenter(
		Vec2 center,
		float radius,
		float density,
		float friction,
		float restitution);
	void attachDisk(
		float radius,
		float density,
		float friction,
		float restitution);
	static FixtureDef* chain(
		VecVec2 vertices,
		float friction,
		float restitution);
	void attachChain(
		VecVec2 vertices,
		float friction,
		float restitution);
	void attachPolygonSensor(
		int tag,
		float width,
		float height);
	void attachPolygonSensor @ attachPolygonSensorWithCenter(
		int tag,
		Vec2 center,
		float width,
		float height,
		float angle);
	void attachPolygonSensor @ attachPolygonSensorWithVertices(
		int tag,
		VecVec2 vertices);
	void attachDiskSensor @ attachDiskSensorWithCenter(
		int tag,
		Vec2 center,
		float radius);
	void attachDiskSensor(
		int tag,
		float radius);
	static BodyDef* create();
};

object class Sensor
{
	boolean bool enabled;
	readonly common int tag;
	readonly common Body* owner;
	readonly boolean bool sensed;
	readonly common Array* sensedBodies;
	bool contains(Body* body);
};

interface object class Body : public INode
{
	readonly common PhysicsWorld* physicsWorld @ world;
	readonly common BodyDef* bodyDef;
	readonly common float mass;
	readonly boolean bool sensor;
	common float velocityX;
	common float velocityY;
	common Vec2 velocity;
	common float angularRate;
	common uint8_t group;
	common float linearDamping;
	common float angularDamping;
	common Object* owner;
	boolean bool receivingContact;
	void applyLinearImpulse(Vec2 impulse, Vec2 pos);
	void applyAngularImpulse(float impulse);
	Sensor* getSensorByTag(int tag);
	bool removeSensorByTag(int tag);
	bool removeSensor(Sensor* sensor);
	void attach(FixtureDef* fixtureDef);
	Sensor* attachSensor(int tag, FixtureDef* fixtureDef);
	void onContactFilter(function<bool(Body* body)> filter);
	static Body* create(BodyDef* def, PhysicsWorld* world, Vec2 pos, float rot);
};

object class JointDef
{
	Vec2 center;
	Vec2 position;
	float angle;
	static JointDef* distance(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float frequency,
		float damping);
	static JointDef* friction(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float maxForce,
		float maxTorque);
	static JointDef* gear(
		bool collision,
		string jointA,
		string jointB,
		float ratio);
	static JointDef* spring(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor);
	static JointDef* prismatic(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float axisAngle,
		float lowerTranslation,
		float upperTranslation,
		float maxMotorForce,
		float motorSpeed);
	static JointDef* pulley(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		Vec2 groundAnchorA,
		Vec2 groundAnchorB,
		float ratio);
	static JointDef* revolute(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float lowerAngle,
		float upperAngle,
		float maxMotorTorque,
		float motorSpeed);
	static JointDef* rope(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float maxLength);
	static JointDef* weld(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float frequency,
		float damping);
	static JointDef* wheel(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float axisAngle,
		float maxMotorTorque,
		float motorSpeed,
		float frequency,
		float damping);
};

interface object class Joint
{
	static Joint* distance(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float frequency,
		float damping);
	static Joint* friction(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float maxForce,
		float maxTorque);
	static Joint* gear(
		bool collision,
		Joint* jointA,
		Joint* jointB,
		float ratio);
	static Joint* spring(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor);
	static MoveJoint* move @ moveTarget(
		bool collision,
		Body* body,
		Vec2 targetPos,
		float maxForce,
		float frequency,
		float damping);
	static MotorJoint* prismatic(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float axisAngle,
		float lowerTranslation,
		float upperTranslation,
		float maxMotorForce,
		float motorSpeed);
	static Joint* pulley(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		Vec2 groundAnchorA,
		Vec2 groundAnchorB,
		float ratio);
	static MotorJoint* revolute(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float lowerAngle,
		float upperAngle,
		float maxMotorTorque,
		float motorSpeed);
	static Joint* rope(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float maxLength);
	static Joint* weld(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float frequency,
		float damping);
	static MotorJoint* wheel(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float axisAngle,
		float maxMotorTorque,
		float motorSpeed,
		float frequency,
		float damping);
	readonly common PhysicsWorld* physicsWorld @ world;
	void destroy();
	static Joint* create(JointDef* def, Dictionary* itemDict);
};

object class MoveJoint : public IJoint
{
	common Vec2 position;
};

object class MotorJoint : public IJoint
{
	boolean bool enabled;
	common float force;
	common float speed;
};

singleton struct Cache
{
	static bool load(string filename);
	static void loadAsync(string filename, function<void()> callback);
	static void update @ updateItem(string filename, string content);
	static void update @ updateTexture(string filename, Texture2D* texture);
	static void unload();
	static bool unload @ unloadItemOrType(string name);
	static void removeUnused();
	static void removeUnused @ removeUnusedByType(string typeName);
};

singleton class Audio
{
	uint32_t play(string filename, bool looping);
	void stop(uint32_t handle);
	void playStream(string filename, bool looping, float crossFadeTime);
	void stopStream(float fadeTime);
};

singleton class Keyboard
{
	bool isKeyDown(string name);
	bool isKeyUp(string name);
	bool isKeyPressed(string name);
	void updateIMEPosHint(Vec2 winPos);
};

singleton class Controller
{
	bool isButtonDown(int controllerId, string name);
	bool isButtonUp(int controllerId, string name);
	bool isButtonPressed(int controllerId, string name);
	float getAxis(int controllerId, string name);
};

object class SVGDef @ SVG
{
	readonly common float width;
	readonly common float height;
	void render();
	static optional SVGDef* from @ create(string filename);
};

value struct DBParams
{
	void add(Array* params);
};

value struct DBRecord
{
	bool read(Array* record);
};

value struct DBQuery
{
	void addWithParams(string sql, DBParams params);
	void add(string sql);
};

singleton class DB
{
	bool exist(string tableName);
	bool exist @ existSchema(string tableName, string schema);
	int exec(string sql);
	outside bool db_do_transaction @ transaction(DBQuery query);
	outside void db_do_transaction_async @ transactionAsync(DBQuery query, function<void(bool result)> callback);
	outside DBRecord db_do_query @ query(string sql, bool withColumns);
	outside DBRecord db_do_query_with_params @ queryWithParams(string sql, Array* param, bool withColumns);
	outside void db_do_insert @ insert(string tableName, DBParams params);
	outside int32_t db_do_exec_with_records @ execWithRecords(string sql, DBParams params);
	outside void db_do_query_with_params_async @ queryWithParamsAsync(string sql, Array* param, bool withColumns, function<void(DBRecord result)> callback);
	outside void db_do_insert_async @ insertAsync(string tableName, DBParams params, function<void(bool result)> callback);
	outside void db_do_exec_async @ execAsync(string sql, DBParams params, function<void(int64_t rowChanges)> callback);
};

object class MLQLearner @ QLearner
{
	void update(MLQState state, MLQAction action, double reward);
	uint32_t getBestAction(MLQState state);
	outside void ml_qlearner_visit_state_action_q @ visitMatrix(function<void(MLQState state, MLQAction action, double q)> handler);
	static MLQState pack(VecUint32 hints, VecUint32 values);
	static VecUint32 unpack(VecUint32 hints, MLQState state);
	static QLearner* create(double gamma, double alpha, double maxQ);
};

singleton class C45
{
	static outside void MLBuildDecisionTreeAsync @ buildDecisionTreeAsync(string data, int maxDepth, function<void(double depth, string name, string op, string value)> treeVisitor);
};

namespace Platformer {

value class TargetAllow
{
	boolean bool terrainAllowed;
	void allow(Platformer::Relation relation, bool allow);
	bool isAllow(Platformer::Relation relation);
	uint32_t toValue();
	static Platformer::TargetAllow create();
	static Platformer::TargetAllow create @ createValue(uint32_t value);
};

object class Face
{
	void addChild(Platformer::Face* face);
	Node* toNode();
	static Face* create(string faceStr, Vec2 point, float scale, float angle);
	static Face* create @ createFunc(function<Node*()> createFunc, Vec2 point, float scale, float angle);
};

object class BulletDef
{
	string tag;
	string endEffect;
	float lifeTime;
	float damageRadius;
	boolean bool highSpeedFix;
	common Vec2 gravity;
	common Platformer::Face* face;
	readonly common BodyDef* bodyDef;
	readonly common Vec2 velocity;
	void setAsCircle(float radius);
	void setVelocity(float angle, float speed);
	static BulletDef* create();
};

object class Bullet : public IBody
{
	common uint32_t targetAllow;
	readonly boolean bool faceRight;
	boolean bool hitStop;
	readonly common Platformer::Unit* emitter;
	readonly common Platformer::BulletDef* bulletDef;
	common Node* face;
	void destroy();
	static Bullet* create(Platformer::BulletDef* def, Platformer::Unit* owner);
};

object class Visual : public INode
{
	readonly boolean bool playing;
	void start();
	void stop();
	Platformer::Visual* autoRemove();
	static Visual* create(string name);
};

namespace Behavior {

class Blackboard
{
	readonly common double deltaTime;
	readonly common Platformer::Unit* owner;
};

object class Leaf @ Tree
{
	static outside Platformer::Behavior::Leaf* BSeq @ seq(VecBTree nodes);
	static outside Platformer::Behavior::Leaf* BSel @ sel(VecBTree nodes);
	static outside Platformer::Behavior::Leaf* BCon @ con(string name, function<bool(Platformer::Behavior::Blackboard blackboard)> handler);
	static outside Platformer::Behavior::Leaf* BAct @ act(string action);
	static outside Platformer::Behavior::Leaf* BCommand @ command(string action);
	static outside Platformer::Behavior::Leaf* BWait @ wait(double duration);
	static outside Platformer::Behavior::Leaf* BCountdown @ countdown(double time, Platformer::Behavior::Leaf* node);
	static outside Platformer::Behavior::Leaf* BTimeout @ timeout(double time, Platformer::Behavior::Leaf* node);
	static outside Platformer::Behavior::Leaf* BRepeat @ repeat(int times, Platformer::Behavior::Leaf* node);
	static outside Platformer::Behavior::Leaf* BRepeat @ repeatForever(Platformer::Behavior::Leaf* node);
	static outside Platformer::Behavior::Leaf* BRetry @ retry(int times, Platformer::Behavior::Leaf* node);
	static outside Platformer::Behavior::Leaf* BRetry @ retryUntilPass(Platformer::Behavior::Leaf* node);
};

}

namespace Decision {

object class Leaf @ Tree
{
	static outside Platformer::Decision::Leaf* DSel @ sel(VecDTree nodes);
	static outside Platformer::Decision::Leaf* DSeq @ seq(VecDTree nodes);
	static outside Platformer::Decision::Leaf* DCon @ con(string name, function<bool(Platformer::Unit* unit)> handler);
	static outside Platformer::Decision::Leaf* DAct @ act(string action);
	static outside Platformer::Decision::Leaf* DAct @ actDynamic(function<string(Platformer::Unit* unit)> handler);
	static outside Platformer::Decision::Leaf* DAccept @ accept();
	static outside Platformer::Decision::Leaf* DReject @ reject();
	static outside Platformer::Decision::Leaf* DBehave @ behave(string name, Platformer::Behavior::Leaf* root);
};

singleton class AI
{
	Array* getUnitsByRelation(Platformer::Relation relation);
	Array* getDetectedUnits();
	Array* getDetectedBodies();
	Platformer::Unit* getNearestUnit(Platformer::Relation relation);
	float getNearestUnitDistance(Platformer::Relation relation);
	Array* getUnitsInAttackRange();
	Array* getBodiesInAttackRange();
};

}

value class WasmActionUpdate @ ActionUpdate
{
	static WasmActionUpdate create(function<bool(Platformer::Unit* owner, Platformer::UnitAction action, float deltaTime)> update);
};

class UnitAction
{
	float reaction;
	float recovery;
	readonly common string name;
	readonly boolean bool doing;
	readonly common Platformer::Unit* owner;
	readonly common float elapsedTime;
	static void clear();
	static outside void platformer_wasm_unit_action_add @ add(
		string name, int priority, float reaction, float recovery, bool queued,
		function<bool(Platformer::Unit* owner, Platformer::UnitAction action)> available,
		function<Platformer::WasmActionUpdate(Platformer::Unit* owner, Platformer::UnitAction action)> create,
		function<void(Platformer::Unit* owner, Platformer::UnitAction action)> stop);
};

object class Unit : public IBody
{
	common Playable* playable;
	common float detectDistance;
	common Size attackRange;
	boolean bool faceRight;
	boolean bool receivingDecisionTrace;
	common string decisionTreeName @ decisionTree;
	readonly boolean bool onSurface;
	readonly common Sensor* groundSensor;
	readonly common Sensor* detectSensor;
	readonly common Sensor* attackSensor;
	readonly common Dictionary* unitDef;
	readonly common Platformer::UnitAction currentAction;
	readonly common float width;
	readonly common float height;
	readonly common Entity* entity;
	Platformer::UnitAction attachAction(string name);
	void removeAction(string name);
	void removeAllActions();
	optional Platformer::UnitAction getAction(string name);
	void eachAction(function<void(Platformer::UnitAction action)> func);
	bool start(string name);
	void stop();
	bool isDoing(string name);
	static Unit* create(Dictionary* unitDef, PhysicsWorld* physicsworld, Entity* entity, Vec2 pos, float rot);
	static Unit* create @ createStore(string defName, string worldName, Entity* entity, Vec2 pos, float rot);
};

object class PlatformCamera : public ICamera
{
	common Vec2 position;
	common float rotation;
	common float zoom;
	common Rect boundary;
	common Vec2 followRatio;
	common Vec2 followOffset;
	optional common Node* followTarget;
	outside void platform_camera_set_follow_target_nullptr @ set_follow_target_null();
	static PlatformCamera* create(string name);
};

object class PlatformWorld : public IPhysicsWorld
{
	readonly common Platformer::PlatformCamera* camera;
	void moveChild(Node* child, int newOrder);
	Node* getLayer(int order);
	void setLayerRatio(int order, Vec2 ratio);
	Vec2 getLayerRatio(int order);
	void setLayerOffset(int order, Vec2 offset);
	Vec2 getLayerOffset(int order);
	void swapLayer(int orderA, int orderB);
	void removeLayer(int order);
	void removeAllLayers();
	static PlatformWorld* create();
};

singleton class Data
{
	readonly common uint8_t groupFirstPlayer;
	readonly common uint8_t groupLastPlayer;
	readonly common uint8_t groupHide;
	readonly common uint8_t groupDetectPlayer;
	readonly common uint8_t groupTerrain;
	readonly common uint8_t groupDetection;
	readonly common Dictionary* store;
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	bool getShouldContact(uint8_t groupA, uint8_t groupB);
	void setRelation(uint8_t groupA, uint8_t groupB, Platformer::Relation relation);
	Platformer::Relation getRelation @ getRelationByGroup(uint8_t groupA, uint8_t groupB);
	Platformer::Relation getRelation(Body* bodyA, Body* bodyB);
	bool isEnemy @ isEnemyGroup(uint8_t groupA, uint8_t groupB);
	bool isEnemy(Body* bodyA, Body* bodyB);
	bool isFriend @ isFriendGroup(uint8_t groupA, uint8_t groupB);
	bool isFriend(Body* bodyA, Body* bodyB);
	bool isNeutral @ isNeutralGroup(uint8_t groupA, uint8_t groupB);
	bool isNeutral(Body* bodyA, Body* bodyB);
	void setDamageFactor(uint16_t damageType, uint16_t defenceType, float bounus);
	float getDamageFactor(uint16_t damageType, uint16_t defenceType);
	bool isPlayer(Body* body);
	bool isTerrain(Body* body);
	void clear();
};

}

object class Buffer {
	void resize(uint32_t size);
	void zeroMemory();
	uint32_t size() const;
	void setString(string str);
	string toString();
};

singleton struct ImGui {

static void Binding::LoadFontTTFAsync @ load_font_ttf_async(
	string ttfFontFile,
	float fontSize,
	string glyphRanges,
	function<void(bool success)> handler);

static bool Binding::IsFontLoaded @ is_font_loaded();

static void Binding::ShowStats @ showStats();
static void Binding::ShowConsole @ showConsole();

static bool Binding::Begin @ begin(string name);

static bool Binding::Begin @ beginOpts(
	string name,
	VecStr windowsFlags);

static void End @ end();

static bool Binding::BeginChild @ beginChild(string str_id);

static bool Binding::BeginChild @ beginChildOpts(
	string str_id,
	Vec2 size,
	VecStr childFlags,
	VecStr windowFlags);

static bool Binding::BeginChild @ beginChildWith_id(uint32_t id);

static bool Binding::BeginChild @ beginChildWith_idOpts(
	uint32_t id,
	Vec2 size,
	VecStr childFlags,
	VecStr windowFlags);

static void EndChild @ endChild();

static void Binding::SetNextWindowPosCenter @ setNextWindowPosCenter();

static void Binding::SetNextWindowPosCenter @ setNextWindowPosCenterWithCond(string setCond);

static void Binding::SetNextWindowSize @ setNextWindowSize(Vec2 size);

static void Binding::SetNextWindowSize @ setNextWindowSizeWithCond(
	Vec2 size,
	string setCond);

static void Binding::SetNextWindowCollapsed @ setNextWindowCollapsed(bool collapsed);

static void Binding::SetNextWindowCollapsed @ setNextWindowCollapsedWithCond(
	bool collapsed,
	string setCond);

static void Binding::SetWindowPos @ setWindowPos(string name, Vec2 pos);

static void Binding::SetWindowPos @ setWindowPosWithCond(
	string name,
	Vec2 pos,
	string setCond);

static void Binding::SetWindowSize @ setWindowSize(
	string name,
	Vec2 size);

static void Binding::SetWindowSize @ setWindowSizeWithCond(
	string name,
	Vec2 size,
	string setCond);

static void Binding::SetWindowCollapsed @ setWindowCollapsed(
	string name,
	bool collapsed);

static void Binding::SetWindowCollapsed @ setWindowCollapsedWithCond(
	string name,
	bool collapsed,
	string setCond);

static void Binding::SetColorEditOptions @ setColorEditOptions(string colorEditMode);

static bool Binding::InputText @ inputText(
	string label,
	Buffer* buffer);

static bool Binding::InputText @ inputTextOpts(
	string label,
	Buffer* buffer,
	VecStr inputTextFlags);

static bool Binding::InputTextMultiline @ inputTextMultiline(
	string label,
	Buffer* buffer);

static bool Binding::InputTextMultiline @ inputTextMultilineOpts(
	string label,
	Buffer* buffer,
	Vec2 size,
	VecStr inputTextFlags);

static bool Binding::TreeNodeEx @ treeNodeEx(string label);

static bool Binding::TreeNodeEx @ treeNodeExOpts(
	string label,
	VecStr treeNodeFlags);

static bool Binding::TreeNodeEx @ treeNodeExWith_id(
	string str_id,
	string text);

static bool Binding::TreeNodeEx @ treeNodeExWith_idOpts(
	string str_id,
	string text,
	VecStr treeNodeFlags);

static void Binding::SetNextItemOpen @ setNextItemOpen(bool is_open);

static void Binding::SetNextItemOpen @ setNextItemOpenWithCond(
	bool is_open,
	string setCond);

static bool Binding::CollapsingHeader @ collapsingHeader(string label);

static bool Binding::CollapsingHeader @ collapsingHeaderOpts(
	string label,
	VecStr treeNodeFlags);

static bool Binding::Selectable @ selectable(string label);

static bool Binding::Selectable @ selectableOpts(
	string label,
	VecStr selectableFlags);

static bool Binding::BeginPopupModal @ beginPopupModal(string name);

static bool Binding::BeginPopupModal @ beginPopupModalOpts(
	string name,
	VecStr windowsFlags);

static bool Binding::BeginPopupContextItem @ beginPopupContextItem(string name);

static bool Binding::BeginPopupContextItem @ beginPopupContextItemOpts(
	string name,
	VecStr popupFlags);

static bool Binding::BeginPopupContextWindow @ beginPopupContextWindow(string name);

static bool Binding::BeginPopupContextWindow @ beginPopupContextWindowOpts(
	string name,
	VecStr popupFlags);

static bool Binding::BeginPopupContextVoid @ beginPopupContextVoid(string name);

static bool Binding::BeginPopupContextVoid @ beginPopupContextVoidOpts(
	string name,
	VecStr popupFlags);

static void Binding::PushStyleColor @ bushStyleColor(string name, Color color);
static void Binding::PushStyleVar @ pushStyleFloat(string name, float val);
static void Binding::PushStyleVar @ pushStyleVec2(string name, Vec2 val);

static void Binding::Text @ text(string text);
static void Binding::TextColored @ textColored(Color color, string text);
static void Binding::TextDisabled @ textDisabled(string text);
static void Binding::TextWrapped @ textWrapped(string text);

static void Binding::LabelText @ labelText(string label, string text);
static void Binding::BulletText @ bulletText(string text);
static bool Binding::TreeNode @ treeNode(string str_id, string text);
static void Binding::SetTooltip @ setTooltip(string text);

static void Binding::Image @ image(
	string clipStr,
	Vec2 size);

static void Binding::Image @ imageOpts(
	string clipStr,
	Vec2 size,
	Color tint_col,
	Color border_col);

static bool Binding::ImageButton @ imageButton(
	string str_id,
	string clipStr,
	Vec2 size);

static bool Binding::ImageButton @ imageButtonOpts(
	string str_id,
	string clipStr,
	Vec2 size,
	Color bg_col,
	Color tint_col);

static bool Binding::ColorButton @ colorButton(
	string desc_id,
	Color col);

static bool Binding::ColorButton @ colorButtonOpts(
	string desc_id,
	Color col,
	string flags,
	Vec2 size);

static void Binding::Columns @ columns(int count);

static void Binding::Columns @ columnsOpts(
	int count,
	bool border,
	string str_id);

static bool Binding::BeginTable @ beginTable(string str_id, int column);

static bool Binding::BeginTable @ beginTableOpts(
	string str_id,
	int column,
	Vec2 outer_size,
	float inner_width,
	VecStr tableFlags);

static void Binding::TableNextRow @ tableNextRow();

static void Binding::TableNextRow @ tableNextRowOpts(
	float min_row_height,
	string tableRowFlag);

static void Binding::TableSetupColumn @ tableSetupColumn(string label);

static void Binding::TableSetupColumn @ tableSetupColumnOpts(
	string label,
	float init_width_or_weight,
	uint32_t user_id,
	VecStr tableColumnFlags);

static void Binding::SetStyleVar @ setStyleBool(string name, bool var);
static void Binding::SetStyleVar @ setStyleFloat(string name, float var);
static void Binding::SetStyleVar @ setStyleVec2(string name, Vec2 var);
static void Binding::SetStyleColor @ setStyleColor(string name, Color color);

static bool Binding::Begin @ _begin(
	string name,
	CallStack* stack);

static bool Binding::Begin @ _beginOpts(
	string name,
	CallStack* stack,
	VecStr windowsFlags);

static bool Binding::CollapsingHeader @ _collapsingHeader(
	string label,
	CallStack* stack);

static bool Binding::CollapsingHeader @ _collapsingHeaderOpts(
	string label,
	CallStack* stack,
	VecStr treeNodeFlags);

static bool Binding::Selectable @ _selectable(
	string label,
	CallStack* stack);

static bool Binding::Selectable @ _selectableOpts(
	string label,
	CallStack* stack,
	Vec2 size,
	VecStr selectableFlags);

static bool Binding::BeginPopupModal @ _beginPopupModal(
	string name,
	CallStack* stack);

static bool Binding::BeginPopupModal @ _beginPopupModalOpts(
	string name,
	CallStack* stack,
	VecStr windowsFlags);

static bool Binding::Combo @ _combo(
	string label,
	CallStack* stack,
	VecStr items);

static bool Binding::Combo @ _comboOpts(
	string label,
	CallStack* stack,
	VecStr items,
	int height_in_items);

static bool Binding::DragFloat @ _dragFloat(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max);

static bool Binding::DragFloat @ _dragFloatOpts(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::DragFloat2 @ _dragFloat2(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max);

static bool Binding::DragFloat2 @ _dragFloat2Opts(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::DragInt @ _dragInt(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max);

static bool Binding::DragInt @ _dragIntOpts(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::DragInt2 @ _dragInt2(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max);

static bool Binding::DragInt2 @ _dragInt2Opts(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::InputFloat @ _inputFloat(
	string label,
	CallStack* stack);

static bool Binding::InputFloat @ _inputFloatOpts(
	string label,
	CallStack* stack,
	float step,
	float step_fast,
	string display_format,
	VecStr inputTextFlags);

static bool Binding::InputFloat2 @ _inputFloat2(
	string label,
	CallStack* stack);

static bool Binding::InputFloat2 @ _inputFloat2Opts(
	string label,
	CallStack* stack,
	string display_format,
	VecStr inputTextFlags);

static bool Binding::InputInt @ _inputInt(
	string label,
	CallStack* stack);

static bool Binding::InputInt @ _inputIntOpts(
	string label,
	CallStack* stack,
	int step,
	int step_fast,
	VecStr inputTextFlags);

static bool Binding::InputInt2 @ _inputInt2(
	string label,
	CallStack* stack);

static bool Binding::InputInt2 @ _inputInt2Opts(
	string label,
	CallStack* stack,
	VecStr inputTextFlags);

static bool Binding::SliderFloat @ _sliderFloat(
	string label,
	CallStack* stack,
	float v_min,
	float v_max);

static bool Binding::SliderFloat @ _sliderFloatOpts(
	string label,
	CallStack* stack,
	float v_min,
	float v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::SliderFloat2 @ _sliderFloat2(
	string label,
	CallStack* stack,
	float v_min,
	float v_max);

static bool Binding::SliderFloat2 @ _sliderFloat2Opts(
	string label,
	CallStack* stack,
	float v_min,
	float v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::SliderInt @ _sliderInt(
	string label,
	CallStack* stack,
	int v_min,
	int v_max);

static bool Binding::SliderInt @ _sliderIntOpts(
	string label,
	CallStack* stack,
	int v_min,
	int v_max,
	string format,
	VecStr sliderFlags);

static bool Binding::SliderInt2 @ _sliderInt2(
	string label,
	CallStack* stack,
	int v_min,
	int v_max);

static bool Binding::SliderInt2 @ _sliderInt2Opts(
	string label,
	CallStack* stack,
	int v_min,
	int v_max,
	string display_format,
	VecStr sliderFlags);

static bool Binding::DragFloatRange2 @ _dragFloatRange2(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max);

static bool Binding::DragFloatRange2 @ _dragFloatRange2Opts(
	string label,
	CallStack* stack,
	float v_speed,
	float v_min,
	float v_max,
	string format,
	string format_max,
	VecStr sliderFlags);

static bool Binding::DragIntRange2 @ _dragIntRange2(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max);

static bool Binding::DragIntRange2 @ _dragIntRange2Opts(
	string label,
	CallStack* stack,
	float v_speed,
	int v_min,
	int v_max,
	string format,
	string format_max,
	VecStr sliderFlags);

static bool Binding::VSliderFloat @ _vSliderFloat(
	string label,
	Vec2 size,
	CallStack* stack,
	float v_min,
	float v_max);

static bool Binding::VSliderFloat @ _vSliderFloatOpts(
	string label,
	Vec2 size,
	CallStack* stack,
	float v_min,
	float v_max,
	string format,
	VecStr sliderFlags);

static bool Binding::VSliderInt @ _vSliderInt(
	string label,
	Vec2 size,
	CallStack* stack,
	int v_min,
	int v_max);

static bool Binding::VSliderInt @ _vSliderIntOpts(
	string label,
	Vec2 size,
	CallStack* stack,
	int v_min,
	int v_max,
	string format,
	VecStr sliderFlags);

static bool Binding::ColorEdit3 @ _colorEdit3(string label, CallStack* stack);

static bool Binding::ColorEdit4 @ _colorEdit4(string label, CallStack* stack, bool show_alpha);

static void Binding::ScrollWhenDraggingOnVoid @ scrollWhenDraggingOnVoid();

static void Binding::SetNextWindowPos @ setNextWindowPos(Vec2 pos, string setCond, Vec2 pivot);
static void SetNextWindowBgAlpha(float alpha);
static void ShowDemoWindow();
static Vec2 GetContentRegionMax();
static Vec2 GetContentRegionAvail();
static Vec2 GetWindowContentRegionMin();
static Vec2 GetWindowContentRegionMax();
static Vec2 GetWindowPos();
static Vec2 GetWindowSize();
static float GetWindowWidth();
static float GetWindowHeight();
static bool IsWindowCollapsed();
static void SetWindowFontScale(float scale);
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
static void PopStyleColor(int count);
static void PopStyleVar(int count);
static void SetNextItemWidth(float item_width);
static void PushItemWidth(float item_width);
static void PopItemWidth();
static float CalcItemWidth();
static void PushTextWrapPos(float wrap_pos_x);
static void PopTextWrapPos();
static void PushTabStop(bool v);
static void PopTabStop();
static void PushButtonRepeat(bool repeat);
static void PopButtonRepeat();
static void Separator();
static void SameLine(float pos_x, float spacing_w);
static void NewLine();
static void Spacing();
static void Dummy(Vec2 size);
static void Indent(float indent_w);
static void Unindent(float indent_w);
static void BeginGroup();
static void EndGroup();
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
static void EndTable();
static bool TableNextColumn();
static bool TableSetColumnIndex(int column_n);
static void TableSetupScrollFreeze(int cols, int rows);
static void TableHeadersRow();
static void PopID @ pop_id();
static void Bullet @ bulletItem();

static void Binding::SetWindowFocus @ SetWindowFocus(string name);
static void Binding::SeparatorText @ SeparatorText(string text);
static void Binding::TableHeader @ TableHeader(string label);
static void Binding::PushID @ push_id(string str_id);
static uint32_t Binding::GetID @ get_id(string str_id);
static bool Binding::Button @ Button(string label, Vec2 size);
static bool Binding::SmallButton @ SmallButton(string label);
static bool Binding::InvisibleButton @ InvisibleButton(string str_id, Vec2 size);

static bool Binding::Checkbox @ _checkbox(string label, CallStack* stack);
static bool Binding::RadioButton @ _radioButton(string label, CallStack* stack, int v_button);

static void Binding::PlotLines @ PlotLines(string label, VecFloat values);
static void Binding::PlotLines @ plotLinesWithScale(string label, VecFloat values, int values_offset, string overlay_text, float scale_min, float scale_max, Vec2 graph_size);

static void Binding::PlotHistogram @ PlotHistogram(string label, VecFloat values);
static void Binding::PlotHistogram @ plotHistogramWithScale(string label, VecFloat values, int values_offset, string overlay_text, float scale_min, float scale_max, Vec2 graph_size);

static void Binding::ProgressBar @ ProgressBar(float fraction);
static void Binding::ProgressBar @ ProgressBarWithOverlay(float fraction, Vec2 size_arg, string overlay);

static bool Binding::ListBox @ _listBox(string label, CallStack* stack, VecStr items);
static bool Binding::ListBox @ _listBoxWithHeight(string label, CallStack* stack, VecStr items, int height_in_items);

static bool Binding::SliderAngle @ SliderAngle(string label, CallStack* stack, float v_degrees_min, float v_degrees_max);

static void Binding::TreePush @ TreePush(string str_id);
static bool Binding::BeginListBox @ BeginListBox(string label, Vec2 size);
static void Binding::Value @ Value(string prefix, bool b);
static bool Binding::BeginMenu @ BeginMenu(string label, bool enabled);
static bool Binding::MenuItem @ MenuItem(string label, string shortcut, bool selected, bool enabled);
static void Binding::OpenPopup @ OpenPopup(string str_id);
static bool Binding::BeginPopup @ BeginPopup(string str_id);

static void TreePop();
static float GetTreeNodeToLabelSpacing();
static void EndListBox();
static void BeginDisabled();
static void EndDisabled();
static void BeginTooltip();
static void EndTooltip();
static bool BeginMainMenuBar();
static void EndMainMenuBar();
static bool BeginMenuBar();
static void EndMenuBar();
static void EndMenu();
static void EndPopup();
static void CloseCurrentPopup();
static void PushClipRect(Vec2 clip_rect_min, Vec2 clip_rect_max, bool intersect_with_current_clip_rect);
static void PopClipRect();
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
};

