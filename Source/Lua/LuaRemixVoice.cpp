#include "Const/Header.h"
#include "Lua/LuaRemixVoice.h"

#include "Common/Async.h"
#include "SDL.h"

#if BX_PLATFORM_ANDROID
#include <jni.h>
#endif

extern "C" {
#include "lua.h"
#include "lauxlib.h"
}

NS_DORA_BEGIN

#if BX_PLATFORM_OSX || BX_PLATFORM_IOS || BX_PLATFORM_ANDROID
namespace {
constexpr char CaptureType[] = "Dora.RemixVoice";
constexpr int sampleRate = 16000;
constexpr size_t maxCaptureBuffer = sampleRate * 2 * 2;
constexpr size_t maxWavSize = 44 + sampleRate * 2 * 61;
enum class VoiceStatus { Opening, Ready, Recording, Transcribing, Complete, Error, Closed };

struct VoiceSession {
	std::mutex mutex;
	std::atomic_bool cancelled = false;
	VoiceStatus status = VoiceStatus::Opening;
	SDL_AudioDeviceID device = 0;
	std::string data;
};

using SessionPtr = std::shared_ptr<VoiceSession>;

#if BX_PLATFORM_ANDROID
jlong androidUploadId(VoiceSession& session) {
	return static_cast<jlong>(reinterpret_cast<intptr_t>(&session.cancelled));
}

std::string postAndroidRemixVoice(VoiceSession& session, const std::string& authorization,
	const std::string& contentType, const std::string& body) {
	auto* env = static_cast<JNIEnv*>(SDL_AndroidGetJNIEnv());
	if (!env || env->PushLocalFrame(8) < 0) return {};
	auto activity = static_cast<jobject>(SDL_AndroidGetActivity());
	std::string result;
	if (activity) {
		auto cls = env->GetObjectClass(activity);
		auto post = env->GetStaticMethodID(cls, "postRemixVoice", "(JLjava/lang/String;Ljava/lang/String;[B)[B");
		if (post) {
			auto size = static_cast<jsize>(body.size());
			auto data = env->NewByteArray(size);
			auto auth = data ? env->NewStringUTF(authorization.c_str()) : nullptr;
			auto type = auth ? env->NewStringUTF(contentType.c_str()) : nullptr;
			if (type) {
				env->SetByteArrayRegion(data, 0, size, reinterpret_cast<const jbyte*>(body.data()));
				if (!env->ExceptionCheck()) {
					auto response = static_cast<jbyteArray>(env->CallStaticObjectMethod(cls, post, androidUploadId(session), auth, type, data));
					if (!env->ExceptionCheck() && response) {
						result.resize(env->GetArrayLength(response));
						env->GetByteArrayRegion(response, 0, static_cast<jsize>(result.size()), reinterpret_cast<jbyte*>(result.data()));
					}
				}
			}
		}
	}
	if (env->ExceptionCheck()) { env->ExceptionClear(); result.clear(); }
	env->PopLocalFrame(nullptr);
	return result;
}

void cancelAndroidRemixVoice(VoiceSession& session) {
	auto* env = static_cast<JNIEnv*>(SDL_AndroidGetJNIEnv());
	if (!env || env->PushLocalFrame(2) < 0) return;
	if (auto activity = static_cast<jobject>(SDL_AndroidGetActivity())) {
		auto cls = env->GetObjectClass(activity);
		if (auto cancel = env->GetStaticMethodID(cls, "cancelRemixVoiceUpload", "(J)V")) {
			env->CallStaticVoidMethod(cls, cancel, androidUploadId(session));
		}
	}
	if (env->ExceptionCheck()) env->ExceptionClear();
	env->PopLocalFrame(nullptr);
}
#endif

SessionPtr& getSession(lua_State* L) {
	return *static_cast<SessionPtr*>(luaL_checkudata(L, 1, CaptureType));
}

void closeCapture(VoiceSession& session, VoiceStatus status) {
	SDL_AudioDeviceID device;
	{
		std::lock_guard lock(session.mutex);
		device = std::exchange(session.device, 0);
		session.status = status;
		session.data.clear();
	}
	if (device != 0) SDL_CloseAudioDevice(device);
}

void receiveAudio(void* userdata, Uint8* stream, int size) {
	auto& session = *static_cast<VoiceSession*>(userdata);
	std::lock_guard lock(session.mutex);
	if (session.status != VoiceStatus::Recording || size <= 0) return;
	auto length = static_cast<size_t>(size);
	if (length > maxCaptureBuffer - session.data.size()) {
		session.status = VoiceStatus::Error;
		return;
	}
	session.data.append(reinterpret_cast<const char*>(stream), length);
}

int startVoice(lua_State* L) {
	auto session = std::make_shared<VoiceSession>();
	session->data.reserve(maxCaptureBuffer);
	new (lua_newuserdatauv(L, sizeof(SessionPtr), 0)) SessionPtr(session);
	luaL_setmetatable(L, CaptureType);
	SharedAsyncThread.run([session]() {
		if (session->cancelled) return;
		SDL_AudioDeviceID device = 0;
		{
			// SDL opens capture devices paused. On Android this can wait for a permission reply.
			static std::mutex audioOpenMutex;
			std::lock_guard openLock(audioOpenMutex);
			if (session->cancelled) return;
			if (SDL_WasInit(SDL_INIT_AUDIO) || SDL_InitSubSystem(SDL_INIT_AUDIO) == 0) {
				SDL_AudioSpec desired{};
				desired.freq = sampleRate;
				desired.format = AUDIO_S16LSB;
				desired.channels = 1;
				desired.samples = 512;
				desired.callback = receiveAudio;
				desired.userdata = session.get();
				device = SDL_OpenAudioDevice(nullptr, 1, &desired, nullptr, 0);
			}
		}
		{
			std::lock_guard lock(session->mutex);
			if (!session->cancelled) {
				session->device = device;
				session->status = device ? VoiceStatus::Ready : VoiceStatus::Error;
				return;
			}
		}
		if (device) SDL_CloseAudioDevice(device);
	});
	return 1;
}

int pollVoice(lua_State* L) {
	auto& session = *getSession(L);
	VoiceStatus status;
	std::string data;
	{
		std::lock_guard lock(session.mutex);
		if (session.status == VoiceStatus::Ready) {
			session.status = VoiceStatus::Recording;
			SDL_PauseAudioDevice(session.device, 0);
		}
		status = session.status;
		if (status == VoiceStatus::Recording) {
			data.assign(session.data);
			session.data.clear();
		} else if (status == VoiceStatus::Complete) {
			data.swap(session.data);
		}
	}
	const char* name = "error";
	switch (status) {
		case VoiceStatus::Opening: name = "opening"; break;
		case VoiceStatus::Ready: name = "opening"; break;
		case VoiceStatus::Recording: name = "recording"; break;
		case VoiceStatus::Transcribing: name = "transcribing"; break;
		case VoiceStatus::Complete: name = "complete"; break;
		case VoiceStatus::Error:
		case VoiceStatus::Closed: break;
	}
	lua_pushstring(L, name);
	if (data.empty()) return 1;
	lua_pushlstring(L, data.data(), data.size());
	return 2;
}

int transcribeVoice(lua_State* L) {
	auto session = getSession(L);
	size_t keyLength;
	const char* key = luaL_checklstring(L, 2, &keyLength);
	size_t audioLength;
	const char* audio = luaL_checklstring(L, 3, &audioLength);
	if (session->cancelled || keyLength == 0 || audioLength <= 44 || audioLength > maxWavSize
		|| std::string_view(key, keyLength).find_first_of(std::string_view("\0\r\n", 3)) != std::string_view::npos) {
		closeCapture(*session, VoiceStatus::Error);
		return 0;
	}

	closeCapture(*session, VoiceStatus::Transcribing);
	SharedAsyncThread.run([session, authorization = "Bearer " + std::string(key, keyLength),
							  wav = std::string(audio, audioLength)]() {
		if (session->cancelled) return;
		constexpr char boundary[] = "dora-remix-dictation-";
		std::string delimiter(boundary);
		while (wav.find(delimiter) != std::string::npos) delimiter += 'x';
		const auto contentType = "multipart/form-data; boundary=" + delimiter;
		auto body = "--" + delimiter + "\r\nContent-Disposition: form-data; name=\"file\"; filename=\"speech.wav\""
			"\r\nContent-Type: audio/wav\r\n\r\n" + wav + "\r\n--" + delimiter + "--\r\n";
#if BX_PLATFORM_ANDROID
		auto result = postAndroidRemixVoice(*session, authorization, contentType, body);
#else
		auto result = postAppleRemixVoice(authorization, contentType, body, session->cancelled);
#endif
		std::lock_guard lock(session->mutex);
		if (!session->cancelled) {
			session->status = result.empty() ? VoiceStatus::Error : VoiceStatus::Complete;
			session->data = std::move(result);
		}
	});
	return 0;
}

int cancelVoice(lua_State* L) {
	auto& session = *getSession(L);
	if (session.cancelled.exchange(true)) return 0;
#if BX_PLATFORM_ANDROID
	cancelAndroidRemixVoice(session);
#endif
	closeCapture(session, VoiceStatus::Closed);
	return 0;
}

int freeVoice(lua_State* L) {
	cancelVoice(L);
	std::destroy_at(&getSession(L));
	return 0;
}
}

#if BX_PLATFORM_ANDROID
extern "C" JNIEXPORT jboolean JNICALL Java_org_ippclub_dorassr_MainActivity_nativeRemixVoiceUploadCancelled(
	JNIEnv*, jclass, jlong requestId) {
	return reinterpret_cast<const std::atomic_bool*>(static_cast<intptr_t>(requestId))->load() ? JNI_TRUE : JNI_FALSE;
}
#endif
#endif

int luaopen_dora_remix_voice(lua_State* L) {
#if BX_PLATFORM_OSX || BX_PLATFORM_IOS || BX_PLATFORM_ANDROID
	luaL_newmetatable(L, CaptureType);
	lua_pushcfunction(L, freeVoice);
	lua_setfield(L, -2, "__gc");
	lua_pop(L, 1);
	const luaL_Reg functions[] = {
		{"start", startVoice}, {"poll", pollVoice}, {"transcribe", transcribeVoice}, {"cancel", cancelVoice}, {nullptr, nullptr}
	};
	luaL_newlib(L, functions);
#else
	lua_newtable(L);
#endif
	return 1;
}

NS_DORA_END
