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
	static outside Rect Rect_GetZero @ zero();
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
	readonly common uint64_t rand;
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
	/// whether the game engine is running in full screen mode.
	/// It is not available to set this property on platform Android and iOS.
	boolean bool fullScreen;
	/// whether the game engine window is always on top. Default is true.
	/// It is not available to set this property on platform Android and iOS.
	boolean bool alwaysOnTop;
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
	/// the first entity in the group.
	optional readonly common Entity* first;
	/// Finds the first entity in the group that satisfies a predicate function.
	///
	/// # Arguments
	///
	/// * `predicate` - The predicate function to test each entity with.
	///
	/// # Returns
	///
	/// * `Option<Entity>` - The first entity that satisfies the predicate, or None if no entity does.
	optional Entity* find(function<def_false bool(Entity* e)> predicate) const;
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
singleton struct Path
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

value struct WorkSheet
{
	bool read(Array* row);
};

value struct WorkBook
{
	WorkSheet getSheet(string name);
};

/// The `Content` is a static struct that manages file searching,
/// loading and other operations related to resources.
singleton class Content
{
	/// an array of directories to search for resource files.
	common VecStr searchPaths;
	/// the path to the directory containing read-only resources. Can only be altered by the user on platform Windows, MacOS and Linux.
	common string assetPath;
	/// the path to the directory where files can be written. Can only be altered by the user on platform Windows, MacOS and Linux. Default is the same as `appPath`.
	common string writablePath;
	/// the path to the directory for the application storage.
	readonly common string appPath;
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
	/// Checks if the specified path is an absolute path.
	///
	/// # Arguments
	///
	/// * `path` - The path to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the path is an absolute path, `false` otherwise.
	bool isAbsolutePath(string path);
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
	/// * `srcFile` - The path of the file or folder to copy.
	/// * `targetFile` - The destination path of the copied files.
	/// * `callback` - The function to call with a boolean indicating whether the file or folder was copied successfully.
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
	/// * `callback` - The function to call with a boolean indicating whether the content was saved successfully.
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
	/// * `callback` - The function to call with a boolean indicating whether the folder was compressed successfully.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the folder was compressed successfully, `false` otherwise.
	void zipAsync(string folderPath, string zipFile, function<def_false bool(string file)> filter, function<void(bool success)> callback);
	/// Asynchronously decompresses a ZIP archive to the specified folder.
	///
	/// # Arguments
	///
	/// * `zip_file` - The name of the ZIP archive to decompress, should be a file under the asset writable path.
	/// * `folder_path` - The path of the folder to decompress to, should be under the asset writable path.
	/// * `filter` - An optional function to filter the files to include in the archive. The function takes a filename as input and returns a boolean indicating whether to include the file. If not provided, all files will be included.
	/// * `callback` - The function to call with a boolean indicating whether the archive was decompressed successfully.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the folder was decompressed successfully, `false` otherwise.
	void unzipAsync(string zipFile, string folderPath, function<def_false bool(string file)> filter, function<void(bool success)> callback);

	outside WorkBook content_wasm_load_excel @ load_excel(string filename);
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
	/// Used for manually updating the scheduler if it is created by the user.
	///
	/// # Arguments
	///
	/// * `deltaTime` - The time in seconds since the last frame update.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the scheduler was stoped, `false` otherwise.
	bool update(double deltaTime);
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
	/// * `val` - The numeric value to set.
	void set @ set(string name, float val);
	/// Sets the values of shader parameters.
	///
	/// # Arguments
	///
	/// * `name` - The name of the parameter to set.
	/// * `val1` - The first numeric value to set.
	/// * `val2` - An optional second numeric value to set.
	/// * `val3` - An optional third numeric value to set.
	/// * `val4` - An optional fourth numeric value to set.
	void set @ setVec4(string name, float val1, float val2, float val3, float val4);
	/// Another function that sets the values of shader parameters.
	///
	/// Works the same as:
	/// pass.set("varName", color.r / 255.0, color.g / 255.0, color.b / 255.0, color.opacity);
	///
	/// # Arguments
	///
	/// * `name` - The name of the parameter to set.
	/// * `val` - The Color object to set.
	void set @ setColor(string name, Color val);
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
	outside optional Pass* Effect_GetPass @ get(size_t index) const;
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
	/// the root node for 2D user interface elements like buttons and labels.
	readonly common Node* uI @ ui;
	/// the root node for 3D user interface elements with 3D projection effect.
	readonly common Node* uI3D @ ui_3d;
	/// the root node for the starting point of a game.
	readonly common Node* entry;
	/// the root node for post-rendering scene tree.
	readonly common Node* postNode;
	/// the current active camera in Director's camera stack.
	readonly common Camera* currentCamera;
	/// whether or not to enable frustum culling.
	boolean bool frustumCulling;
	/// Schedule a function to be called every frame.
	///
	/// # Arguments
	///
	/// * `updateFunc` - The function to call every frame.
	outside void Director_Schedule @ schedule(function<def_true bool(double deltaTime)> updateFunc);
	/// Schedule a function to be called every frame for processing post game logic.
	///
	/// # Arguments
	///
	/// * `func` - The function to call every frame.
	outside void Director_SchedulePosted @ schedulePosted(function<def_true bool(double deltaTime)> updateFunc);
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
	outside void Director_Cleanup @ cleanup();
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
	outside void View_SetPostEffectNullptr @ set_post_effect_null();
	/// whether or not vertical sync is enabled.
	boolean bool vSync @ vsync;
};

value class ActionDef {
	/// Creates a new action definition object to change a property of a node.
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
	/// * `ActionDef` - A new ActionDef object.
	static outside ActionDef ActionDef_Prop @ prop(float duration, float start, float stop, Property prop, EaseType easing);
	/// Creates a new action definition object to change the color of a node.
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
	/// * `ActionDef` - A new ActionDef object.
	static outside ActionDef ActionDef_Tint @ tint(float duration, Color3 start, Color3 stop, EaseType easing);
	/// Creates a new action definition object to rotate a node by smallest angle.
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
	/// * `ActionDef` - A new ActionDef object.
	static outside ActionDef ActionDef_Roll @ roll(float duration, float start, float stop, EaseType easing);
	/// Creates a new action definition object to run a group of actions in parallel.
	///
	/// # Arguments
	///
	/// * `defs` - The actions to run in parallel.
	///
	/// # Returns
	///
	/// * `ActionDef` - A new ActionDef object.
	static outside ActionDef ActionDef_Spawn @ spawn(VecActionDef defs);
	/// Creates a new action definition object to run a group of actions in sequence.
	///
	/// # Arguments
	///
	/// * `defs` - The actions to run in sequence.
	///
	/// # Returns
	///
	/// * `ActionDef` - A new ActionDef object.
	static outside ActionDef ActionDef_Sequence @ sequence(VecActionDef defs);
	/// Creates a new action definition object to delay the execution of following action.
	///
	/// # Arguments
	///
	/// * `duration` - The duration of the delay.
	///
	/// # Returns
	///
	/// * `ActionDef` - A new ActionDef object.
	static outside ActionDef ActionDef_Delay @ delay(float duration);
	/// Creates a new action definition object to show a node.
	static outside ActionDef ActionDef_Show @ show();
	/// Creates a new action definition object to hide a node.
	static outside ActionDef ActionDef_Hide @ hide();
	/// Creates a new action definition object to emit an event.
	///
	/// # Arguments
	///
	/// * `eventName` - The name of the event to emit.
	/// * `msg` - The message to send with the event.
	///
	/// # Returns
	///
	/// * `ActionDef` - A new ActionDef object.
	static outside ActionDef ActionDef_Emit @ event(string eventName, string msg);
	/// Creates a new action definition object to move a node.
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
	/// * `ActionDef` - A new ActionDef object.
	static outside ActionDef ActionDef_Move @ move_to(float duration, Vec2 start, Vec2 stop, EaseType easing);
	/// Creates a new action definition object to scale a node.
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
	/// * `ActionDef` - A new ActionDef object.
	static outside ActionDef ActionDef_Scale @ scale(float duration, float start, float stop, EaseType easing);
	/// Creates a new action definition object to do a frame animation. Can only be performed on a Sprite node.
	///
	/// # Arguments
	///
	/// * `clipStr` - The name of the image clip, which is a sprite sheet. Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
	/// * `duration` - The duration of the action.
	///
	/// # Returns
	///
	/// * `ActionDef` - A new ActionDef object.
	static outside ActionDef ActionDef_Frame @ frame(string clipStr, float duration);
	/// Creates a new action definition object to do a frame animation with frames count for each frame. Can only be performed on a Sprite node.
	///
	/// # Arguments
	///
	/// * `clipStr` - The name of the image clip, which is a sprite sheet. Can be "Image/file.png" and "Image/items.clip|itemA". Supports image file format: jpg, png, dds, pvr, ktx.
	/// * `duration` - The duration of the action.
	/// * `frames` - The number of frames for each frame.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	static outside ActionDef ActionDef_Frame @ frame_with_frames(string clipStr, float duration, VecUint32 frames);
};

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
	/// Creates a new Action object.
	///
	/// # Arguments
	///
	/// * `def` - The definition of the action.
	///
	/// # Returns
	///
	/// * `Action` - A new Action object.
	static Action* create(ActionDef def);
};

/// A grabber which is used to render a part of the scene to a texture
/// by a grid of vertices.
object class Grabber
{
	/// the camera used to render the texture.
	optional common Camera* camera;
	/// the sprite effect applied to the texture.
	optional common SpriteEffect* effect;
	/// the blend function for the grabber.
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
	/// whether the node is currently running in a scene tree.
	readonly boolean bool running;
	/// whether the node is currently scheduling a function for updates.
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
	/// whether debug graphic should be displayed for the node.
	boolean bool showDebug;
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
	/// Schedules a main function to run every frame. Call this function again to replace the previous scheduled main function or coroutine.
	///
	/// # Arguments
	///
	/// * `updateFunc` - The function to be called. If the function returns `true`, it will not be called again.
	void schedule(function<def_true bool(double deltaTime)> updateFunc);
	/// Unschedules the current node's scheduled main function.
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
	/// * `callback` - The function to call with the converted point in world space.
	///
	/// # Returns
	///
	/// * `Vec2` - The converted point in world space.
	void convertToWindowSpace(Vec2 nodePoint, function<void(Vec2 result)> callback);
	/// Calls the given function for each child node of this node.
	///
	/// # Arguments
	///
	/// * `visitorFunc` - The function to call for each child node. The function should return a boolean value indicating whether to continue the iteration. Return true to stop iteration.
	///
	/// # Returns
	///
	/// * `bool` - `false` if all children have been visited, `true` if the iteration was interrupted by the function.
	bool eachChild(function<def_true bool(Node* child)> visitorFunc);
	/// Traverses the node hierarchy starting from this node and calls the given function for each visited node. The nodes without `TraverseEnabled` flag are not visited.
	///
	/// # Arguments
	///
	/// * `visitorFunc` - The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal. Return true to stop iteration.
	///
	/// # Returns
	///
	/// * `bool` - `false` if all nodes have been visited, `true` if the traversal was interrupted by the function.
	bool traverse(function<def_true bool(Node* child)> visitorFunc);
	/// Traverses the entire node hierarchy starting from this node and calls the given function for each visited node.
	///
	/// # Arguments
	///
	/// * `visitorFunc` - The function to call for each visited node. The function should return a boolean value indicating whether to continue the traversal.
	///
	/// # Returns
	///
	/// * `bool` - `false` if all nodes have been visited, `true` if the traversal was interrupted by the function.
	bool traverseAll(function<def_true bool(Node* child)> visitorFunc);
	/// Runs an action defined by the given action definition on this node.
	///
	/// # Arguments
	///
	/// * `action_def` - The action definition to run.
	/// * `looped` - Whether to loop the action.
	///
	/// # Returns
	///
	/// * `f32` - The duration of the newly running action in seconds.
	outside float Node_RunActionDefDuration @ run_action_def(ActionDef def, bool looped);
	/// Runs an action on this node.
	///
	/// # Arguments
	///
	/// * `action` - The action to run.
	/// * `looped` - Whether to loop the action.
	///
	/// # Returns
	///
	/// * `f32` - The duration of the newly running action in seconds.
	float runAction @ runAction(Action* action, bool looped);
	/// Stops all actions running on this node.
	void stopAllActions();
	/// Runs an action defined by the given action definition right after clearing all the previous running actions.
	///
	/// # Arguments
	///
	/// * `action_def` - The action definition to run.
	/// * `looped` - Whether to loop the action.
	///
	/// # Returns
	///
	/// * `f32` - The duration of the newly running action in seconds.
	outside float Node_PerformDefDuration @ perform_def(ActionDef actionDef, bool looped);
	/// Runs an action on this node right after clearing all the previous running actions.
	///
	/// # Arguments
	///
	/// * `action` - The action to run.
	/// * `looped` - Whether to loop the action.
	///
	/// # Returns
	///
	/// * `f32` - The duration of the newly running action in seconds.
	float perform(Action* action, bool looped);
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
	/// * `Grabber` - A Grabber object with gridX == 1 and gridY == 1.
	outside Grabber* Node_StartGrabbing @ grab();
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
	outside void Node_StopGrabbing @ stop_grab();
	/// Removes the transform target for the specified node.
	outside void Node_SetTransformTargetNullptr @ set_transform_target_null();
	/// Associates the given handler function with the node event.
	///
	/// # Arguments
	///
	/// * `event_name` - The name of the node event.
	/// * `handler` - The handler function to associate with the node event.
	void slot(string eventName, function<void(Event* e)> handler);
	/// Associates the given handler function with a global event.
	///
	/// # Arguments
	///
	/// * `event_name` - The name of the global event.
	/// * `handler` - The handler function to associate with the event.
	void gslot(string eventName, function<void(Event* e)> handler);
	/// Emits an event to a node, triggering the event handler associated with the event name.
	///
	/// # Arguments
	///
	/// * `name` - The name of the event.
	/// * `stack` - The argument stack to be passed to the event handler.
	outside void Node_Emit @ emit(string name, CallStack* stack);
	/// Schedules a function to run every frame. Call this function again to schedule multiple functions.
	///
	/// # Arguments
	///
	/// * `updateFunc` - The function to run every frame. If the function returns `true`, it will not be called again.
	void onUpdate(function<def_true bool(double deltaTime)> updateFunc);
	/// Registers a callback for event triggered when the node is entering the rendering phase. The callback is called every frame, and ensures that its call order is consistent with the rendering order of the scene tree, such as rendering child nodes after their parent nodes. Recommended for calling vector drawing functions.
	///
	/// # Arguments
	///
	/// * `func` - The function to call when the node is entering the rendering phase, returns true to stop.
	///
	/// # Returns
	///
	/// * `void` - True to stop the function from running.
	void onRender(function<def_true bool(double deltaTime)> renderFunc);
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
	static outside optional Texture2D* Texture2D_Create @ createFile(string filename);
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
	outside void Sprite_SetEffectNullptr @ set_effect_as_default();
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
	/// the blend function for the grid.
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
	/// whether this is the first touch event when multi-touches exist.
	readonly boolean bool first;
	/// the unique identifier assigned to this touch event.
	readonly common int id;
	/// the amount and direction of movement since the last touch event.
	readonly common Vec2 delta;
	/// the location of the touch event in the node's local coordinate system.
	readonly common Vec2 location;
	/// the location of the touch event in the world coordinate system.
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
	/// the color of the outline, only works with SDF label.
	common Color outlineColor;
	/// the width of the outline, only works with SDF label.
	common float outlineWidth;
	/// the smooth value of the text, only works with SDF label, default is (0.7, 0.7).
	common Vec2 smooth;
	/// the text to be rendered.
	common string text;
	/// the blend function for the label.
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
	/// * `sdf` - Whether to use SDF rendering or not. With SDF rendering, the outline feature will be enabled.
	///
	/// # Returns
	///
	/// * `Label` - The new Label object.
	static optional Label* create(string fontName, uint32_t fontSize, bool sdf);
	/// Creates a new Label object with the specified font string.
	///
	/// # Arguments
	///
	/// * `font_str` - The font string to use for the label. Should be in the format "fontName;fontSize;sdf", where `sdf` should be "true" or "false".
	///
	/// # Returns
	///
	/// * `Label` - The new Label object.
	static optional Label* create @ with_str(string fontStr);
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
	/// * `handler` - The function to call when the save operation is complete. The function will be passed a boolean value indicating whether the save operation was successful.
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
	/// the blend function for the draw node.
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
	/// the blend function for the line node.
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
	/// * `visitorFunc` - The function to call for each node.
	///
	/// # Returns
	///
	/// * `bool` - Whether the function was called for all nodes or not.
	bool eachNode(function<def_false bool(Node* node)> visitorFunc);
	/// Creates a new instance of 'Model' from the specified model file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the model file to load. Can be filename with or without extension like: "Model/item" or "Model/item.model".
	///
	/// # Returns
	///
	/// * A new instance of 'Model'.
	static optional Model* create(string filename);
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
	static outside string Model_GetClipFilename @ getClipFile(string filename);
	/// Gets an array of look names from the specified model file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the model file to search.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing an array of look names found in the model file.
	static outside VecStr Model_GetLookNames @ getLooks(string filename);
	/// Gets an array of animation names from the specified model file.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the model file to search.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing an array of animation names found in the model file.
	static outside VecStr Model_GetAnimationNames @ getAnimations(string filename);
};

/// An implementation of an animation system using the Spine engine.
object class Spine : public IPlayable
{
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
	static optional Spine* create @ createFiles(string skelFile, string atlasFile);
	/// Creates a new instance of 'Spine' using the specified Spine string.
	///
	/// # Arguments
	///
	/// * `spine_str` - The Spine file string for the new instance. A Spine file string can be a file path with the target file extension like "Spine/item" or file paths with all the related files like "Spine/item.skel|Spine/item.atlas" or "Spine/item.json|Spine/item.atlas".
	///
	/// # Returns
	///
	/// * A new instance of 'Spine'. Returns `None` if the Spine file could not be loaded.
	static optional Spine* create(string spineStr);
	/// Returns a list of available looks for the specified Spine2D file string.
	///
	/// # Arguments
	///
	/// * `spine_str` - The Spine2D file string to get the looks for.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing the available looks.
	static outside VecStr Spine_GetLookNames @ getLooks(string spineStr);
	/// Returns a list of available animations for the specified Spine2D file string.
	///
	/// # Arguments
	///
	/// * `spine_str` - The Spine2D file string to get the animations for.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing the available animations.
	static outside VecStr Spine_GetAnimationNames @ getAnimations(string spineStr);
};

/// An implementation of the 'Playable' record using the DragonBones animation system.
object class DragonBone : public IPlayable
{
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
	static optional DragonBone* create @ createFiles(string boneFile, string atlasFile);
	/// Creates a new instance of 'DragonBone' using the specified bone string.
	///
	/// # Arguments
	///
	/// * `bone_str` - The DragonBone file string for the new instance. A DragonBone file string can be a file path with the target file extension like "DragonBone/item" or file paths with all the related files like "DragonBone/item_ske.json|DragonBone/item_tex.json". An armature name can be added following a separator of ';'. like "DragonBone/item;mainArmature" or "DragonBone/item_ske.json|DragonBone/item_tex.json;mainArmature".
	///
	/// # Returns
	///
	/// * A new instance of 'DragonBone'. Returns `None` if the bone file or atlas file is not found.
	static optional DragonBone* create(string boneStr);
	/// Returns a list of available looks for the specified DragonBone file string.
	///
	/// # Arguments
	///
	/// * `bone_str` - The DragonBone file string to get the looks for.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing the available looks.
	static outside VecStr DragonBone_GetLookNames @ getLooks(string boneStr);
	/// Returns a list of available animations for the specified DragonBone file string.
	///
	/// # Arguments
	///
	/// * `bone_str` - The DragonBone file string to get the animations for.
	///
	/// # Returns
	///
	/// * A `Vec<String>` representing the available animations.
	static outside VecStr DragonBone_GetAnimationNames @ getAnimations(string boneStr);
};

/// A node used for aligning layout elements.
object class AlignNode : public INode
{
	/// Sets the layout style of the node.
	///
	/// # Arguments
	///
	/// * `style` - The layout style to set.
	/// The following properties can be set through a CSS style string:
	/// ## Layout direction and alignment
	/// * direction: Sets the direction (ltr, rtl, inherit).
	/// * align-items, align-self, align-content: Sets the alignment of different items (flex-start, center, stretch, flex-end, auto).
	/// * flex-direction: Sets the layout direction (column, row, column-reverse, row-reverse).
	/// * justify-content: Sets the arrangement of child items (flex-start, center, flex-end, space-between, space-around, space-evenly).
	/// ## Flex properties
	/// * flex: Sets the overall size of the flex container.
	/// * flex-grow: Sets the flex growth value.
	/// * flex-shrink: Sets the flex shrink value.
	/// * flex-wrap: Sets whether to wrap (nowrap, wrap, wrap-reverse).
	/// * flex-basis: Sets the flex basis value or percentage.
	/// ## Margins and dimensions
	/// * margin: Can be set by a single value or multiple values separated by commas, percentages or auto for each side.
	/// * margin-top, margin-right, margin-bottom, margin-left, margin-start, margin-end: Sets the margin values, percentages or auto.
	/// * padding: Can be set by a single value or multiple values separated by commas or percentages for each side.
	/// * padding-top, padding-right, padding-bottom, padding-left: Sets the padding values or percentages.
	/// * border: Can be set by a single value or multiple values separated by commas for each side.
	/// * width, height, min-width, min-height, max-width, max-height: Sets the dimension values or percentage properties.
	/// ## Positioning
	/// * top, right, bottom, left, start, end, horizontal, vertical: Sets the positioning property values or percentages.
	/// ## Other properties
	/// * position: Sets the positioning type (absolute, relative, static).
	/// * overflow: Sets the overflow property (visible, hidden, scroll).
	/// * display: Controls whether to display (flex, none).
	void css(string style);
	/// Creates a new AlignNode object.
	///
	/// # Arguments
	///
	/// * `isWindowRoot` - Whether the node is a window root node. A window root node will automatically listen for window size change events and update the layout accordingly.
	static AlignNode* create(bool isWindowRoot);
};

/// A struct for playing Effekseer effects.
object class EffekNode : public INode
{
	/// Plays an effect at the specified position.
	///
	/// # Arguments
	///
	/// * `filename` - The filename of the effect to play.
	/// * `pos` - The xy-position to play the effect at.
	/// * `z` - The z-position of the effect.
	///
	/// # Returns
	///
	/// * `int` - The handle of the effect.
	int play(string filename, Vec2 pos, float z);
	/// Stops an effect with the specified handle.
	///
	/// # Arguments
	///
	/// * `handle` - The handle of the effect to stop.
	void stop(int handle);
	/// Creates a new EffekNode object.
	///
	/// # Returns
	///
	/// * `EffekNode` - A new EffekNode object.
	static EffekNode* create();
};

/// The TileNode class to render Tilemaps from TMX file in game scene tree hierarchy.
object class TileNode : public INode
{
	/// whether the depth buffer should be written to when rendering the tilemap.
	boolean bool depthWrite;
	/// the blend function for the tilemap.
	common BlendFunc blendFunc;
	/// the tilemap shader effect.
	common SpriteEffect* effect;
	/// the texture filtering mode for the tilemap.
	common TextureFilter filter;
	/// Get the layer data by name from the tilemap.
	///
	/// # Arguments
	///
	/// * `layerName` - The name of the layer in the TMX file.
	///
	/// # Returns
	///
	/// * `Dictionary` - The layer data as a dictionary object.
	optional Dictionary* getLayer(string layerName) const;
	/// Creates a `TileNode` object that will render the tile layers from a TMX file.
	///
	/// # Arguments
	///
	/// * `tmxFile` - The TMX file for the tilemap. This should be a file created with the Tiled Map Editor (http://www.mapeditor.org) and must be in XML format.
	///
	/// # Returns
	///
	/// Returns a new instance of the `TileNode` class. If the tilemap file is not found, it will return `None`.
	static optional TileNode* create(string tmxFile);
	/// Creates a `TileNode` object that will render the specified tile layer from a TMX file.
	///
	/// # Arguments
	///
	/// * `tmxFile` - The TMX file for the tilemap. This should be a file created with the Tiled Map Editor (http://www.mapeditor.org) and must be in XML format.
	/// * `layerName` - The name of the layer in the TMX file.
	///
	/// # Returns
	///
	/// Returns a new instance of the `TileNode` class. If the tilemap file is not found, it will return `None`.
	static optional TileNode* create @ createWithLayer(string tmxFile, string layerName);
	/// Creates a `TileNode` object that will render the specified tile layers from a TMX file.
	///
	/// # Arguments
	///
	/// * `tmxFile` - The TMX file for the tilemap. This should be a file created with the Tiled Map Editor (http://www.mapeditor.org) and must be in XML format.
	/// * `layerNames` - A vector of names of the layers in the TMX file.
	///
	/// # Returns
	///
	/// Returns a new instance of the `TileNode` class. If the tilemap file is not found, it will return `None`.
	static optional TileNode* create @ createWithLayers(string tmxFile, VecStr layerNames);
};

/// A struct that represents a physics world in the game.
interface object class PhysicsWorld : public INode
{
	/// Queries the physics world for all bodies that intersect with the specified rectangle.
	///
	/// # Arguments
	///
	/// * `rect` - The rectangle to query for bodies.
	/// * `handler` - A function that is called for each body found in the query. The function takes a `Body` as an argument and returns a `bool` indicating whether to continue querying for more bodies. Return `false` to continue, `true` to stop.
	///
	/// # Returns
	///
	/// * `bool` - Whether the query was interrupted. `true` means interrupted, `false` otherwise.
	bool query(Rect rect, function<def_false bool(Body* body)> handler);
	/// Casts a ray through the physics world and finds the first body that intersects with the ray.
	///
	/// # Arguments
	///
	/// * `start` - The starting point of the ray.
	/// * `stop` - The ending point of the ray.
	/// * `closest` - Whether to stop ray casting upon the closest body that intersects with the ray. Set `closest` to `true` to get a faster ray casting search.
	/// * `handler` - A function that is called for each body found in the raycast. The function takes a `Body`, a `Vec2` representing the point where the ray intersects with the body, and a `Vec2` representing the normal vector at the point of intersection as arguments, and returns a `bool` indicating whether to continue casting the ray for more bodies. Return `false` to continue, `true` to stop.
	///
	/// # Returns
	///
	/// * `bool` - Whether the raycast was interrupted. `true` means interrupted, `false` otherwise.
	bool raycast(Vec2 start, Vec2 stop, bool closest, function<def_false bool(Body* body, Vec2 point, Vec2 normal)> handler);
	/// Sets the number of velocity and position iterations to perform in the physics world.
	///
	/// # Arguments
	///
	/// * `velocity_iter` - The number of velocity iterations to perform.
	/// * `position_iter` - The number of position iterations to perform.
	void setIterations(int velocityIter, int positionIter);
	/// Sets whether two physics groups should make contact with each other or not.
	///
	/// # Arguments
	///
	/// * `groupA` - The first physics group.
	/// * `groupB` - The second physics group.
	/// * `contact` - Whether the two groups should make contact with each other.
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	/// Gets whether two physics groups should make contact with each other or not.
	///
	/// # Arguments
	///
	/// * `groupA` - The first physics group.
	/// * `groupB` - The second physics group.
	///
	/// # Returns
	///
	/// * `bool` - Whether the two groups should make contact with each other.
	bool getShouldContact(uint8_t groupA, uint8_t groupB);
	/// the factor used for converting physics engine meters value to pixel value.
	/// Default 100.0 is a good value since the physics engine can well simulate real life objects
	/// between 0.1 to 10 meters. Use value 100.0 we can simulate game objects
	/// between 10 to 1000 pixels that suite most games.
	/// You can change this value before any physics body creation.
	static float scaleFactor;
	/// Creates a new `PhysicsWorld` object.
	///
	/// # Returns
	///
	/// * A new `PhysicsWorld` object.
	static PhysicsWorld* create();
};

object class FixtureDef { };

/// A struct to describe the properties of a physics body.
object class BodyDef
{
	/// Sets the define for the type of the body.
	///
	/// # Arguments
	///
	/// * `body_type` - The type of the body.
	outside void BodyDef_SetTypeEnum @ set_type(BodyType body_type);
	/// Gets the define for the type of the body.
	///
	/// # Returns
	///
	/// * `BodyType` - The type of the body.
	outside BodyType BodyDef_GetTypeEnum @ get_type() const;
	/// define for the position of the body.
	Vec2 offset @ position;
	/// define for the angle of the body.
	float angleOffset @ angle;
	/// define for the face image or other items accepted by creating `Face` for the body.
	string face;
	/// define for the face position of the body.
	Vec2 facePos;
	/// define for linear damping of the body.
	common float linearDamping;
	/// define for angular damping of the body.
	common float angularDamping;
	/// define for initial linear acceleration of the body.
	common Vec2 linearAcceleration;
	/// whether the body's rotation is fixed or not.
	boolean bool fixedRotation;
	/// whether the body is a bullet or not.
	/// Set to true to add extra bullet movement check for the body.
	boolean bool bullet;
	/// Creates a polygon fixture definition with the specified dimensions and center position.
	///
	/// # Arguments
	///
	/// * `center` - The center point of the polygon.
	/// * `width` - The width of the polygon.
	/// * `height` - The height of the polygon.
	/// * `angle` - The angle of the polygon.
	/// * `density` - The density of the polygon.
	/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
	/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.
	static FixtureDef* polygon @ polygonWithCenter(
		Vec2 center,
		float width,
		float height,
		float angle,
		float density,
		float friction,
		float restitution);
	/// Creates a polygon fixture definition with the specified dimensions.
	///
	/// # Arguments
	///
	/// * `width` - The width of the polygon.
	/// * `height` - The height of the polygon.
	/// * `density` - The density of the polygon.
	/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
	/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.
	static FixtureDef* polygon(
		float width,
		float height,
		float density,
		float friction,
		float restitution);
	/// Creates a polygon fixture definition with the specified vertices.
	///
	/// # Arguments
	///
	/// * `vertices` - The vertices of the polygon.
	/// * `density` - The density of the polygon.
	/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
	/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.0.
	static FixtureDef* polygon @ polygonWithVertices(
		VecVec2 vertices,
		float density,
		float friction,
		float restitution);
	/// Attaches a polygon fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `center` - The center point of the polygon.
	/// * `width` - The width of the polygon.
	/// * `height` - The height of the polygon.
	/// * `angle` - The angle of the polygon.
	/// * `density` - The density of the polygon.
	/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
	/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.0.
	void attachPolygon @ attachPolygonWithCenter(
		Vec2 center,
		float width,
		float height,
		float angle,
		float density,
		float friction,
		float restitution);
	/// Attaches a polygon fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `width` - The width of the polygon.
	/// * `height` - The height of the polygon.
	/// * `density` - The density of the polygon.
	/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
	/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.0.
	void attachPolygon(
		float width,
		float height,
		float density,
		float friction,
		float restitution);
	/// Attaches a polygon fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `vertices` - The vertices of the polygon.
	/// * `density` - The density of the polygon.
	/// * `friction` - The friction of the polygon. Should be between 0 and 1.0.
	/// * `restitution` - The restitution of the polygon. Should be between 0 and 1.0.
	void attachPolygon @ attachPolygonWithVertices(
		VecVec2 vertices,
		float density,
		float friction,
		float restitution);
	/// Creates a concave shape definition made of multiple convex shapes.
	///
	/// # Arguments
	///
	/// * `vertices` - A vector containing the vertices of each convex shape that makes up the concave shape. Each convex shape in the vertices vector should end with a `Vec2(0.0, 0.0)` as separator.
	/// * `density` - The density of the shape.
	/// * `friction` - The friction coefficient of the shape. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution (elasticity) of the shape. Should be between 0.0 and 1.0.
	///
	/// # Returns
	///
	/// * `FixtureDef` - The resulting fixture definition.
	static FixtureDef* multi(
		VecVec2 vertices,
		float density,
		float friction,
		float restitution);
	/// Attaches a concave shape definition made of multiple convex shapes to the body.
	///
	/// # Arguments
	///
	/// * `vertices` - A vector containing the vertices of each convex shape that makes up the concave shape. Each convex shape in the vertices vector should end with a `Vec2(0.0, 0.0)` as separator.
	/// * `density` - The density of the concave shape.
	/// * `friction` - The friction of the concave shape. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution of the concave shape. Should be between 0.0 and 1.0.
	void attachMulti(
		VecVec2 vertices,
		float density,
		float friction,
		float restitution);
	/// Creates a Disk-shape fixture definition.
	///
	/// # Arguments
	///
	/// * `center` - The center of the circle.
	/// * `radius` - The radius of the circle.
	/// * `density` - The density of the circle.
	/// * `friction` - The friction coefficient of the circle. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution (elasticity) of the circle. Should be between 0.0 and 1.0.
	///
	/// # Returns
	///
	/// * `FixtureDef` - The resulting fixture definition.
	static FixtureDef* disk @ diskWithCenter(
		Vec2 center,
		float radius,
		float density,
		float friction,
		float restitution);
	/// Creates a Disk-shape fixture definition.
	///
	/// # Arguments
	///
	/// * `radius` - The radius of the circle.
	/// * `density` - The density of the circle.
	/// * `friction` - The friction coefficient of the circle. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution (elasticity) of the circle. Should be between 0.0 and 1.0.
	///
	/// # Returns
	///
	/// * `FixtureDef` - The resulting fixture definition.
	static FixtureDef* disk(
		float radius,
		float density,
		float friction,
		float restitution);
	/// Attaches a disk fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `center` - The center point of the disk.
	/// * `radius` - The radius of the disk.
	/// * `density` - The density of the disk.
	/// * `friction` - The friction of the disk. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution of the disk. Should be between 0.0 and 1.0.
	void attachDisk @ attachDiskWithCenter(
		Vec2 center,
		float radius,
		float density,
		float friction,
		float restitution);
	/// Attaches a disk fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `radius` - The radius of the disk.
	/// * `density` - The density of the disk.
	/// * `friction` - The friction of the disk. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution of the disk. Should be between 0.0 and 1.0.
	void attachDisk(
		float radius,
		float density,
		float friction,
		float restitution);
	/// Creates a Chain-shape fixture definition. This fixture is a free form sequence of line segments that has two-sided collision.
	///
	/// # Arguments
	///
	/// * `vertices` - The vertices of the chain.
	/// * `friction` - The friction coefficient of the chain. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution (elasticity) of the chain. Should be between 0.0 and 1.0.
	///
	/// # Returns
	///
	/// * `FixtureDef` - The resulting fixture definition.
	static FixtureDef* chain(
		VecVec2 vertices,
		float friction,
		float restitution);
	/// Attaches a chain fixture definition to the body. The Chain fixture is a free form sequence of line segments that has two-sided collision.
	///
	/// # Arguments
	///
	/// * `vertices` - The vertices of the chain.
	/// * `friction` - The friction of the chain. Should be between 0.0 and 1.0.
	/// * `restitution` - The restitution of the chain. Should be between 0.0 and 1.0.
	void attachChain(
		VecVec2 vertices,
		float friction,
		float restitution);
	/// Attaches a polygon sensor fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `tag` - An integer tag for the sensor.
	/// * `width` - The width of the polygon.
	/// * `height` - The height of the polygon.
	void attachPolygonSensor(
		int tag,
		float width,
		float height);
	/// Attaches a polygon sensor fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `tag` - An integer tag for the sensor.
	/// * `center` - The center point of the polygon.
	/// * `width` - The width of the polygon.
	/// * `height` - The height of the polygon.
	/// * `angle` - Optional. The angle of the polygon.
	void attachPolygonSensor @ attachPolygonSensorWithCenter(
		int tag,
		Vec2 center,
		float width,
		float height,
		float angle);
	/// Attaches a polygon sensor fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `tag` - An integer tag for the sensor.
	/// * `vertices` - A vector containing the vertices of the polygon.
	void attachPolygonSensor @ attachPolygonSensorWithVertices(
		int tag,
		VecVec2 vertices);
	/// Attaches a disk sensor fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `tag` - An integer tag for the sensor.
	/// * `center` - The center of the disk.
	/// * `radius` - The radius of the disk.
	void attachDiskSensor @ attachDiskSensorWithCenter(
		int tag,
		Vec2 center,
		float radius);
	/// Attaches a disk sensor fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `tag` - An integer tag for the sensor.
	/// * `radius` - The radius of the disk.
	void attachDiskSensor(
		int tag,
		float radius);
	/// Creates a new instance of `BodyDef` class.
	///
	/// # Returns
	///
	/// * A new `BodyDef` object.
	static BodyDef* create();
};

/// A struct to represent a physics sensor object in the game world.
object class Sensor
{
	/// whether the sensor is currently enabled or not.
	boolean bool enabled;
	/// the tag for the sensor.
	readonly common int tag;
	/// the "Body" object that owns the sensor.
	readonly common Body* owner;
	/// whether the sensor is currently sensing any other "Body" objects in the game world.
	readonly boolean bool sensed;
	/// the array of "Body" objects that are currently being sensed by the sensor.
	readonly common Array* sensedBodies;
	/// Determines whether the specified `Body` object is currently being sensed by the sensor.
	///
	/// # Arguments
	///
	/// * `body` - The `Body` object to check if it is being sensed.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the `Body` object is being sensed by the sensor, `false` otherwise.
	bool contains(Body* body);
};

/// A struct represents a physics body in the world.
interface object class Body : public INode
{
	/// the physics world that the body belongs to.
	readonly common PhysicsWorld* physicsWorld @ world;
	/// the definition of the body.
	readonly common BodyDef* bodyDef;
	/// the mass of the body.
	readonly common float mass;
	/// whether the body is used as a sensor or not.
	readonly boolean bool sensor;
	/// the x-axis velocity of the body.
	common float velocityX;
	/// the y-axis velocity of the body.
	common float velocityY;
	/// the velocity of the body as a `Vec2`.
	common Vec2 velocity;
	/// the angular rate of the body.
	common float angularRate;
	/// the collision group that the body belongs to.
	common uint8_t group;
	/// the linear damping of the body.
	common float linearDamping;
	/// the angular damping of the body.
	common float angularDamping;
	/// the reference for an owner of the body.
	common Object* owner;
	/// whether the body is currently receiving contact events or not.
	boolean bool receivingContact;
	/// Applies a linear impulse to the body at a specified position.
	///
	/// # Arguments
	///
	/// * `impulse` - The linear impulse to apply.
	/// * `pos` - The position at which to apply the impulse.
	void applyLinearImpulse(Vec2 impulse, Vec2 pos);
	/// Applies an angular impulse to the body.
	///
	/// # Arguments
	///
	/// * `impulse` - The angular impulse to apply.
	void applyAngularImpulse(float impulse);
	/// Returns the sensor with the given tag.
	///
	/// # Arguments
	///
	/// * `tag` - The tag of the sensor to get.
	///
	/// # Returns
	///
	/// * `Sensor` - The sensor with the given tag.
	Sensor* getSensorByTag(int tag);
	/// Removes the sensor with the specified tag from the body.
	///
	/// # Arguments
	///
	/// * `tag` - The tag of the sensor to remove.
	///
	/// # Returns
	///
	/// * `bool` - Whether a sensor with the specified tag was found and removed.
	bool removeSensorByTag(int tag);
	/// Removes the given sensor from the body's sensor list.
	///
	/// # Arguments
	///
	/// * `sensor` - The sensor to remove.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the sensor was successfully removed, `false` otherwise.
	bool removeSensor(Sensor* sensor);
	/// Attaches a fixture to the body.
	///
	/// # Arguments
	///
	/// * `fixture_def` - The fixture definition for the fixture to attach.
	void attach(FixtureDef* fixtureDef);
	/// Attaches a new sensor with the given tag and fixture definition to the body.
	///
	/// # Arguments
	///
	/// * `tag` - The tag of the sensor to attach.
	/// * `fixture_def` - The fixture definition of the sensor.
	///
	/// # Returns
	///
	/// * `Sensor` - The newly attached sensor.
	Sensor* attachSensor(int tag, FixtureDef* fixtureDef);
	/// Registers a function to be called when the body begins to receive contact events. Return `false` from this function to prevent colliding.
	///
	/// # Arguments
	///
	/// * `filter` - The filter function to set.
	void onContactFilter(function<def_false bool(Body* body)> filter);
	/// Creates a new instance of `Body`.
	///
	/// # Arguments
	///
	/// * `def` - The definition for the body to be created.
	/// * `world` - The physics world where the body belongs.
	/// * `pos` - The initial position of the body.
	/// * `rot` - The initial rotation angle of the body in degrees.
	///
	/// # Returns
	///
	/// * A new `Body` instance.
	static Body* create(BodyDef* def, PhysicsWorld* world, Vec2 pos, float rot);
};

/// A struct that defines the properties of a joint to be created.
object class JointDef
{
	/// the center point of the joint, in local coordinates.
	Vec2 center;
	/// the position of the joint, in world coordinates.
	Vec2 position;
	/// the angle of the joint, in degrees.
	float angle;
	/// Creates a distance joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the physics body connected to joint will collide with each other.
	/// * `body_a` - The name of first physics body to connect with the joint.
	/// * `body_b` - The name of second physics body to connect with the joint.
	/// * `anchor_a` - The position of the joint on the first physics body.
	/// * `anchor_b` - The position of the joint on the second physics body.
	/// * `frequency` - The frequency of the joint, in Hertz.
	/// * `damping` - The damping ratio of the joint.
	///
	/// # Returns
	///
	/// * `JointDef` - The new joint definition.
	static JointDef* distance(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float frequency,
		float damping);
	/// Creates a friction joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the physics body connected to joint will collide with each other.
	/// * `body_a` - The first physics body to connect with the joint.
	/// * `body_b` - The second physics body to connect with the joint.
	/// * `world_pos` - The position of the joint in the game world.
	/// * `max_force` - The maximum force that can be applied to the joint.
	/// * `max_torque` - The maximum torque that can be applied to the joint.
	///
	/// # Returns
	///
	/// * `Joint` - The new friction joint definition.
	static JointDef* friction(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float maxForce,
		float maxTorque);
	/// Creates a gear joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the physics bodies connected to the joint can collide with each other.
	/// * `joint_a` - The first joint to connect with the gear joint.
	/// * `joint_b` - The second joint to connect with the gear joint.
	/// * `ratio` - The gear ratio.
	///
	/// # Returns
	///
	/// * `Joint` - The new gear joint definition.
	static JointDef* gear(
		bool collision,
		string jointA,
		string jointB,
		float ratio);
	/// Creates a new spring joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether the connected bodies should collide with each other.
	/// * `body_a` - The first body connected to the joint.
	/// * `body_b` - The second body connected to the joint.
	/// * `linear_offset` - Position of body-B minus the position of body-A, in body-A's frame.
	/// * `angular_offset` - Angle of body-B minus angle of body-A.
	/// * `max_force` - The maximum force the joint can exert.
	/// * `max_torque` - The maximum torque the joint can exert.
	/// * `correction_factor` - Correction factor. 0.0 = no correction, 1.0 = full correction.
	///
	/// # Returns
	///
	/// * `Joint` - The created joint definition.
	static JointDef* spring(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor);
	/// Creates a new prismatic joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether the connected bodies should collide with each other.
	/// * `body_a` - The first body connected to the joint.
	/// * `body_b` - The second body connected to the joint.
	/// * `world_pos` - The world position of the joint.
	/// * `axis_angle` - The axis angle of the joint.
	/// * `lower_translation` - Lower translation limit.
	/// * `upper_translation` - Upper translation limit.
	/// * `max_motor_force` - Maximum motor force.
	/// * `motor_speed` - Motor speed.
	///
	/// # Returns
	///
	/// * `MotorJoint` - The created prismatic joint definition.
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
	/// Creates a pulley joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the connected bodies will collide with each other.
	/// * `body_a` - The first physics body to connect.
	/// * `body_b` - The second physics body to connect.
	/// * `anchor_a` - The position of the anchor point on the first body.
	/// * `anchor_b` - The position of the anchor point on the second body.
	/// * `ground_anchor_a` - The position of the ground anchor point on the first body in world coordinates.
	/// * `ground_anchor_b` - The position of the ground anchor point on the second body in world coordinates.
	/// * `ratio` - The pulley ratio.
	///
	/// # Returns
	///
	/// * `Joint` - The pulley joint definition.
	static JointDef* pulley(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		Vec2 groundAnchorA,
		Vec2 groundAnchorB,
		float ratio);
	/// Creates a revolute joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the connected bodies will collide with each other.
	/// * `body_a` - The first physics body to connect.
	/// * `body_b` - The second physics body to connect.
	/// * `world_pos` - The position in world coordinates where the joint will be created.
	/// * `lower_angle` - The lower angle limit in radians.
	/// * `upper_angle` - The upper angle limit in radians.
	/// * `max_motor_torque` - The maximum torque that can be applied to the joint to achieve the target speed.
	/// * `motor_speed` - The desired speed of the joint.
	///
	/// # Returns
	///
	/// * `MotorJoint` - The revolute joint definition.
	static JointDef* revolute(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float lowerAngle,
		float upperAngle,
		float maxMotorTorque,
		float motorSpeed);
	/// Creates a rope joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the connected bodies will collide with each other.
	/// * `body_a` - The first physics body to connect.
	/// * `body_b` - The second physics body to connect.
	/// * `anchor_a` - The position of the anchor point on the first body.
	/// * `anchor_b` - The position of the anchor point on the second body.
	/// * `max_length` - The maximum distance between the anchor points.
	///
	/// # Returns
	///
	/// * `Joint` - The rope joint definition.
	static JointDef* rope(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float maxLength);
	/// Creates a weld joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the bodies connected to the joint can collide with each other.
	/// * `body_a` - The first body to be connected by the joint.
	/// * `body_b` - The second body to be connected by the joint.
	/// * `world_pos` - The position in the world to connect the bodies together.
	/// * `frequency` - The frequency at which the joint should be stiff.
	/// * `damping` - The damping rate of the joint.
	///
	/// # Returns
	///
	/// * `Joint` - The newly created weld joint definition.
	static JointDef* weld(
		bool collision,
		string bodyA,
		string bodyB,
		Vec2 worldPos,
		float frequency,
		float damping);
	/// Creates a wheel joint definition.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the bodies connected to the joint can collide with each other.
	/// * `body_a` - The first body to be connected by the joint.
	/// * `body_b` - The second body to be connected by the joint.
	/// * `world_pos` - The position in the world to connect the bodies together.
	/// * `axis_angle` - The angle of the joint axis in radians.
	/// * `max_motor_torque` - The maximum torque the joint motor can exert.
	/// * `motor_speed` - The target speed of the joint motor.
	/// * `frequency` - The frequency at which the joint should be stiff.
	/// * `damping` - The damping rate of the joint.
	///
	/// # Returns
	///
	/// * `MotorJoint` - The newly created wheel joint definition.
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

/// A struct that can be used to connect physics bodies together.
interface object class Joint
{
	/// Creates a distance joint between two physics bodies.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the physics body connected to joint will collide with each other.
	/// * `body_a` - The first physics body to connect with the joint.
	/// * `body_b` - The second physics body to connect with the joint.
	/// * `anchor_a` - The position of the joint on the first physics body.
	/// * `anchor_b` - The position of the joint on the second physics body.
	/// * `frequency` - The frequency of the joint, in Hertz.
	/// * `damping` - The damping ratio of the joint.
	///
	/// # Returns
	///
	/// * `Joint` - The new distance joint.
	static Joint* distance(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float frequency,
		float damping);
	/// Creates a friction joint between two physics bodies.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the physics body connected to joint will collide with each other.
	/// * `body_a` - The first physics body to connect with the joint.
	/// * `body_b` - The second physics body to connect with the joint.
	/// * `world_pos` - The position of the joint in the game world.
	/// * `max_force` - The maximum force that can be applied to the joint.
	/// * `max_torque` - The maximum torque that can be applied to the joint.
	///
	/// # Returns
	///
	/// * `Joint` - The new friction joint.
	static Joint* friction(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float maxForce,
		float maxTorque);
	/// Creates a gear joint between two other joints.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the physics bodies connected to the joint can collide with each other.
	/// * `joint_a` - The first joint to connect with the gear joint.
	/// * `joint_b` - The second joint to connect with the gear joint.
	/// * `ratio` - The gear ratio.
	///
	/// # Returns
	///
	/// * `Joint` - The new gear joint.
	static Joint* gear(
		bool collision,
		Joint* jointA,
		Joint* jointB,
		float ratio);
	/// Creates a new spring joint between the two specified bodies.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether the connected bodies should collide with each other.
	/// * `body_a` - The first body connected to the joint.
	/// * `body_b` - The second body connected to the joint.
	/// * `linear_offset` - Position of body-B minus the position of body-A, in body-A's frame.
	/// * `angular_offset` - Angle of body-B minus angle of body-A.
	/// * `max_force` - The maximum force the joint can exert.
	/// * `max_torque` - The maximum torque the joint can exert.
	/// * `correction_factor` - Correction factor. 0.0 = no correction, 1.0 = full correction.
	///
	/// # Returns
	///
	/// * `Joint` - The created joint.
	static Joint* spring(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 linearOffset,
		float angularOffset,
		float maxForce,
		float maxTorque,
		float correctionFactor);
	/// Creates a new move joint for the specified body.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether the body can collide with other bodies.
	/// * `body` - The body that the joint is attached to.
	/// * `target_pos` - The target position that the body should move towards.
	/// * `max_force` - The maximum force the joint can exert.
	/// * `frequency` - Frequency ratio.
	/// * `damping` - Damping ratio.
	///
	/// # Returns
	///
	/// * `MoveJoint` - The created move joint.
	static MoveJoint* move @ moveTarget(
		bool collision,
		Body* body,
		Vec2 targetPos,
		float maxForce,
		float frequency,
		float damping);
	/// Creates a new prismatic joint between the two specified bodies.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether the connected bodies should collide with each other.
	/// * `body_a` - The first body connected to the joint.
	/// * `body_b` - The second body connected to the joint.
	/// * `world_pos` - The world position of the joint.
	/// * `axis_angle` - The axis angle of the joint.
	/// * `lower_translation` - Lower translation limit.
	/// * `upper_translation` - Upper translation limit.
	/// * `max_motor_force` - Maximum motor force.
	/// * `motor_speed` - Motor speed.
	///
	/// # Returns
	///
	/// * `MotorJoint` - The created prismatic joint.
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
	/// Creates a pulley joint between two physics bodies.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the connected bodies will collide with each other.
	/// * `body_a` - The first physics body to connect.
	/// * `body_b` - The second physics body to connect.
	/// * `anchor_a` - The position of the anchor point on the first body.
	/// * `anchor_b` - The position of the anchor point on the second body.
	/// * `ground_anchor_a` - The position of the ground anchor point on the first body in world coordinates.
	/// * `ground_anchor_b` - The position of the ground anchor point on the second body in world coordinates.
	/// * `ratio` - The pulley ratio.
	///
	/// # Returns
	///
	/// * `Joint` - The pulley joint.
	static Joint* pulley(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		Vec2 groundAnchorA,
		Vec2 groundAnchorB,
		float ratio);
	/// Creates a revolute joint between two physics bodies.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the connected bodies will collide with each other.
	/// * `body_a` - The first physics body to connect.
	/// * `body_b` - The second physics body to connect.
	/// * `world_pos` - The position in world coordinates where the joint will be created.
	/// * `lower_angle` - The lower angle limit in radians.
	/// * `upper_angle` - The upper angle limit in radians.
	/// * `max_motor_torque` - The maximum torque that can be applied to the joint to achieve the target speed.
	/// * `motor_speed` - The desired speed of the joint.
	///
	/// # Returns
	///
	/// * `MotorJoint` - The revolute joint.
	static MotorJoint* revolute(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float lowerAngle,
		float upperAngle,
		float maxMotorTorque,
		float motorSpeed);
	/// Creates a rope joint between two physics bodies.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the connected bodies will collide with each other.
	/// * `body_a` - The first physics body to connect.
	/// * `body_b` - The second physics body to connect.
	/// * `anchor_a` - The position of the anchor point on the first body.
	/// * `anchor_b` - The position of the anchor point on the second body.
	/// * `max_length` - The maximum distance between the anchor points.
	///
	/// # Returns
	///
	/// * `Joint` - The rope joint.
	static Joint* rope(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 anchorA,
		Vec2 anchorB,
		float maxLength);
	/// Creates a weld joint between two bodies.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the bodies connected to the joint can collide with each other.
	/// * `body_a` - The first body to be connected by the joint.
	/// * `body_b` - The second body to be connected by the joint.
	/// * `world_pos` - The position in the world to connect the bodies together.
	/// * `frequency` - The frequency at which the joint should be stiff.
	/// * `damping` - The damping rate of the joint.
	///
	/// # Returns
	///
	/// * `Joint` - The newly created weld joint.
	static Joint* weld(
		bool collision,
		Body* bodyA,
		Body* bodyB,
		Vec2 worldPos,
		float frequency,
		float damping);
	/// Creates a wheel joint between two bodies.
	///
	/// # Arguments
	///
	/// * `can_collide` - Whether or not the bodies connected to the joint can collide with each other.
	/// * `body_a` - The first body to be connected by the joint.
	/// * `body_b` - The second body to be connected by the joint.
	/// * `world_pos` - The position in the world to connect the bodies together.
	/// * `axis_angle` - The angle of the joint axis in radians.
	/// * `max_motor_torque` - The maximum torque the joint motor can exert.
	/// * `motor_speed` - The target speed of the joint motor.
	/// * `frequency` - The frequency at which the joint should be stiff.
	/// * `damping` - The damping rate of the joint.
	///
	/// # Returns
	///
	/// * `MotorJoint` - The newly created wheel joint.
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
	/// the physics world that the joint belongs to.
	readonly common PhysicsWorld* physicsWorld @ world;
	/// Destroys the joint and removes it from the physics simulation.
	void destroy();
	/// Creates a joint instance based on the given joint definition and item dictionary containing physics bodies to be connected by joint.
	///
	/// # Arguments
	///
	/// * `def` - The joint definition.
	/// * `item_dict` - The dictionary containing all the bodies and other required items.
	///
	/// # Returns
	///
	/// * `Joint` - The newly created joint.
	static Joint* create(JointDef* def, Dictionary* itemDict);
};

/// A type of joint that allows a physics body to move to a specific position.
object class MoveJoint : public IJoint
{
	/// the current position of the move joint in the game world.
	common Vec2 position;
};

/// A joint that applies a rotational or linear force to a physics body.
object class MotorJoint : public IJoint
{
	/// whether or not the motor joint is enabled.
	boolean bool enabled;
	/// the force applied to the motor joint.
	common float force;
	/// the speed of the motor joint.
	common float speed;
};

/// A interface for managing various game resources.
singleton struct Cache
{
	/// Loads a file into the cache with a blocking operation.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to load.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the file was loaded successfully, `false` otherwise.
	static bool load(string filename);
	/// Loads a file into the cache asynchronously.
	///
	/// # Arguments
	///
	/// * `filenames` - The name of the file(s) to load. This can be a single string or a vector of strings.
	/// * `handler` - A callback function that is invoked when the file is loaded.
	static void loadAsync(string filename, function<void(bool success)> handler);
	/// Updates the content of a file loaded in the cache.
	/// If the item of filename does not exist in the cache, a new file content will be added into the cache.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the file to update.
	/// * `content` - The new content for the file.
	static void update @ updateItem(string filename, string content);
	/// Updates the texture object of the specific filename loaded in the cache.
	/// If the texture object of filename does not exist in the cache, it will be added into the cache.
	///
	/// # Arguments
	///
	/// * `filename` - The name of the texture to update.
	/// * `texture` - The new texture object for the file.
	static void update @ updateTexture(string filename, Texture2D* texture);
	/// Unloads a resource from the cache.
	///
	/// # Arguments
	///
	/// * `name` - The type name of resource to unload, could be one of "Texture", "SVG", "Clip", "Frame", "Model", "Particle", "Shader", "Font", "Sound", "Spine". Or the name of the resource file to unload.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the resource was unloaded successfully, `false` otherwise.
	static bool unload @ unloadItemOrType(string name);
	/// Unloads all resources from the cache.
	static void unload();
	/// Removes all unused resources (not being referenced) from the cache.
	static void removeUnused();
	/// Removes all unused resources of the given type from the cache.
	///
	/// # Arguments
	///
	/// * `resource_type` - The type of resource to remove. This could be one of "Texture", "SVG", "Clip", "Frame", "Model", "Particle", "Shader", "Font", "Sound", "Spine".
	static void removeUnused @ removeUnusedByType(string typeName);
};

/// A interface of an audio player.
singleton class Audio
{
	/// Plays a sound effect and returns a handler for the audio.
	///
	/// # Arguments
	///
	/// * `filename` - The path to the sound effect file (must be a WAV file).
	/// * `loop` - Optional. Whether to loop the sound effect. Default is `false`.
	///
	/// # Returns
	///
	/// * `i32` - A handler for the audio that can be used to stop the sound effect.
	uint32_t play(string filename, bool looping);
	/// Stops a sound effect that is currently playing.
	///
	/// # Arguments
	///
	/// * `handler` - The handler for the audio that is returned by the `play` function.
	void stop(uint32_t handle);
	/// Plays a streaming audio file.
	///
	/// # Arguments
	///
	/// * `filename` - The path to the streaming audio file (can be OGG, WAV, MP3, or FLAC).
	/// * `loop` - Whether to loop the streaming audio.
	/// * `crossFadeTime` - The time (in seconds) to crossfade between the previous and new streaming audio.
	void playStream(string filename, bool looping, float crossFadeTime);
	/// Stops a streaming audio file that is currently playing.
	///
	/// # Arguments
	///
	/// * `fade_time` - The time (in seconds) to fade out the streaming audio.
	void stopStream(float fadeTime);
};

/// An interface for handling keyboard inputs.
singleton class Keyboard
{
	/// Checks whether a key is currently pressed.
	///
	/// # Arguments
	///
	/// * `name` - The name of the key to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the key is pressed, `false` otherwise.
	bool isKeyDown @ _is_key_down(string name);
	/// Checks whether a key is currently released.
	///
	/// # Arguments
	///
	/// * `name` - The name of the key to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the key is released, `false` otherwise.
	bool isKeyUp @ _is_key_up(string name);
	/// Checks whether a key is currently being pressed.
	///
	/// # Arguments
	///
	/// * `name` - The name of the key to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the key is being pressed, `false` otherwise.
	bool isKeyPressed @ _is_key_pressed(string name);
	/// Updates the input method editor (IME) position hint.
	///
	/// # Arguments
	///
	/// * `win_pos` - The position of the keyboard window.
	void updateIMEPosHint @ update_ime_pos_hint(Vec2 winPos);
};

/// An interface for handling mouse inputs.
singleton class Mouse {
	/// The position of the mouse in the visible window.
	/// You can use `Mouse::get_position() * App::get_device_pixel_ratio()` to get the coordinate in the game world.
	/// Then use `node.convertToNodeSpace()` to convert the world coordinate to the local coordinate of the node.
	///
	/// # Example
	///
	/// ```
	/// let worldPos = Mouse::get_position() * App::get_device_pixel_ratio();
	/// let nodePos = node.convert_to_node_space(&worldPos);
	/// ```
	static Vec2 getPosition();
	/// Whether the left mouse button is currently being pressed.
	static bool isLeftButtonPressed();
	/// Whether the right mouse button is currently being pressed.
	static bool isRightButtonPressed();
	/// Whether the middle mouse button is currently being pressed.
	static bool isMiddleButtonPressed();
	/// Gets the mouse wheel value.
	static Vec2 getWheel();
};

/// An interface for handling game controller inputs.
singleton class Controller
{
	/// Checks whether a button on the controller is currently pressed.
	///
	/// # Arguments
	///
	/// * `controller_id` - The ID of the controller to check. Starts from 0.
	/// * `name` - The name of the button to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the button is pressed, `false` otherwise.
	bool isButtonDown @ _is_button_down(int controllerId, string name);
	/// Checks whether a button on the controller is currently released.
	///
	/// # Arguments
	///
	/// * `controller_id` - The ID of the controller to check. Starts from 0.
	/// * `name` - The name of the button to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the button is released, `false` otherwise.
	bool isButtonUp @ _is_button_up(int controllerId, string name);
	/// Checks whether a button on the controller is currently being pressed.
	///
	/// # Arguments
	///
	/// * `controller_id` - The ID of the controller to check. Starts from 0.
	/// * `name` - The name of the button to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the button is being pressed, `false` otherwise.
	bool isButtonPressed @ _is_button_pressed(int controllerId, string name);
	/// Gets the value of an axis on the controller.
	///
	/// # Arguments
	///
	/// * `controller_id` - The ID of the controller to check. Starts from 0.
	/// * `name` - The name of the axis to check.
	///
	/// # Returns
	///
	/// * `f32` - The value of the axis. The value is between -1.0 and 1.0.
	float getAxis @ _get_axis(int controllerId, string name);
};

/// A struct used for Scalable Vector Graphics rendering.
object class SVGDef @ SVG
{
	/// the width of the SVG object.
	readonly common float width;
	/// the height of the SVG object.
	readonly common float height;
	/// Renders the SVG object, should be called every frame for the render result to appear.
	void render();
	/// Creates a new SVG object from the specified SVG file.
	///
	/// # Arguments
	///
	/// * `filename` - The path to the SVG format file.
	///
	/// # Returns
	///
	/// * `Svg` - The created SVG object.
	static optional SVGDef* from @ create(string filename);
};

value struct DBParams
{
	void add(Array* params);
	static DBParams create();
};

value struct DBRecord
{
	readonly boolean bool valid;
	bool read(Array* record);
};

value struct DBQuery
{
	void addWithParams(string sql, DBParams params);
	void add(string sql);
	static DBQuery create();
};

/// A struct that represents a database.
singleton class DB
{
	/// Checks whether a database exists.
	///
	/// # Arguments
	///
	/// * `db_name` - The name of the database to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the database exists, `false` otherwise.
	bool existDB @ exist_db(string dbName);
	/// Checks whether a table exists in the database.
	///
	/// # Arguments
	///
	/// * `table_name` - The name of the table to check.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the table exists, `false` otherwise.
	bool exist(string tableName);
	/// Checks whether a table exists in the database.
	///
	/// # Arguments
	///
	/// * `table_name` - The name of the table to check.
	/// * `schema` - Optional. The name of the schema to check in.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the table exists, `false` otherwise.
	bool exist @ existSchema(string tableName, string schema);
	/// Executes an SQL statement and returns the number of rows affected.
	///
	/// # Arguments
	///
	/// * `sql` - The SQL statement to execute.
	///
	/// # Returns
	///
	/// * `i32` - The number of rows affected by the statement.
	int exec(string sql);
	/// Executes a list of SQL statements as a single transaction.
	///
	/// # Arguments
	///
	/// * `query` - A list of SQL statements to execute.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the transaction was successful, `false` otherwise.
	outside bool DB_Transaction @ transaction(DBQuery query);
	/// Executes a list of SQL statements as a single transaction asynchronously.
	///
	/// # Arguments
	///
	/// * `sqls` - A list of SQL statements to execute.
	/// * `callback` - A callback function that is invoked when the transaction is executed, receiving the result of the transaction.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the transaction was successful, `false` otherwise.
	outside void DB_TransactionAsync @ transactionAsync(DBQuery query, function<void(bool result)> callback);
	/// Executes an SQL query and returns the results as a list of rows.
	///
	/// # Arguments
	///
	/// * `sql` - The SQL statement to execute.
	/// * `with_column` - Whether to include column names in the result.
	///
	/// # Returns
	///
	/// * `DBRecord` - A list of rows returned by the query.
	outside DBRecord DB_Query @ query(string sql, bool withColumns);
	/// Executes an SQL query and returns the results as a list of rows.
	///
	/// # Arguments
	///
	/// * `sql` - The SQL statement to execute.
	/// * `params` - A list of values to substitute into the SQL statement.
	/// * `with_column` - Whether to include column names in the result.
	///
	/// # Returns
	///
	/// * `DBRecord` - A list of rows returned by the query.
	outside DBRecord DB_QueryWithParams @ queryWithParams(string sql, Array* params, bool withColumns);
	/// Inserts a row of data into a table within a transaction.
	///
	/// # Arguments
	///
	/// * `table_name` - The name of the table to insert into.
	/// * `values` - The values to insert into the table.
	///
	/// # Returns
	///
	/// * `bool` - `true` if the insertion was successful, `false` otherwise.
	outside void DB_Insert @ insert(string tableName, DBParams values);
	/// Executes an SQL statement and returns the number of rows affected.
	///
	/// # Arguments
	///
	/// * `sql` - The SQL statement to execute.
	/// * `values` - Lists of values to substitute into the SQL statement.
	///
	/// # Returns
	///
	/// * `i32` - The number of rows affected by the statement.
	outside int32_t DB_ExecWithRecords @ execWithRecords(string sql, DBParams values);
	/// Executes an SQL query asynchronously and returns the results as a list of rows.
	///
	/// # Arguments
	///
	/// * `sql` - The SQL statement to execute.
	/// * `params` - Optional. A list of values to substitute into the SQL statement.
	/// * `with_column` - Optional. Whether to include column names in the result. Default is `false`.
	/// * `callback` - A callback function that is invoked when the query is executed, receiving the results as a list of rows.
	outside void DB_QueryWithParamsAsync @ queryWithParamsAsync(string sql, Array* params, bool withColumns, function<void(DBRecord result)> callback);
	/// Inserts a row of data into a table within a transaction asynchronously.
	///
	/// # Arguments
	///
	/// * `table_name` - The name of the table to insert into.
	/// * `values` - The values to insert into the table.
	/// * `callback` - A callback function that is invoked when the insertion is executed, receiving the result of the insertion.
	outside void DB_InsertAsync @ insertAsync(string tableName, DBParams values, function<void(bool result)> callback);
	/// Executes an SQL statement with a list of values within a transaction asynchronously and returns the number of rows affected.
	///
	/// # Arguments
	///
	/// * `sql` - The SQL statement to execute.
	/// * `values` - A list of values to substitute into the SQL statement.
	/// * `callback` - A callback function that is invoked when the statement is executed, recieving the number of rows affected.
	outside void DB_ExecAsync @ execAsync(string sql, DBParams values, function<void(int64_t rowChanges)> callback);
};

/// A simple reinforcement learning framework that can be used to learn optimal policies for Markov decision processes using Q-learning. Q-learning is a model-free reinforcement learning algorithm that learns an optimal action-value function from experience by repeatedly updating estimates of the Q-value of state-action pairs.
object class MLQLearner @ QLearner
{
	/// Updates Q-value for a state-action pair based on received reward.
	///
	/// # Arguments
	///
	/// * `state` - An integer representing the state.
	/// * `action` - An integer representing the action.
	/// * `reward` - A number representing the reward received for the action in the state.
	void update(MLQState state, MLQAction action, double reward);
	/// Returns the best action for a given state based on the current Q-values.
	///
	/// # Arguments
	///
	/// * `state` - The current state.
	///
	/// # Returns
	///
	/// * `i32` - The action with the highest Q-value for the given state.
	uint32_t getBestAction(MLQState state);
	/// Visits all state-action pairs and calls the provided handler function for each pair.
	///
	/// # Arguments
	///
	/// * `handler` - A function that is called for each state-action pair.
	outside void ML_QLearnerVisitStateActionQ @ visitMatrix(function<void(MLQState state, MLQAction action, double q)> handler);
	/// Constructs a state from given hints and condition values.
	///
	/// # Arguments
	///
	/// * `hints` - A vector of integers representing the byte length of provided values.
	/// * `values` - The condition values as discrete values.
	///
	/// # Returns
	///
	/// * `i64` - The packed state value.
	static MLQState pack(VecUint32 hints, VecUint32 values);
	/// Deconstructs a state from given hints to get condition values.
	///
	/// # Arguments
	///
	/// * `hints` - A vector of integers representing the byte length of provided values.
	/// * `state` - The state integer to unpack.
	///
	/// # Returns
	///
	/// * `Vec<i32>` - The condition values as discrete values.
	static VecUint32 unpack(VecUint32 hints, MLQState state);
	/// Creates a new QLearner object with optional parameters for gamma, alpha, and maxQ.
	///
	/// # Arguments
	///
	/// * `gamma` - The discount factor for future rewards.
	/// * `alpha` - The learning rate for updating Q-values.
	/// * `maxQ` - The maximum Q-value. Defaults to 100.0.
	///
	/// # Returns
	///
	/// * `QLearner` - The newly created QLearner object.
	static QLearner* create(double gamma, double alpha, double maxQ);
};

/// An interface for machine learning algorithms.
singleton class C45
{
	/// A function that takes CSV data as input and applies the C4.5 machine learning algorithm to build a decision tree model asynchronously.
	/// C4.5 is a decision tree algorithm that uses information gain to select the best attribute to split the data at each node of the tree. The resulting decision tree can be used to make predictions on new data.
	///
	/// # Arguments
	///
	/// * `csv_data` - The CSV training data for building the decision tree using delimiter `,`.
	/// * `max_depth` - The maximum depth of the generated decision tree. Set to 0 to prevent limiting the generated tree depth.
	/// * `handler` - The callback function to be called for each node of the generated decision tree.
	///     * `depth` - The learning accuracy value or the depth of the current node in the decision tree.
	///     * `name` - The name of the attribute used for splitting the data at the current node.
	///     * `op` - The comparison operator used for splitting the data at the current node.
	///     * `value` - The value used for splitting the data at the current node.
	static outside void MLBuildDecisionTreeAsync @ buildDecisionTreeAsync(string data, int maxDepth, function<void(double depth, string name, string op, string value)> treeVisitor);
};

/// An HTTP client interface.
singleton class HttpClient
{
	/// Sends a POST request to the specified URL and returns the response body.
	///
	/// # Arguments
	///
	/// * `url` - The URL to send the request to.
	/// * `json` - The JSON data to send in the request body.
	/// * `timeout` - The timeout in seconds for the request.
	/// * `callback` - A callback function that is called when the request is complete. The function receives the response body as a parameter.
	void postAsync(string url, string json, float timeout, function<void(OptString body)> callback);
	/// Sends a POST request to the specified URL with custom headers and returns the response body.
	///
	/// # Arguments
	///
	/// * `url` - The URL to send the request to.
	/// * `headers` - A vector of headers to include in the request. Each header should be in the format `key: value`.
	/// * `json` - The JSON data to send in the request body.
	/// * `timeout` - The timeout in seconds for the request.
	/// * `callback` - A callback function that is called when the request is complete. The function receives the response body as a parameter.
	void postAsync @ postWithHeadersAsync(string url, VecStr headers, string json, float timeout, function<void(OptString body)> callback);
	/// Sends a POST request to the specified URL with custom headers and returns the response body.
	///
	/// # Arguments
	///
	/// * `url` - The URL to send the request to.
	/// * `headers` - A vector of headers to include in the request. Each header should be in the format `key: value`.
	/// * `json` - The JSON data to send in the request body.
	/// * `timeout` - The timeout in seconds for the request.
	/// * `part_callback` - A callback function that is called periodically to get part of the response content. Returns `true` to stop the request.
	/// * `callback` - A callback function that is called when the request is complete. The function receives the response body as a parameter.
	void postAsync @ postWithHeadersPartAsync(string url, VecStr headers, string json, float timeout, function<def_false bool(string body)> partCallback, function<void(OptString body)> callback);
	/// Sends a GET request to the specified URL and returns the response body.
	///
	/// # Arguments
	///
	/// * `url` - The URL to send the request to.
	/// * `timeout` - The timeout in seconds for the request.
	/// * `callback` - A callback function that is called when the request is complete. The function receives the response body as a parameter.
	void getAsync(string url, float timeout, function<void(OptString body)> callback);
	/// Downloads a file asynchronously from the specified URL and saves it to the specified path.
	///
	/// # Arguments
	///
	/// * `url` - The URL of the file to download.
	/// * `full_path` - The full path where the downloaded file should be saved.
	/// * `timeout` - The timeout in seconds for the request.
	/// * `progress` - A callback function that is called periodically to report the download progress.
	///   The function receives three parameters: `interrupted` (a boolean value indicating whether the download was interrupted), `current` (the number of bytes downloaded so far) and `total` (the total number of bytes to be downloaded).
	void downloadAsync(string url, string fullPath, float timeout, function<def_true bool(bool interrupted, uint64_t current, uint64_t total)> progress);
};

namespace Platformer {

/// A struct to specifies how a bullet object should interact with other game objects or units based on their relationship.
value class TargetAllow
{
	/// whether the bullet object can collide with terrain.
	boolean bool terrainAllowed;
	/// Allows or disallows the bullet object to interact with a game object or unit, based on their relationship.
	///
	/// # Arguments
	///
	/// * `relation` - The relationship between the bullet object and the other game object or unit.
	/// * `allow` - Whether the bullet object should be allowed to interact.
	void allow(Platformer::Relation relation, bool allow);
	/// Determines whether the bullet object is allowed to interact with a game object or unit, based on their relationship.
	///
	/// # Arguments
	///
	/// * `relation` - The relationship between the bullet object and the other game object or unit.
	///
	/// # Returns
	///
	/// * `bool` - Whether the bullet object is allowed to interact.
	bool isAllow(Platformer::Relation relation);
	/// Converts the object to a value that can be used for interaction settings.
	///
	/// # Returns
	///
	/// * `usize` - The value that can be used for interaction settings.
	uint32_t toValue();
	/// Creates a new TargetAllow object with default settings.
	static Platformer::TargetAllow create();
	/// Creates a new TargetAllow object with the specified value.
	///
	/// # Arguments
	///
	/// * `value` - The value to use for the new TargetAllow object.
	static Platformer::TargetAllow create @ createValue(uint32_t value);
};

/// Represents a definition for a visual component of a game bullet or other visual item.
object class Face
{
	/// Adds a child `Face` definition to it.
	///
	/// # Arguments
	///
	/// * `face` - The child `Face` to add.
	void addChild(Platformer::Face* face);
	/// Returns a node that can be added to a scene tree for rendering.
	///
	/// # Returns
	///
	/// * `Node` - The `Node` representing this `Face`.
	Node* toNode();
	/// Creates a new `Face` definition using the specified attributes.
	///
	/// # Arguments
	///
	/// * `face_str` - A string for creating the `Face` component. Could be 'Image/file.png' and 'Image/items.clip|itemA'.
	/// * `point` - The position of the `Face` component.
	/// * `scale` - The scale of the `Face` component.
	/// * `angle` - The angle of the `Face` component.
	///
	/// # Returns
	///
	/// * `Face` - The new `Face` component.
	static Face* create(string faceStr, Vec2 point, float scale, float angle);
	/// Creates a new `Face` definition using the specified attributes.
	///
	/// # Arguments
	///
	/// * `create_func` - A function that returns a `Node` representing the `Face` component.
	/// * `point` - The position of the `Face` component.
	/// * `scale` - The scale of the `Face` component.
	/// * `angle` - The angle of the `Face` component.
	///
	/// # Returns
	///
	/// * `Face` - The new `Face` component.
	static Face* create @ createFunc(function<Node*()> createFunc, Vec2 point, float scale, float angle);
};

/// A struct type that specifies the properties and behaviors of a bullet object in the game.
object class BulletDef
{
	/// the tag for the bullet object.
	string tag;
	/// the effect that occurs when the bullet object ends its life.
	string endEffect;
	/// the amount of time in seconds that the bullet object remains active.
	float lifeTime;
	/// the radius of the bullet object's damage area.
	float damageRadius;
	/// whether the bullet object should be fixed for high speeds.
	boolean bool highSpeedFix;
	/// the gravity vector that applies to the bullet object.
	common Vec2 gravity;
	/// the visual item of the bullet object.
	common Platformer::Face* face;
	/// the physics body definition for the bullet object.
	readonly common BodyDef* bodyDef;
	/// the velocity vector of the bullet object.
	readonly common Vec2 velocity;
	/// Sets the bullet object's physics body as a circle.
	///
	/// # Arguments
	///
	/// * `radius` - The radius of the circle.
	void setAsCircle(float radius);
	/// Sets the velocity of the bullet object.
	///
	/// # Arguments
	///
	/// * `angle` - The angle of the velocity in degrees.
	/// * `speed` - The speed of the velocity.
	void setVelocity(float angle, float speed);
	/// Creates a new bullet object definition with default settings.
	///
	/// # Returns
	///
	/// * `BulletDef` - The new bullet object definition.
	static BulletDef* create();
};

/// A struct that defines the properties and behavior of a bullet object instance in the game.
object class Bullet : public IBody
{
	/// the value from a `Platformer.TargetAllow` object for the bullet object.
	common uint32_t targetAllow;
	/// whether the bullet object is facing right.
	readonly boolean bool faceRight;
	/// whether the bullet object should stop on impact.
	boolean bool hitStop;
	/// the `Unit` object that fired the bullet.
	readonly common Platformer::Unit* emitter;
	/// the `BulletDef` object that defines the bullet's properties and behavior.
	readonly common Platformer::BulletDef* bulletDef;
	/// the `Node` object that appears as the bullet's visual item.
	common Node* face;
	/// Destroys the bullet object instance.
	void destroy();
	/// A method that creates a new `Bullet` object instance with the specified `BulletDef` and `Unit` objects.
	///
	/// # Arguments
	///
	/// * `def` - The `BulletDef` object that defines the bullet's properties and behavior.
	/// * `owner` - The `Unit` object that fired the bullet.
	///
	/// # Returns
	///
	/// * `Bullet` - The new `Bullet` object instance.
	static Bullet* create(Platformer::BulletDef* def, Platformer::Unit* owner);
};

/// A struct represents a visual effect object like Particle, Frame Animation or just a Sprite.
object class Visual : public INode
{
	/// whether the visual effect is currently playing or not.
	readonly boolean bool playing;
	/// Starts playing the visual effect.
	void start();
	/// Stops playing the visual effect.
	void stop();
	/// Automatically removes the visual effect from the game world when it finishes playing.
	///
	/// # Returns
	///
	/// * `Visual` - The same `Visual` object that was passed in as a parameter.
	Platformer::Visual* autoRemove();
	/// Creates a new `Visual` object with the specified name.
	///
	/// # Arguments
	///
	/// * `name` - The name of the new `Visual` object. Could be a particle file, a frame animation file or an image file.
	///
	/// # Returns
	///
	/// * `Visual` - The new `Visual` object.
	static Visual* create(string name);
};

namespace Behavior {

/// A blackboard object that can be used to store data for behavior tree nodes.
class Blackboard
{
	/// the time since the last frame update in seconds.
	readonly common double deltaTime;
	/// the unit that the AI agent belongs to.
	readonly common Platformer::Unit* owner;
};

/// A behavior tree framework for creating game AI structures.
object class Leaf @ Tree
{
	/// Creates a new sequence node that executes an array of child nodes in order.
	///
	/// # Arguments
	///
	/// * `nodes` - A vector of child nodes.
	///
	/// # Returns
	///
	/// * `Leaf` - A new sequence node.
	static outside Platformer::Behavior::Leaf* BSeq @ seq(VecBTree nodes);
	/// Creates a new selector node that selects and executes one of its child nodes that will succeed.
	///
	/// # Arguments
	///
	/// * `nodes` - A vector of child nodes.
	///
	/// # Returns
	///
	/// * `Leaf` - A new selector node.
	static outside Platformer::Behavior::Leaf* BSel @ sel(VecBTree nodes);
	/// Creates a new condition node that executes a check handler function when executed.
	///
	/// # Arguments
	///
	/// * `name` - The name of the condition.
	/// * `check` - A function that takes a blackboard object and returns a boolean value.
	///
	/// # Returns
	///
	/// * `Leaf` - A new condition node.
	static outside Platformer::Behavior::Leaf* BCon @ con(string name, function<def_false bool(Platformer::Behavior::Blackboard blackboard)> handler);
	/// Creates a new action node that executes an action when executed.
	/// This node will block the execution until the action finishes.
	///
	/// # Arguments
	///
	/// * `action_name` - The name of the action to execute.
	///
	/// # Returns
	///
	/// * `Leaf` - A new action node.
	static outside Platformer::Behavior::Leaf* BAct @ act(string action_name);
	/// Creates a new command node that executes a command when executed.
	/// This node will return right after the action starts.
	///
	/// # Arguments
	///
	/// * `action_name` - The name of the command to execute.
	///
	/// # Returns
	///
	/// * `Leaf` - A new command node.
	static outside Platformer::Behavior::Leaf* BCommand @ command(string action_name);
	/// Creates a new wait node that waits for a specified duration when executed.
	///
	/// # Arguments
	///
	/// * `duration` - The duration to wait in seconds.
	///
	/// # Returns
	///
	/// * A new wait node of type `Leaf`.
	static outside Platformer::Behavior::Leaf* BWait @ wait(double duration);
	/// Creates a new countdown node that executes a child node continuously until a timer runs out.
	///
	/// # Arguments
	///
	/// * `time` - The time limit in seconds.
	/// * `node` - The child node to execute.
	///
	/// # Returns
	///
	/// * A new countdown node of type `Leaf`.
	static outside Platformer::Behavior::Leaf* BCountdown @ countdown(double time, Platformer::Behavior::Leaf* node);
	/// Creates a new timeout node that executes a child node until a timer runs out.
	///
	/// # Arguments
	///
	/// * `time` - The time limit in seconds.
	/// * `node` - The child node to execute.
	///
	/// # Returns
	///
	/// * A new timeout node of type `Leaf`.
	static outside Platformer::Behavior::Leaf* BTimeout @ timeout(double time, Platformer::Behavior::Leaf* node);
	/// Creates a new repeat node that executes a child node a specified number of times.
	///
	/// # Arguments
	///
	/// * `times` - The number of times to execute the child node.
	/// * `node` - The child node to execute.
	///
	/// # Returns
	///
	/// * A new repeat node of type `Leaf`.
	static outside Platformer::Behavior::Leaf* BRepeat @ repeat(int times, Platformer::Behavior::Leaf* node);
	/// Creates a new repeat node that executes a child node repeatedly.
	///
	/// # Arguments
	///
	/// * `node` - The child node to execute.
	///
	/// # Returns
	///
	/// * A new repeat node of type `Leaf`.
	static outside Platformer::Behavior::Leaf* BRepeat @ repeatForever(Platformer::Behavior::Leaf* node);
	/// Creates a new retry node that executes a child node repeatedly until it succeeds or a maximum number of retries is reached.
	///
	/// # Arguments
	///
	/// * `times` - The maximum number of retries.
	/// * `node` - The child node to execute.
	///
	/// # Returns
	///
	/// * A new retry node of type `Leaf`.
	static outside Platformer::Behavior::Leaf* BRetry @ retry(int times, Platformer::Behavior::Leaf* node);
	/// Creates a new retry node that executes a child node repeatedly until it succeeds.
	///
	/// # Arguments
	///
	/// * `node` - The child node to execute.
	///
	/// # Returns
	///
	/// * A new retry node of type `Leaf`.
	static outside Platformer::Behavior::Leaf* BRetry @ retryUntilPass(Platformer::Behavior::Leaf* node);
};

}

namespace Decision {

/// A decision tree framework for creating game AI structures.
object class Leaf @ Tree
{
	/// Creates a selector node with the specified child nodes.
	///
	/// A selector node will go through the child nodes until one succeeds.
	///
	/// # Arguments
	///
	/// * `nodes` - An array of `Leaf` nodes.
	///
	/// # Returns
	///
	/// * A `Leaf` node that represents a selector.
	static outside Platformer::Decision::Leaf* DSel @ sel(VecDTree nodes);
	/// Creates a sequence node with the specified child nodes.
	///
	/// A sequence node will go through the child nodes until all nodes succeed.
	///
	/// # Arguments
	///
	/// * `nodes` - An array of `Leaf` nodes.
	///
	/// # Returns
	///
	/// * A `Leaf` node that represents a sequence.
	static outside Platformer::Decision::Leaf* DSeq @ seq(VecDTree nodes);
	/// Creates a condition node with the specified name and handler function.
	///
	/// # Arguments
	///
	/// * `name` - The name of the condition.
	/// * `check` - The check function that takes a `Unit` parameter and returns a boolean result.
	///
	/// # Returns
	///
	/// * A `Leaf` node that represents a condition check.
	static outside Platformer::Decision::Leaf* DCon @ con(string name, function<def_false bool(Platformer::Unit* unit)> handler);
	/// Creates an action node with the specified action name.
	///
	/// # Arguments
	///
	/// * `action_name` - The name of the action to perform.
	///
	/// # Returns
	///
	/// * A `Leaf` node that represents an action.
	static outside Platformer::Decision::Leaf* DAct @ act(string action_name);
	/// Creates an action node with the specified handler function.
	///
	/// # Arguments
	///
	/// * `handler` - The handler function that takes a `Unit` parameter which is the running AI agent and returns an action.
	///
	/// # Returns
	///
	/// * A `Leaf` node that represents an action.
	static outside Platformer::Decision::Leaf* DAct @ actDynamic(function<string(Platformer::Unit* unit)> handler);
	/// Creates a leaf node that represents accepting the current behavior tree.
	///
	/// Always get success result from this node.
	///
	/// # Returns
	///
	/// * A `Leaf` node.
	static outside Platformer::Decision::Leaf* DAccept @ accept();
	/// Creates a leaf node that represents rejecting the current behavior tree.
	///
	/// Always get failure result from this node.
	///
	/// # Returns
	///
	/// * A `Leaf` node.
	static outside Platformer::Decision::Leaf* DReject @ reject();
	/// Creates a leaf node with the specified behavior tree as its root.
	///
	/// It is possible to include a Behavior Tree as a node in a Decision Tree by using the Behave() function. This allows the AI to use a combination of decision-making and behavior execution to achieve its goals.
	///
	/// # Arguments
	///
	/// * `name` - The name of the behavior tree.
	/// * `root` - The root node of the behavior tree.
	///
	/// # Returns
	///
	/// * A `Leaf` node.
	static outside Platformer::Decision::Leaf* DBehave @ behave(string name, Platformer::Behavior::Leaf* root);
};

/// The interface to retrieve information while executing the decision tree.
singleton class AI
{
	/// Gets an array of units in detection range that have the specified relation to current AI agent.
	///
	/// # Arguments
	///
	/// * `relation` - The relation to filter the units by.
	///
	/// # Returns
	///
	/// * An array of units with the specified relation.
	Array* getUnitsByRelation(Platformer::Relation relation);
	/// Gets an array of units that the AI has detected.
	///
	/// # Returns
	///
	/// * An array of detected units.
	Array* getDetectedUnits();
	/// Gets an array of bodies that the AI has detected.
	///
	/// # Returns
	///
	/// * An array of detected bodies.
	Array* getDetectedBodies();
	/// Gets the nearest unit that has the specified relation to the AI.
	///
	/// # Arguments
	///
	/// * `relation` - The relation to filter the units by.
	///
	/// # Returns
	///
	/// * The nearest unit with the specified relation.
	Platformer::Unit* getNearestUnit(Platformer::Relation relation);
	/// Gets the distance to the nearest unit that has the specified relation to the AI agent.
	///
	/// # Arguments
	///
	/// * `relation` - The relation to filter the units by.
	///
	/// # Returns
	///
	/// * The distance to the nearest unit with the specified relation.
	float getNearestUnitDistance(Platformer::Relation relation);
	/// Gets an array of units that are within attack range.
	///
	/// # Returns
	///
	/// * An array of units in attack range.
	Array* getUnitsInAttackRange();
	/// Gets an array of bodies that are within attack range.
	///
	/// # Returns
	///
	/// * An array of bodies in attack range.
	Array* getBodiesInAttackRange();
};

}

object class WasmActionUpdate @ ActionUpdate
{
	static WasmActionUpdate* create(function<def_true bool(Platformer::Unit* owner, Platformer::UnitAction action, float deltaTime)> update);
};

/// A struct that represents an action that can be performed by a "Unit".
class UnitAction
{
	/// the length of the reaction time for the "UnitAction", in seconds.
	/// The reaction time will affect the AI check cycling time.
	float reaction;
	/// the length of the recovery time for the "UnitAction", in seconds.
	/// The recovery time will mainly affect how long the `Playable` animation model will do transitions between animations played by different actions.
	float recovery;
	/// the name of the "UnitAction".
	readonly common string name;
	/// whether the "Unit" is currently performing the "UnitAction" or not.
	readonly boolean bool doing;
	/// the "Unit" that owns this "UnitAction".
	readonly common Platformer::Unit* owner;
	/// the elapsed time since the "UnitAction" was started, in seconds.
	readonly common float elapsedTime;
	/// Removes all "UnitAction" objects from the "UnitActionClass".
	static void clear();
	/// Adds a new "UnitAction" to the "UnitActionClass" with the specified name and parameters.
	///
	/// # Arguments
	///
	/// * `name` - The name of the "UnitAction".
	/// * `priority` - The priority level for the "UnitAction". `UnitAction` with higher priority (larger number) will replace the running lower priority `UnitAction`. If performing `UnitAction` having the same priority with the running `UnitAction` and the `UnitAction` to perform having the param 'queued' to be true, the running `UnitAction` won't be replaced.
	/// * `reaction` - The length of the reaction time for the "UnitAction", in seconds. The reaction time will affect the AI check cycling time. Set to 0.0 to make AI check run in every update.
	/// * `recovery` - The length of the recovery time for the "UnitAction", in seconds. The recovery time will mainly affect how long the `Playable` animation model will do transitions between animations played by different actions.
	/// * `queued` - Whether the "UnitAction" is currently queued or not. The queued "UnitAction" won't replace the running "UnitAction" with a same priority.
	/// * `available` - A function that takes a `Unit` object and a `UnitAction` object and returns a boolean value indicating whether the "UnitAction" is available to be performed.
	/// * `create` - A function that takes a `Unit` object and a `UnitAction` object and returns a `WasmActionUpdate` object that contains the update function for the "UnitAction".
	/// * `stop` - A function that takes a `Unit` object and a `UnitAction` object and stops the "UnitAction".
	static outside void Platformer_UnitAction_Add @ add(
		string name, int priority, float reaction, float recovery, bool queued,
		function<def_false bool(Platformer::Unit* owner, Platformer::UnitAction action)> available,
		function<Platformer::WasmActionUpdate*(Platformer::Unit* owner, Platformer::UnitAction action)> create,
		function<void(Platformer::Unit* owner, Platformer::UnitAction action)> stop);
};

/// A struct represents a character or other interactive item in a game scene.
object class Unit : public IBody
{
	/// the property that references a "Playable" object for managing the animation state and playback of the "Unit".
	common Playable* playable;
	/// the property that specifies the maximum distance at which the "Unit" can detect other "Unit" or objects.
	common float detectDistance;
	/// the property that specifies the size of the attack range for the "Unit".
	common Size attackRange;
	/// the boolean property that specifies whether the "Unit" is facing right or not.
	boolean bool faceRight;
	/// the boolean property that specifies whether the "Unit" is receiving a trace of the decision tree for debugging purposes.
	boolean bool receivingDecisionTrace;
	/// the string property that specifies the decision tree to use for the "Unit's" AI behavior.
	/// the decision tree object will be searched in The singleton instance Data.store.
	common string decisionTreeName @ decisionTree;
	/// whether the "Unit" is currently on a surface or not.
	readonly boolean bool onSurface;
	/// the "Sensor" object for detecting ground surfaces.
	readonly common Sensor* groundSensor;
	/// the "Sensor" object for detecting other "Unit" objects or physics bodies in the game world.
	readonly common Sensor* detectSensor;
	/// the "Sensor" object for detecting other "Unit" objects within the attack senser area.
	readonly common Sensor* attackSensor;
	/// the "Dictionary" object for defining the properties and behavior of the "Unit".
	readonly common Dictionary* unitDef;
	/// the property that specifies the current action being performed by the "Unit".
	readonly common Platformer::UnitAction currentAction;
	/// the width of the "Unit".
	readonly common float width;
	/// the height of the "Unit".
	readonly common float height;
	/// the "Entity" object for representing the "Unit" in the ECS system.
	readonly common Entity* entity;
	/// Adds a new `UnitAction` to the `Unit` with the specified name, and returns the new `UnitAction`.
	///
	/// # Arguments
	///
	/// * `name` - The name of the new `UnitAction`.
	///
	/// # Returns
	///
	/// * The newly created `UnitAction`.
	Platformer::UnitAction attachAction(string name);
	/// Removes the `UnitAction` with the specified name from the `Unit`.
	///
	/// # Arguments
	///
	/// * `name` - The name of the `UnitAction` to remove.
	void removeAction(string name);
	/// Removes all "UnitAction" objects from the "Unit".
	void removeAllActions();
	/// Returns the `UnitAction` with the specified name, or `None` if the `UnitAction` does not exist.
	///
	/// # Arguments
	///
	/// * `name` - The name of the `UnitAction` to retrieve.
	///
	/// # Returns
	///
	/// * The `UnitAction` with the specified name, or `None`.
	optional Platformer::UnitAction getAction(string name);
	/// Calls the specified function for each `UnitAction` attached to the `Unit`.
	///
	/// # Arguments
	///
	/// * `visitorFunc` - A function to call for each `UnitAction`.
	void eachAction(function<void(Platformer::UnitAction action)> visitorFunc);
	/// Starts the `UnitAction` with the specified name, and returns true if the `UnitAction` was started successfully.
	///
	/// # Arguments
	///
	/// * `name` - The name of the `UnitAction` to start.
	///
	/// # Returns
	///
	/// * `true` if the `UnitAction` was started successfully, `false` otherwise.
	bool start(string name);
	/// Stops the currently running "UnitAction".
	void stop();
	/// Returns true if the `Unit` is currently performing the specified `UnitAction`, false otherwise.
	///
	/// # Arguments
	///
	/// * `name` - The name of the `UnitAction` to check.
	///
	/// # Returns
	///
	/// * `true` if the `Unit` is currently performing the specified `UnitAction`, `false` otherwise.
	bool isDoing(string name);
	/// A method that creates a new `Unit` object.
	///
	/// # Arguments
	///
	/// * `unit_def` - A `Dictionary` object that defines the properties and behavior of the `Unit`.
	/// * `physics_world` - A `PhysicsWorld` object that represents the physics simulation world.
	/// * `entity` - An `Entity` object that represents the `Unit` in ECS system.
	/// * `pos` - A `Vec2` object that specifies the initial position of the `Unit`.
	/// * `rot` - A number that specifies the initial rotation of the `Unit`.
	///
	/// # Returns
	///
	/// * The newly created `Unit` object.
	static Unit* create(Dictionary* unitDef, PhysicsWorld* physicsWorld, Entity* entity, Vec2 pos, float rot);
	/// A method that creates a new `Unit` object.
	///
	/// # Arguments
	///
	/// * `unit_def_name` - A string that specifies the name of the `Unit` definition to retrieve from `Data.store` table.
	/// * `physics_world_name` - A string that specifies the name of the `PhysicsWorld` object to retrieve from `Data.store` table.
	/// * `entity` - An `Entity` object that represents the `Unit` in ECS system.
	/// * `pos` - A `Vec2` object that specifies the initial position of the `Unit`.
	/// * `rot` - An optional number that specifies the initial rotation of the `Unit` (default is 0.0).
	///
	/// # Returns
	///
	/// * The newly created `Unit` object.
	static Unit* create @ createStore(string unitDefName, string physicsWorldName, Entity* entity, Vec2 pos, float rot);
};

/// A platform camera for 2D platformer games that can track a game unit's movement and keep it within the camera's view.
object class PlatformCamera : public ICamera
{
	/// The camera's position.
	common Vec2 position;
	/// The camera's rotation in degrees.
	common float rotation;
	/// The camera's zoom factor, 1.0 means the normal size, 2.0 mean zoom to doubled size.
	common float zoom;
	/// The rectangular area within which the camera is allowed to view.
	common Rect boundary;
	/// the ratio at which the camera should move to keep up with the target's position.
	/// For example, set to `Vec2(1.0, 1.0)`, then the camera will keep up to the target's position right away.
	/// Set to Vec2(0.5, 0.5) or smaller value, then the camera will move halfway to the target's position each frame, resulting in a smooth and gradual movement.
	common Vec2 followRatio;
	/// the offset at which the camera should follow the target.
	common Vec2 followOffset;
	/// the game unit that the camera should track.
	optional common Node* followTarget;
	/// Removes the target that the camera is following.
	outside void PlatformCamera_SetFollowTargetNullptr @ set_follow_target_null();
	/// Creates a new instance of `PlatformCamera`.
	///
	/// # Arguments
	///
	/// * `name` - An optional string that specifies the name of the new instance. Default is an empty string.
	///
	/// # Returns
	///
	/// * A new `PlatformCamera` instance.
	static PlatformCamera* create(string name);
};

/// A struct representing a 2D platformer game world with physics simulations.
object class PlatformWorld : public IPhysicsWorld
{
	/// the camera used to control the view of the game world.
	readonly common Platformer::PlatformCamera* camera;
	/// Moves a child node to a new order for a different layer.
	///
	/// # Arguments
	///
	/// * `child` - The child node to be moved.
	/// * `new_order` - The new order of the child node.
	void moveChild(Node* child, int newOrder);
	/// Gets the layer node at a given order.
	///
	/// # Arguments
	///
	/// * `order` - The order of the layer node to get.
	///
	/// # Returns
	///
	/// * The layer node at the given order.
	Node* getLayer(int order);
	/// Sets the parallax moving ratio for a given layer to simulate 3D projection effect.
	///
	/// # Arguments
	///
	/// * `order` - The order of the layer to set the ratio for.
	/// * `ratio` - The new parallax ratio for the layer.
	void setLayerRatio(int order, Vec2 ratio);
	/// Gets the parallax moving ratio for a given layer.
	///
	/// # Arguments
	///
	/// * `order` - The order of the layer to get the ratio for.
	///
	/// # Returns
	///
	/// * A `Vec2` representing the parallax ratio for the layer.
	Vec2 getLayerRatio(int order);
	/// Sets the position offset for a given layer.
	///
	/// # Arguments
	///
	/// * `order` - The order of the layer to set the offset for.
	/// * `offset` - A `Vec2` representing the new position offset for the layer.
	void setLayerOffset(int order, Vec2 offset);
	/// Gets the position offset for a given layer.
	///
	/// # Arguments
	///
	/// * `order` - The order of the layer to get the offset for.
	///
	/// # Returns
	///
	/// * A `Vec2` representing the position offset for the layer.
	Vec2 getLayerOffset(int order);
	/// Swaps the positions of two layers.
	///
	/// # Arguments
	///
	/// * `order_a` - The order of the first layer to swap.
	/// * `order_b` - The order of the second layer to swap.
	void swapLayer(int orderA, int orderB);
	/// Removes a layer from the game world.
	///
	/// # Arguments
	///
	/// * `order` - The order of the layer to remove.
	void removeLayer(int order);
	/// Removes all layers from the game world.
	void removeAllLayers();
	/// The method to create a new instance of `PlatformWorld`.
	///
	/// # Returns
	///
	/// * A new instance of `PlatformWorld`.
	static PlatformWorld* create();
};

/// An interface that provides a centralized location for storing and accessing game-related data.
singleton class Data
{
	/// the group key representing the first index for a player group.
	readonly common uint8_t groupFirstPlayer;
	/// the group key representing the last index for a player group.
	readonly common uint8_t groupLastPlayer;
	/// the group key that won't have any contact with other groups by default.
	readonly common uint8_t groupHide;
	/// the group key that will have contacts with player groups by default.
	readonly common uint8_t groupDetectPlayer;
	/// the group key representing terrain that will have contacts with other groups by default.
	readonly common uint8_t groupTerrain;
	/// the group key that will have contacts with other groups by default.
	readonly common uint8_t groupDetection;
	/// the dictionary that can be used to store arbitrary data associated with string keys and various values globally.
	readonly common Dictionary* store;
	/// Sets a boolean value indicating whether two groups should be in contact or not.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	/// * `contact` - A boolean indicating whether the two groups should be in contact.
	void setShouldContact(uint8_t groupA, uint8_t groupB, bool contact);
	/// Gets a boolean value indicating whether two groups should be in contact or not.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two groups should be in contact.
	bool getShouldContact(uint8_t groupA, uint8_t groupB);
	/// Sets the relation between two groups.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	/// * `relation` - The relation between the two groups.
	void setRelation(uint8_t groupA, uint8_t groupB, Platformer::Relation relation);
	/// Gets the relation between two groups.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	///
	/// # Returns
	///
	/// * The relation between the two groups.
	Platformer::Relation getRelation @ getRelationByGroup(uint8_t groupA, uint8_t groupB);
	/// A function that can be used to get the relation between two bodies.
	///
	/// # Arguments
	///
	/// * `body_a` - The first body.
	/// * `body_b` - The second body.
	///
	/// # Returns
	///
	/// * The relation between the two bodies.
	Platformer::Relation getRelation(Body* bodyA, Body* bodyB);
	/// A function that returns whether two groups have an "Enemy" relation.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two groups have an "Enemy" relation.
	bool isEnemy @ isEnemyGroup(uint8_t groupA, uint8_t groupB);
	/// A function that returns whether two bodies have an "Enemy" relation.
	///
	/// # Arguments
	///
	/// * `body_a` - The first body.
	/// * `body_b` - The second body.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two bodies have an "Enemy" relation.
	bool isEnemy(Body* bodyA, Body* bodyB);
	/// A function that returns whether two groups have a "Friend" relation.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two groups have a "Friend" relation.
	bool isFriend @ isFriendGroup(uint8_t groupA, uint8_t groupB);
	/// A function that returns whether two bodies have a "Friend" relation.
	///
	/// # Arguments
	///
	/// * `body_a` - The first body.
	/// * `body_b` - The second body.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two bodies have a "Friend" relation.
	bool isFriend(Body* bodyA, Body* bodyB);
	/// A function that returns whether two groups have a "Neutral" relation.
	///
	/// # Arguments
	///
	/// * `group_a` - An integer representing the first group.
	/// * `group_b` - An integer representing the second group.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two groups have a "Neutral" relation.
	bool isNeutral @ isNeutralGroup(uint8_t groupA, uint8_t groupB);
	/// A function that returns whether two bodies have a "Neutral" relation.
	///
	/// # Arguments
	///
	/// * `body_a` - The first body.
	/// * `body_b` - The second body.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the two bodies have a "Neutral" relation.
	bool isNeutral(Body* bodyA, Body* bodyB);
	/// Sets the bonus factor for a particular type of damage against a particular type of defence.
	///
	/// The builtin "MeleeAttack" and "RangeAttack" actions use a simple formula of `finalDamage = damage * bonus`.
	///
	/// # Arguments
	///
	/// * `damage_type` - An integer representing the type of damage.
	/// * `defence_type` - An integer representing the type of defence.
	/// * `bonus` - A number representing the bonus.
	void setDamageFactor(uint16_t damageType, uint16_t defenceType, float bounus);
	/// Gets the bonus factor for a particular type of damage against a particular type of defence.
	///
	/// # Arguments
	///
	/// * `damage_type` - An integer representing the type of damage.
	/// * `defence_type` - An integer representing the type of defence.
	///
	/// # Returns
	///
	/// * A number representing the bonus factor.
	float getDamageFactor(uint16_t damageType, uint16_t defenceType);
	/// A function that returns whether a body is a player or not.
	///
	/// This works the same as `Data::get_group_first_player() <= body.group and body.group <= Data::get_group_last_player()`.
	///
	/// # Arguments
	///
	/// * `body` - The body to check.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the body is a player.
	bool isPlayer(Body* body);
	/// A function that returns whether a body is terrain or not.
	///
	/// This works the same as `body.group == Data::get_group_terrain()`.
	///
	/// # Arguments
	///
	/// * `body` - The body to check.
	///
	/// # Returns
	///
	/// * A boolean indicating whether the body is terrain.
	bool isTerrain(Body* body);
	/// Clears all data stored in the "Data" object, including user data in Data.store field. And reset some data to default values.
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

static void Binding::LoadFontTTFAsync @ load_font_ttf_async(
	string ttfFontFile,
	float fontSize,
	string glyphRanges,
	function<void(bool success)> handler);

static bool Binding::IsFontLoaded @ is_font_loaded();

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

static void Binding::Image @ imageOpts(
	string clipStr,
	Vec2 size,
	Color tint_col,
	Color border_col);

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
static void Binding::TextLinkOpenURL @ TextLinkOpen_url(string label, string url);

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

/// A node for rendering vector graphics.
object class VGNode : public INode {
	/// The surface of the node for displaying frame buffer texture that contains vector graphics.
	/// You can get the texture of the surface by calling `vgNode.get_surface().get_texture()`.
	readonly common Sprite* surface;
	/// The function for rendering vector graphics.
	///
	/// # Arguments
	///
	/// * `renderFunc` - The closure function for rendering vector graphics. You can do the rendering operations inside this closure.
	///
	/// # Example
	///
	/// ```
	/// vgNode.render(|| {
	/// 	Nvg::begin_path();
	/// 	Nvg::move_to(100.0, 100.0);
	/// 	Nvg::line_to(200.0, 200.0);
	/// 	Nvg::close_path();
	/// 	Nvg::stroke();
	/// });
	/// ```
	void render(function<void()> renderFunc);
	/// Creates a new VGNode object with the specified width and height.
	///
	/// # Arguments
	///
	/// * `width` - The width of the node's frame buffer texture.
	/// * `height` - The height of the node's frame buffer texture.
	/// * `scale` - The scale factor of the VGNode.
	/// * `edge_aa` - The edge anti-aliasing factor of the VGNode.
	///
	/// # Returns
	///
	/// * The newly created VGNode object.
	static VGNode* create(float width, float height, float scale, int edge_aa);
};
