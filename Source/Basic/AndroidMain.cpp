#include "Const/Header.h"
#include "Basic/AndroidMain.h"

#if BX_PLATFORM_ANDROID

static string g_androidAPKPath;

string getAndroidAPKPath()
{
	return g_androidAPKPath;
}

extern "C" {

	JNIEXPORT void JNICALL Java_com_luvfight_dorothy_MainActivity_nativeSetPath(JNIEnv* env, jclass cls, jstring apkPath)
	{
		const char* chars = env->GetStringUTFChars(apkPath, NULL);
		g_androidAPKPath = chars;
		env->ReleaseStringUTFChars(apkPath, chars);
	}

	/* Called before SDL_main() to initialize JNI bindings in SDL library */
	extern void SDL_Android_Init(JNIEnv* env, jclass cls);

	JNIEXPORT int JNICALL Java_org_libsdl_app_SDLActivity_nativeInit(JNIEnv* env, jclass cls, jobject array);

	/* Start up the SDL app */
	JNIEXPORT int JNICALL Java_org_libsdl_app_SDLActivity_nativeInit(JNIEnv* env, jclass cls, jobject array)
	{
		int i;
		int argc;
		int status;
		int len;
		char** argv;

		/* This interface could expand with ABI negotiation, callbacks, etc. */
		SDL_Android_Init(env, cls);

		SDL_SetMainReady();

		/* Prepare the arguments. */

		len = env->GetArrayLength((jarray)array);
		argv = SDL_stack_alloc(char*, 1 + len + 1);
		argc = 0;
		/* Use the name "app_process" so PHYSFS_platformCalcBaseDir() works.
			https://bitbucket.org/MartinFelis/love-android-sdl2/issue/23/release-build-crash-on-start
		 */
		argv[argc++] = SDL_strdup("app_process");
		for (i = 0; i < len; ++i) {
			const char* utf;
			char* arg = NULL;
			jstring string = (jstring)env->GetObjectArrayElement((jobjectArray)array, i);
			if (string) {
				utf = env->GetStringUTFChars(string, 0);
				if (utf) {
					arg = SDL_strdup(utf);
					env->ReleaseStringUTFChars(string, utf);
				}
				env->DeleteLocalRef(string);
			}
			if (!arg) {
				arg = SDL_strdup("");
			}
			argv[argc++] = arg;
		}
		argv[argc] = NULL;


		/* Run the application. */
		status = SDL_main(argc, argv);

		/* Release the arguments. */

		for (i = 0; i < argc; ++i) {
			SDL_free(argv[i]);
		}
		SDL_stack_free(argv);
		/* Do not issue an exit or the whole application will terminate instead of just the SDL thread */
		/* exit(status); */

		return status;
	}
}
#endif // BX_PLATFORM_ANDROID
