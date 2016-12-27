/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

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
