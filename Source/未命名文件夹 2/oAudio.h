class oSound
{
	static void load(const char* filename);
	static void unload(const char* filename);
	static int play(const char* filename, bool loop = false);
	static void stop(int id);
	static void stop();
	static tolua_property__common float volume;
	static tolua_property__bool bool useCache;
};

class oMusic
{
	static void preload(const char* filename);
	static void play(const char* filename, bool loop = false);
	static void pause();
	static void resume();
	static void stop();
	static tolua_property__common float volume;
};
