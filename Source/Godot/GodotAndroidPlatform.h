// Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE).
#pragma once
#include "SDL.h"
#include "SDL_system.h"
#include "Other/utf8.h"
#include <jni.h>
NS_DORA_BEGIN
inline std::string godotAndroidIntentOption(const char *name) {
    auto *env=static_cast<JNIEnv*>(SDL_AndroidGetJNIEnv());
    if (!env || env->PushLocalFrame(16)<0) return {};
    std::string result;
    jobject activity=static_cast<jobject>(SDL_AndroidGetActivity());
    if (activity) {
        jclass cls=env->GetObjectClass(activity);
        jmethodID getIntent=env->GetMethodID(cls,"getIntent","()Landroid/content/Intent;");
        jobject intent=getIntent?env->CallObjectMethod(activity,getIntent):nullptr;
        if (intent && !env->ExceptionCheck()) {
            jclass intentClass=env->GetObjectClass(intent);
            jmethodID getExtra=env->GetMethodID(intentClass,"getStringExtra","(Ljava/lang/String;)Ljava/lang/String;");
            jstring key=env->NewStringUTF(name);
            jstring value=getExtra?static_cast<jstring>(env->CallObjectMethod(intent,getExtra,key)):nullptr;
            if (value && !env->ExceptionCheck()) {
                const jchar *text=env->GetStringChars(value,nullptr);
                if (text) {
                    result=CodeCvt::utf16to8(std::u16string(reinterpret_cast<const char16_t*>(text),env->GetStringLength(value)));
                    env->ReleaseStringChars(value,text);
                }
            }
        }
    }
    if (env->ExceptionCheck()) { env->ExceptionDescribe();env->ExceptionClear(); }
    env->PopLocalFrame(nullptr);return result;
}
inline int prepareGodotAndroidJava(void *,uint32_t argc,const char *const *argv) {
    auto *env=static_cast<JNIEnv*>(SDL_AndroidGetJNIEnv());
    if (!env || argc<1 || !argv || env->PushLocalFrame(int(argc)+16)<0) return 0;
    auto finish=[env](int result) {
        if (env->ExceptionCheck()) { env->ExceptionDescribe();env->ExceptionClear();result=0; }
        env->PopLocalFrame(nullptr);return result;
    };
    jobject activity=static_cast<jobject>(SDL_AndroidGetActivity());if (!activity) return finish(0);
    jclass activityClass=env->GetObjectClass(activity);
    jmethodID getLoader=env->GetMethodID(activityClass,"getClassLoader","()Ljava/lang/ClassLoader;");
    if (!getLoader) return finish(0);
    jobject loader=env->CallObjectMethod(activity,getLoader);if (!loader || env->ExceptionCheck()) return finish(0);
    jclass loaderClass=env->GetObjectClass(loader);
    jmethodID loadClass=env->GetMethodID(loaderClass,"loadClass","(Ljava/lang/String;)Ljava/lang/Class;");
    if (!loadClass) return finish(0);
    jstring name=env->NewStringUTF("org.ippclub.dorassr.GodotEmbed");
    jclass helper=static_cast<jclass>(env->CallObjectMethod(loader,loadClass,name));
    if (!helper || env->ExceptionCheck()) return finish(0);
    jmethodID prepare=env->GetStaticMethodID(helper,"prepare","(Landroid/app/Activity;[Ljava/lang/String;)Z");
    if (!prepare) return finish(0);
    jclass stringClass=env->FindClass("java/lang/String");
    jobjectArray arguments=env->NewObjectArray(argc-1,stringClass,nullptr);
    if (!arguments) return finish(0);
    for (uint32_t i=1;i<argc;++i) {
        const auto text=CodeCvt::utf8to16(argv[i]);
        jstring value=env->NewString(reinterpret_cast<const jchar*>(text.data()),jsize(text.size()));
        if (!value) return finish(0);
        env->SetObjectArrayElement(arguments,i-1,value);env->DeleteLocalRef(value);
        if (env->ExceptionCheck()) return finish(0);
    }
    const bool ready=env->CallStaticBooleanMethod(helper,prepare,activity,arguments);
    return finish(ready?1:0);
}
NS_DORA_END
