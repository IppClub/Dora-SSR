#include "bgfx/platform.h"

#if BX_PLATFORM_ANDROID

#include <jni.h>
#include <android/log.h>
#include <string>
using std::string;

extern "C" {
	JNIEXPORT void JNICALL Java_com_luvfight_dorothy_MainActivity_nativeSetPath(JNIEnv* env, jclass cls, jstring apkPath);
}

string getAndroidAPKPath();

#endif // BX_PLATFORM_ANDROID
