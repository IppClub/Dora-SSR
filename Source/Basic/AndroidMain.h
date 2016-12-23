#ifndef __DOROTHY_BASIC_ANDROIDMAIN_H__
#define __DOROTHY_BASIC_ANDROIDMAIN_H__

#if BX_PLATFORM_ANDROID

#include <jni.h>
#include <android/log.h>

extern "C" {
	JNIEXPORT void JNICALL Java_com_luvfight_dorothy_MainActivity_nativeSetPath(JNIEnv* env, jclass cls, jstring apkPath);
}

string getAndroidAPKPath();

#endif // BX_PLATFORM_ANDROID

#endif // __DOROTHY_BASIC_ANDROIDMAIN_H__