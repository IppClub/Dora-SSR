/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Wasm/WasmRuntime.h"

#include "Dora.h"
#include "GUI/ImGuiBinding.h"

#include "Other/xlsxtext.hpp"

#ifndef DORA_NO_WA
extern "C" {
#if BX_PLATFORM_WINDOWS
extern __declspec(dllexport) char* WaBuild(char* input);
extern __declspec(dllexport) char* WaFormat(char* input);
extern __declspec(dllexport) void WaFreeCString(char* str);
#elif BX_PLATFORM_ANDROID
#include <jni.h>
extern "C" JNIEnv* Android_JNI_GetEnv();
static JavaVM* g_VM = NULL;
static void CacheJavaVM() {
	if (!g_VM) {
		JNIEnv* env = Android_JNI_GetEnv();
		if (!env || env->GetJavaVM(&g_VM) != 0) {
			Issue("Failed to get JavaVM");
		}
	}
}
JNIEnv* GetEnv() {
	CacheJavaVM();
	JNIEnv* env = NULL;
	if (g_VM->GetEnv((void**)&env, JNI_VERSION_1_6) != JNI_OK) {
		// 当前线程未附加，尝试 attach
		if (g_VM->AttachCurrentThread(&env, NULL) != 0) {
			Issue("Failed to attach current thread to JVM");
		}
	}
	return env;
}
static const char* WaBuild(char* input) {
	auto env = GetEnv();
	jclass cls = env->FindClass("org/ippclub/dorassr/MainActivity");
	if (!cls) return "failed to build Wa Project due to jni class not found";

	jmethodID mid = env->GetStaticMethodID(cls, "waBuild", "(Ljava/lang/String;)Ljava/lang/String;");
	if (!mid) return "failed to build Wa Project due to jni method not found";

	jstring jpath = env->NewStringUTF(input);
	jstring jresult = (jstring)env->CallStaticObjectMethod(cls, mid, jpath);

	const char* str = env->GetStringUTFChars(jresult, nullptr);
	char* result = new char[strlen(str) + 1];
	strcpy(result, str);
	env->ReleaseStringUTFChars(jresult, str);

	env->DeleteLocalRef(jpath);
	env->DeleteLocalRef(jresult);
	env->DeleteLocalRef(cls);

	return result;
}
static const char* WaFormat(char* input) {
	auto env = GetEnv();
	jclass cls = env->FindClass("org/ippclub/dorassr/MainActivity");
	if (!cls) return "";

	jmethodID mid = env->GetStaticMethodID(cls, "waFormat", "(Ljava/lang/String;)Ljava/lang/String;");
	if (!mid) return "";

	jstring jpath = env->NewStringUTF(input);
	jstring jresult = (jstring)env->CallStaticObjectMethod(cls, mid, jpath);

	const char* str = env->GetStringUTFChars(jresult, nullptr);
	char* result = new char[strlen(str) + 1];
	strcpy(result, str);
	env->ReleaseStringUTFChars(jresult, str);

	env->DeleteLocalRef(jpath);
	env->DeleteLocalRef(jresult);
	env->DeleteLocalRef(cls);

	return result;
}
void WaFreeCString(const char* str) {
	delete[] str;
}
#else
extern char* WaBuild(char* input);
extern char* WaFormat(char* input);
extern void WaFreeCString(char* str);
#endif
}
#endif // DORA_NO_WA

NS_DORA_BEGIN

#define DoraVersion(major, minor, patch) ((major) << 16 | (minor) << 8 | (patch))

static const int doraWASMVersion = DoraVersion(0, 5, 2);

static std::string VersionToStr(int version) {
	return std::to_string((version & 0x00ff0000) >> 16) + '.' + std::to_string((version & 0x0000ff00) >> 8) + '.' + std::to_string(version & 0x000000ff);
}

union LightWasmValue {
	Vec2 vec2;
	Size size;
	int64_t value;
	explicit LightWasmValue(const Size& v)
		: size(v) { }
	explicit LightWasmValue(const Vec2& v)
		: vec2(v) { }
	explicit LightWasmValue(int64_t v)
		: value(v) { }
};

static_assert(sizeof(LightWasmValue) == sizeof(int64_t), "encode item with greater size than int64_t for wasm.");

extern "C" {
#ifdef DORA_NO_STATIC_CALL_BACK
	void call_function(int32_t func_id) {
		DORA_UNUSED_PARAM(func_id);
		Error("unexpected invoked call_function()");
		std::abort();
	}
	void deref_function(int32_t func_id) {
		DORA_UNUSED_PARAM(func_id);
		Error("unexpected invoked deref_function()");
		std::abort();
	}
#else // !DORA_NO_STATIC_CALL_BACK
	void call_function(int32_t func_id);
	void deref_function(int32_t func_id);
#endif // !DORA_NO_STATIC_CALL_BACK
	typedef void (*DoraCallFunction)(int32_t func_id);
	static DoraCallFunction doraCallFunction = nullptr;
	DORA_EXPORT void dora_register_call_function(DoraCallFunction callFunc) {
		doraCallFunction = callFunc;
	}
	typedef void (*DoraDerefFunction)(int32_t func_id);
	static DoraDerefFunction doraDerefFunction = nullptr;
	DORA_EXPORT void dora_register_deref_function(DoraDerefFunction derefFunc) {
		doraDerefFunction = derefFunc;
	}
} // extern "C"

/* Vec2 */

static inline int64_t Vec2_Retain(const Vec2& vec2) {
	return LightWasmValue{vec2}.value;
}
static inline Vec2 Vec2_From(int64_t value) {
	return LightWasmValue{value}.vec2;
}

/* Size */

static inline int64_t Size_Retain(const Size& size) {
	return LightWasmValue{size}.value;
}
static inline Size Size_From(int64_t value) {
	return LightWasmValue{value}.size;
}

/* String */

static int64_t Str_Retain(String str) {
	return r_cast<int64_t>(new std::string(str.rawData(), str.size()));
}
static std::unique_ptr<std::string> Str_From(int64_t var) {
	return std::unique_ptr<std::string>(r_cast<std::string*>(var));
}

/* Vector */

using dora_vec_t = std::variant<
	std::vector<int32_t>,
	std::vector<int64_t>,
	std::vector<float>,
	std::vector<double>>;

static int64_t Vec_Retain(dora_vec_t&& vec) {
	auto new_vec = new dora_vec_t(std::move(vec));
	return r_cast<int64_t>(new_vec);
}

static int64_t Vec_To(const std::vector<Slice>& vec) {
	std::vector<int64_t> buf(vec.size());
	for (size_t i = 0; i < vec.size(); i++) {
		buf[i] = Str_Retain(vec[i]);
	}
	return Vec_Retain(dora_vec_t(std::move(buf)));
}

static int64_t Vec_To(const std::vector<std::string>& vec) {
	std::vector<int64_t> buf(vec.size());
	for (size_t i = 0; i < vec.size(); i++) {
		buf[i] = Str_Retain(vec[i]);
	}
	return Vec_Retain(dora_vec_t(std::move(buf)));
}

static int64_t Vec_To(const std::list<std::string>& vec) {
	std::vector<int64_t> buf;
	buf.reserve(vec.size());
	for (const auto& item : vec) {
		buf.push_back(Str_Retain(item));
	}
	return Vec_Retain(dora_vec_t(std::move(buf)));
}

static int64_t Vec_To(const std::vector<uint32_t>& vec) {
	std::vector<int32_t> buf;
	buf.reserve(vec.size());
	for (const auto& item : vec) {
		buf.push_back(s_cast<int32_t>(item));
	}
	return Vec_Retain(dora_vec_t(std::move(buf)));
}

static std::vector<std::string> Vec_FromStr(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int64_t>>(*vec);
	std::vector<std::string> strs;
	strs.reserve(vecInt.size());
	for (auto item : vecInt) {
		strs.push_back(*Str_From(item));
	}
	return strs;
}

static std::vector<Vec2> Vec_FromVec2(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int64_t>>(*vec);
	std::vector<Vec2> vs;
	vs.reserve(vecInt.size());
	for (auto item : vecInt) {
		vs.push_back(Vec2_From(item));
	}
	return vs;
}

static std::vector<uint32_t> Vec_FromUint32(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int32_t>>(*vec);
	std::vector<uint32_t> vs;
	vs.reserve(vecInt.size());
	for (auto item : vecInt) {
		vs.push_back(s_cast<uint32_t>(item));
	}
	return vs;
}

static std::vector<float> Vec_FromFloat(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	return std::move(std::get<std::vector<float>>(*vec));
}

static std::vector<VertexColor> Vec_FromVertexColor(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int64_t>>(*vec);
	std::vector<VertexColor> vs;
	vs.reserve(vecInt.size());
	for (auto item : vecInt) {
		vs.push_back(*r_cast<VertexColor*>(item));
	}
	return vs;
}

using ActionDef = Own<ActionDuration>;
static std::vector<ActionDef> Vec_FromActionDef(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int64_t>>(*vec);
	std::vector<ActionDef> vs;
	vs.reserve(vecInt.size());
	for (auto item : vecInt) {
		vs.push_back(std::move(*r_cast<ActionDef*>(item)));
	}
	return vs;
}

static std::vector<Platformer::Behavior::Leaf*> Vec_FromBtree(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int64_t>>(*vec);
	std::vector<Platformer::Behavior::Leaf*> vs;
	vs.reserve(vecInt.size());
	for (auto item : vecInt) {
		vs.push_back(r_cast<Platformer::Behavior::Leaf*>(item));
	}
	return vs;
}

static std::vector<Platformer::Decision::Leaf*> Vec_FromDtree(int64_t var) {
	auto vec = std::unique_ptr<dora_vec_t>(r_cast<dora_vec_t*>(var));
	auto vecInt = std::get<std::vector<int64_t>>(*vec);
	std::vector<Platformer::Decision::Leaf*> vs;
	vs.reserve(vecInt.size());
	for (auto item : vecInt) {
		vs.push_back(r_cast<Platformer::Decision::Leaf*>(item));
	}
	return vs;
}

/* CallStack */

void CallStack::push(uint64_t value) { _stack.push_back(s_cast<int64_t>(value)); }
void CallStack::push(int64_t value) { _stack.push_back(value); }
void CallStack::push(double value) { _stack.push_back(value); }
void CallStack::push(bool value) { _stack.push_back(value); }
void CallStack::push(String value) { _stack.push_back(value.toString()); }
void CallStack::push(Object* value) { _stack.push_back(value); }
void CallStack::push(const Vec2& value) { _stack.push_back(value); }
void CallStack::push(const Size& value) { _stack.push_back(value); }
void CallStack::push_v(dora_val_t value) { _stack.push_back(value); }

bool CallStack::empty() const {
	return _stack.empty();
}

dora_val_t CallStack::pop() {
	auto var = _stack.front();
	_stack.pop_front();
	return var;
}

bool CallStack::pop_bool_or(bool def) {
	if (_stack.empty()) {
		return def;
	}
	auto var = _stack.front();
	_stack.pop_front();
	if (std::holds_alternative<bool>(var)) {
		return std::get<bool>(var);
	}
	return def;
}

dora_val_t& CallStack::front() {
	return _stack.front();
}

void CallStack::clear() {
	_stack.clear();
}

static Own<Value> Value_To(const dora_val_t& v) {
	Own<Value> ov;
	std::visit([&](auto&& arg) {
		ov = Value::alloc(arg);
	},
		v);
	return ov;
}

static int64_t Value_From(Value* v) {
	if (!v) return 0;
	switch (v->getType()) {
		case ValueType::Integral:
			return r_cast<int64_t>(new dora_val_t(v->toVal<int64_t>()));
		case ValueType::FloatingPoint:
			return r_cast<int64_t>(new dora_val_t(v->toVal<double>()));
		case ValueType::Boolean:
			return r_cast<int64_t>(new dora_val_t(v->toVal<bool>()));
		case ValueType::Object: {
			auto obj = v->to<Object>();
			obj->retain();
			return r_cast<int64_t>(new dora_val_t(obj));
		}
		case ValueType::Struct: {
			if (auto str = v->asVal<std::string>()) {
				return r_cast<int64_t>(new dora_val_t(*str));
			} else if (auto vec2 = v->asVal<Vec2>()) {
				return r_cast<int64_t>(new dora_val_t(*vec2));
			} else if (auto size = v->asVal<Size>()) {
				return r_cast<int64_t>(new dora_val_t(*size));
			}
		}
	}
	return 0;
}

static void CallStack_PushValue(CallStack* stack, Value* v) {
	switch (v->getType()) {
		case ValueType::Integral:
			stack->push(v->toVal<int64_t>());
			break;
		case ValueType::FloatingPoint:
			stack->push(v->toVal<double>());
			break;
		case ValueType::Boolean:
			stack->push(v->toVal<bool>());
			break;
		case ValueType::Object:
			stack->push(v->to<Object>());
			break;
		case ValueType::Struct: {
			if (auto str = v->asVal<std::string>()) {
				stack->push(*str);
				break;
			} else if (auto vec2 = v->asVal<Vec2>()) {
				stack->push(*vec2);
				break;
			} else if (auto size = v->asVal<Size>()) {
				stack->push(*size);
				break;
			} else
				stack->push_v(dora_val_t());
		}
	}
}

static int64_t Object_From(Object* obj) {
	if (obj) obj->retain();
	return r_cast<int64_t>(obj);
}

/* Content */

struct WorkSheet {
	WorkSheet() { }
	WorkSheet(WorkSheet&& other)
		: worksheet(other.worksheet)
		, workbook(std::move(other.workbook))
		, it(other.it) {
	}
	bool read(Array* row) {
		if (!worksheet) return false;
		if (it != worksheet->end()) {
			row->clear();
			for (const auto& cell : *it) {
				if (row->getCount() < cell.refer.col) {
					for (int i = s_cast<int>(row->getCount()); i < s_cast<int>(cell.refer.col); i++) {
						row->add(Value::alloc(false));
					}
				}
				if (cell.value.empty() && cell.string_id >= 0) {
					const auto& value = workbook->shared_strings()[cell.string_id];
					row->set(cell.refer.col - 1, Value::alloc(value));
				} else {
					char* endptr = nullptr;
					double d = std::strtod(cell.value.c_str(), &endptr);
					if (*endptr != '\0' || endptr == cell.value.c_str()) {
						row->set(cell.refer.col - 1, Value::alloc(cell.value));
					} else {
						row->set(cell.refer.col - 1, Value::alloc(d));
					}
				}
			}
			it++;
			return true;
		} else {
			return false;
		}
	}
	xlsxtext::worksheet* worksheet = nullptr;
	std::vector<std::vector<xlsxtext::cell>>::const_iterator it;
	std::shared_ptr<xlsxtext::workbook> workbook;
};

struct WorkBook {
	WorkSheet getSheet(String name) {
		if (!workbook) return {};
		for (auto& worksheet : *workbook) {
			if (worksheet.name() == name) {
				auto errors = worksheet.read();
				if (!errors.empty()) {
					Error("failed to read excel sheet \"{}\":", worksheet.name());
					for (auto [refer, msg] : errors) {
						Error("{}: {}", refer, msg);
					}
					return {};
				}
				WorkSheet sheet;
				sheet.worksheet = &worksheet;
				sheet.it = worksheet.begin();
				sheet.workbook = workbook;
				return sheet;
			}
		}
		return {};
	}
	std::shared_ptr<xlsxtext::workbook> workbook;
};

static WorkBook content_wasm_load_excel(String filename) {
	auto workbook = std::make_shared<xlsxtext::workbook>(SharedContent.load(filename));
	WorkBook book;
	if (workbook->read()) {
		book.workbook = workbook;
	}
	return book;
}

/* Rect */

static inline const Rect& Rect_GetZero() { return Rect::zero; }

// Director

static void Director_Schedule(const std::function<bool(double)>& handler) {
#ifdef DORA_AS_LIB
	SharedDirector.getScheduler()->schedule(handler);
#else
	SharedWasmRuntime.getScheduler()->schedule(handler);
#endif
}

static void Director_SchedulePosted(const std::function<bool(double)>& handler) {
#ifdef DORA_AS_LIB
	SharedDirector.getPostScheduler()->schedule(handler);
#else
	SharedWasmRuntime.getPostScheduler()->schedule(handler);
#endif
}

static void Director_Cleanup() {
	SharedDirector.cleanup();
}

// Node

using Grabber = Node::Grabber;

static Grabber* Node_StartGrabbing(Node* node) {
	return node->grab(true);
}
static void Node_StopGrabbing(Node* node) {
	node->grab(false);
}
static void Node_SetTransformTargetNullptr(Node* node) {
	node->setTransformTarget(nullptr);
}
static float Node_RunActionDefDuration(Node* node, ActionDef def, bool loop) {
	if (def) {
		return node->runAction(Action::create(std::move(def)), loop);
	}
	return 0.0f;
}
static float Node_PerformDefDuration(Node* node, ActionDef def, bool loop) {
	if (def) {
		return node->perform(Action::create(std::move(def)), loop);
	}
	return 0.0f;
}
static void Node_Emit(Node* node, String name, CallStack* stack) {
	WasmEventArgs event(name, stack);
	r_cast<Node*>(node)->emit(&event);
}

// Texture2D

static inline Texture2D* Texture2D_Create(String name) {
	return SharedTextureCache.load(name);
}

// Sprite

static inline void Sprite_SetEffectNullptr(Sprite* self) {
	self->setEffect(nullptr);
}

// Platformer::PlatformCamera

static void PlatformCamera_SetFollowTargetNullptr(Platformer::PlatformCamera* self) {
	self->setFollowTarget(nullptr);
}

// View

static void View_SetPostEffectNullptr() {
	SharedView.setPostEffect(nullptr);
}

// Effect

static Pass* Effect_GetPass(Effect* self, size_t index) {
	const auto& passes = self->getPasses();
	if (index < passes.size()) {
		return self->get(index);
	}
	return nullptr;
}

// Action

#define ActionDef_Prop PropertyAction::alloc
#define ActionDef_Tint Tint::alloc
#define ActionDef_Roll Roll::alloc
#define ActionDef_Spawn Spawn::alloc
#define ActionDef_Sequence Sequence::alloc
#define ActionDef_Delay Delay::alloc
#define ActionDef_Show Show::alloc
#define ActionDef_Hide Hide::alloc
#define ActionDef_Emit Emit::alloc
#define ActionDef_Move Move::alloc
#define ActionDef_Scale Scale::alloc

static Own<ActionDuration> ActionDef_Frame(String clipStr, float duration) {
	auto def = FrameActionDef::create();
	auto [tex, rect] = SharedClipCache.loadTexture(clipStr);
	if (!tex) {
		Error("invalid texture \"{}\" used for creating frame action.", clipStr.toString());
		return FrameAction::alloc(def);
	}
	if (rect.getHeight() > rect.getWidth()) {
		Error("invalid texture \"%s\" (height > width) used for creating frame action.", clipStr.toString());
		return FrameAction::alloc(def);
	}
	def->clipStr = clipStr.toString();
	auto totalFrames = s_cast<int>(rect.getWidth() / rect.getHeight());
	for (int i = 0; i < totalFrames; i++) {
		def->rects.push_back(New<Rect>(rect.getX() + i * rect.getHeight(), rect.getY(), rect.getHeight(), rect.getHeight()));
	}
	def->duration = duration;
	return FrameAction::alloc(def);
}

static Own<ActionDuration> ActionDef_Frame(String clipStr, float duration, const std::vector<uint32_t>& frames) {
	auto def = FrameActionDef::create();
	auto [tex, rect] = SharedClipCache.loadTexture(clipStr);
	if (!tex) {
		Error("invalid texture \"{}\" used for creating frame action.", clipStr.toString());
		return FrameAction::alloc(def);
	}
	if (rect.getHeight() > rect.getWidth()) {
		Error("invalid texture \"%s\" (height > width) used for creating frame action.", clipStr.toString());
		return FrameAction::alloc(def);
	}
	def->clipStr = clipStr.toString();
	auto totalFrames = s_cast<int>(rect.getWidth() / rect.getHeight());
	std::vector<Rect> rects(totalFrames);
	for (int i = 0; i < totalFrames; i++) {
		rects[i] = {rect.getX() + i * rect.getHeight(), rect.getY(), rect.getHeight(), rect.getHeight()};
	}
	def->duration = duration;
	if (totalFrames != frames.size()) {
		Error("unmatched frame numbers, expecting {}, got {}.", totalFrames, frames.size());
		return FrameAction::alloc(def);
	}
	for (int i = 0; i < totalFrames; i++) {
		auto count = frames[i];
		for (unsigned int c = 0; c < count; c++) {
			def->rects.push_back(New<Rect>(rects[i]));
		}
	}
	return FrameAction::alloc(def);
}

// Model

static std::string Model_GetClipFilename(String filename) {
	if (ModelDef* modelDef = SharedModelCache.load(filename)) {
		return modelDef->getClipFile();
	}
	return Slice::Empty;
}
static std::vector<std::string> Model_GetLookNames(String filename) {
	if (ModelDef* modelDef = SharedModelCache.load(filename)) {
		return modelDef->getLookNames();
	}
	return std::vector<std::string>();
}
static std::vector<std::string> Model_GetAnimationNames(String filename) {
	if (ModelDef* modelDef = SharedModelCache.load(filename)) {
		return modelDef->getAnimationNames();
	}
	return std::vector<std::string>();
}

// Spine

static std::vector<std::string> Spine_GetLookNames(String spineStr) {
	if (auto skelData = SharedSkeletonCache.load(spineStr)) {
		auto& skins = skelData->getSkel()->getSkins();
		std::vector<std::string> res;
		res.reserve(skins.size());
		for (size_t i = 0; i < skins.size(); i++) {
			const auto& name = skins[i]->getName();
			res.push_back(std::string(name.buffer(), name.length()));
		}
		return res;
	}
	return std::vector<std::string>();
}
static std::vector<std::string> Spine_GetAnimationNames(String spineStr) {
	if (auto skelData = SharedSkeletonCache.load(spineStr)) {
		auto& anims = skelData->getSkel()->getAnimations();
		std::vector<std::string> res;
		res.reserve(anims.size());
		for (size_t i = 0; i < anims.size(); i++) {
			const auto& name = anims[i]->getName();
			res.push_back(std::string(name.buffer(), name.length()));
		}
		return res;
	}
	return std::vector<std::string>();
}

// DragonBones

static std::vector<std::string> DragonBone_GetLookNames(String boneStr) {
	auto boneData = SharedDragonBoneCache.load(boneStr);
	if (boneData.first) {
		if (boneData.second.empty()) {
			boneData.second = boneData.first->getArmatureNames().front();
		}
		const auto& skins = boneData.first->getArmature(boneData.second)->skins;
		std::vector<std::string> res;
		res.reserve(skins.size());
		for (const auto& item : skins) {
			res.push_back(item.first);
		}
		return res;
	}
	return std::vector<std::string>();
}
static std::vector<std::string> DragonBone_GetAnimationNames(String boneStr) {
	auto boneData = SharedDragonBoneCache.load(boneStr);
	if (boneData.first) {
		if (boneData.second.empty()) {
			boneData.second = boneData.first->getArmatureNames().front();
		}
		return boneData.first->getArmature(boneData.second)->animationNames;
	}
	return std::vector<std::string>();
}

/* BodyDef */

static void BodyDef_SetTypeEnum(BodyDef* def, int32_t type) {
	pr::BodyType bodyType;
	switch (type) {
		case 0:
			bodyType = pr::BodyType::Dynamic;
			break;
		case 1:
			bodyType = pr::BodyType::Static;
			break;
		case 2:
			bodyType = pr::BodyType::Kinematic;
			break;
		default:
			Issue("invalid body type value for BodyDef: {}", type);
			break;
	}
	def->setType(bodyType);
}
static int32_t BodyDef_GetTypeEnum(BodyDef* def) {
	switch (def->getType()) {
		case pr::BodyType::Dynamic:
			return 0;
		case pr::BodyType::Static:
			return 1;
		case pr::BodyType::Kinematic:
			return 2;
		default:
			Issue("invalid body type enum: {}", s_cast<int>(def->getType()));
			return 0;
	}
}

// QLearner

#define MLBuildDecisionTreeAsync ML::BuildDecisionTreeAsync
using MLQLearner = ML::QLearner;
using MLQState = ML::QLearner::QState;
using MLQAction = ML::QLearner::QAction;
static void ML_QLearnerVisitStateActionQ(MLQLearner* qlearner, const std::function<void(MLQState, MLQAction, double)>& handler) {
	const auto& matrix = qlearner->getMatrix();
	for (const auto& row : matrix) {
		ML::QLearner::QState state = row.first;
		for (const auto& col : row.second) {
			ML::QLearner::QAction action = col.first;
			double q = col.second;
			handler(state, action, q);
		}
	}
}

// Behavior

#define BSeq Platformer::Behavior::Seq
#define BSel Platformer::Behavior::Sel
#define BCon Platformer::Behavior::Con
#define BAct Platformer::Behavior::Act
#define BCommand Platformer::Behavior::Command
#define BWait Platformer::Behavior::Wait
#define BCountdown Platformer::Behavior::Countdown
#define BTimeout Platformer::Behavior::Timeout
#define BRepeat Platformer::Behavior::Repeat
#define BRetry Platformer::Behavior::Retry

// Decision

#define DSeq Platformer::Decision::Seq
#define DSel Platformer::Decision::Sel
#define DCon Platformer::Decision::Con
#define DAct Platformer::Decision::Act
#define DAccept Platformer::Decision::Accept
#define DReject Platformer::Decision::Reject
#define DBehave Platformer::Decision::Behave

// UnitAction

namespace Platformer {

class WasmActionUpdate : public Object {
public:
	std::function<bool(Unit*, UnitAction*, float)> update;
	CREATE_FUNC_NOT_NULL(WasmActionUpdate);

protected:
	explicit WasmActionUpdate(std::function<bool(Unit*, UnitAction*, float)>&& update)
		: update(std::move(update)) { }
	DORA_TYPE_OVERRIDE(WasmActionUpdate);
};
class WasmUnitAction : public UnitAction {
public:
	WasmUnitAction(String name, int priority, bool queued, Unit* owner)
		: UnitAction(name, priority, queued, owner) { }
	virtual bool isAvailable() override {
		return _available(_owner, s_cast<UnitAction*>(this));
	}
	virtual void run() override {
		UnitAction::run();
		if (auto playable = _owner->getPlayable()) {
			playable->setRecovery(recovery);
		}
		_update = std::move(_create(_owner, s_cast<UnitAction*>(this))->update);
		if (_update(_owner, s_cast<UnitAction*>(this), 0.0f)) {
			WasmUnitAction::stop();
		}
	}
	virtual void update(float dt) override {
		if (_update && _update(_owner, s_cast<UnitAction*>(this), dt)) {
			WasmUnitAction::stop();
		}
		UnitAction::update(dt);
	}
	virtual void stop() override {
		_update = nullptr;
		_stop(_owner, s_cast<UnitAction*>(this));
		UnitAction::stop();
	}

private:
	std::function<bool(Unit*, UnitAction*)> _available;
	std::function<WasmActionUpdate*(Unit*, UnitAction*)> _create;
	std::function<bool(Unit*, UnitAction*, float)> _update;
	std::function<void(Unit*, UnitAction*)> _stop;
	friend class WasmActionDef;
};
class WasmActionDef : public UnitActionDef {
public:
	WasmActionDef(
		const std::function<bool(Unit*, UnitAction*)>& available,
		const std::function<WasmActionUpdate*(Unit*, UnitAction*)>& create,
		const std::function<void(Unit*, UnitAction*)>& stop)
		: available(available)
		, create(create)
		, stop(stop) { }
	std::function<bool(Unit*, UnitAction*)> available;
	std::function<WasmActionUpdate*(Unit*, UnitAction*)> create;
	std::function<void(Unit*, UnitAction*)> stop;
	virtual Own<UnitAction> toAction(Unit* unit) override {
		WasmUnitAction* action = new WasmUnitAction(name, priority, queued, unit);
		action->reaction = reaction;
		action->recovery = recovery;
		action->_available = available;
		action->_create = create;
		action->_stop = stop;
		return MakeOwn(s_cast<UnitAction*>(action));
	}
};
static void UnitAction_Add(
	String name, int priority, float reaction, float recovery, bool queued,
	const std::function<bool(Unit*, UnitAction*)>& available,
	const std::function<WasmActionUpdate*(Unit*, UnitAction*)>& create,
	const std::function<void(Unit*, UnitAction*)>& stop) {
	UnitActionDef* actionDef = new WasmActionDef(available, create, stop);
	actionDef->name = name.toString();
	actionDef->priority = priority;
	actionDef->reaction = reaction;
	actionDef->recovery = recovery;
	actionDef->queued = queued;
	UnitAction::add(name, MakeOwn(actionDef));
}

} // namespace Platformer
#define Platformer_UnitAction_Add Platformer::UnitAction_Add

// DB

struct DBParams {
	void add(Array* params) {
		auto& record = records.emplace_back();
		for (size_t i = 0; i < params->getCount(); ++i) {
			record.emplace_back(params->get(i)->clone());
		}
	}
	std::deque<std::vector<Own<Value>>> records;
};
struct DBRecord {
	DBRecord() { }
	DBRecord(DBRecord&& other)
		: records(std::move(other.records)) { }
	bool read(Array* record) {
		record->clear();
		if (records.empty()) return false;
		for (const auto& value : records.front()) {
			record->add(DB::col(value));
		}
		records.pop_front();
		return true;
	}
	bool isValid() { return valid; }
	bool valid = false;
	std::deque<std::vector<DB::Col>> records;
};
struct DBQuery {
	DBQuery() { }
	DBQuery(DBQuery&& other)
		: queries(std::move(other.queries)) { }
	void addWithParams(String sql, DBParams& params) {
		auto& query = queries.emplace_back();
		query.first = sql.toString();
		for (auto& rec : params.records) {
			query.second.emplace_back(std::move(rec));
		}
	}
	void add(String sql) {
		auto& query = queries.emplace_back();
		query.first = sql.toString();
	}
	std::list<std::pair<std::string, std::deque<std::vector<Own<Value>>>>> queries;
};
static bool DB_Transaction(DBQuery& query) {
	return SharedDB.transaction([&](SQLite::Database* db) {
		for (const auto& sql : query.queries) {
			if (sql.second.empty()) {
				DB::execUnsafe(db, sql.first);
			} else {
				DB::execUnsafe(db, sql.first, sql.second);
			}
		}
	});
}
static void DB_TransactionAsync(DBQuery& query, const std::function<void(bool result)>& callback) {
	SharedDB.transactionAsync([&](SQLite::Database* db) {
		for (const auto& sql : query.queries) {
			if (sql.second.empty()) {
				DB::execUnsafe(db, sql.first);
			} else {
				DB::execUnsafe(db, sql.first, sql.second);
			}
		}
	},
		callback);
}
static DBRecord DB_Query(String sql, bool withColumns) {
	std::vector<Own<Value>> args;
	auto result = SharedDB.query(sql, args, withColumns);
	DBRecord record;
	if (result) {
		record.records = std::move(*result);
		record.valid = true;
	} else {
		record.valid = false;
	}
	return record;
}
static DBRecord DB_QueryWithParams(String sql, Array* param, bool withColumns) {
	std::vector<Own<Value>> args;
	for (size_t i = 0; i < param->getCount(); ++i) {
		args.emplace_back(param->get(i)->clone());
	}
	auto result = SharedDB.query(sql, args, withColumns);
	DBRecord record;
	if (result) {
		record.records = std::move(*result);
		record.valid = true;
	} else {
		record.valid = false;
	}
	return record;
}
static void DB_Insert(String tableName, const DBParams& params) {
	SharedDB.insert(tableName, params.records);
}
static int32_t DB_ExecWithRecords(String sql, const DBParams& params) {
	return SharedDB.exec(sql, params.records);
}
static void DB_QueryWithParamsAsync(String sql, Array* param, bool withColumns, const std::function<void(DBRecord& result)>& callback) {
	std::vector<Own<Value>> args;
	for (size_t i = 0; i < param->getCount(); ++i) {
		args.emplace_back(param->get(i)->clone());
	}
	SharedDB.queryAsync(sql, std::move(args), withColumns, [callback](std::optional<DB::Rows>& result) {
		DBRecord record;
		if (result) {
			record.records = std::move(*result);
			record.valid = true;
		} else {
			record.valid = false;
		}
		callback(record);
	});
}
static void DB_InsertAsync(String tableName, DBParams& params, const std::function<void(bool)>& callback) {
	SharedDB.insertAsync(tableName, std::move(params.records), callback);
}
static void DB_ExecAsync(String sql, DBParams& params, const std::function<void(int64_t)>& callback) {
	SharedDB.execAsync(sql, std::move(params.records), [callback](int rows) {
		callback(s_cast<int64_t>(rows));
	});
}

NS_DORA_END

extern "C" {

using namespace Dora;

/* String */

DORA_EXPORT int64_t str_new(int32_t len) {
	return r_cast<int64_t>(new std::string(len, 0));
}
DORA_EXPORT int32_t str_len(int64_t str) {
	return s_cast<int32_t>(r_cast<std::string*>(str)->length());
}
DORA_EXPORT void str_read(void* dest, int64_t src) {
	auto str = r_cast<std::string*>(src);
	if (str->length() > 0) {
		std::memcpy(dest, str->c_str(), str->length());
	}
}
DORA_EXPORT void str_read_ptr(int32_t dest, int64_t src) {
	auto destPtr = SharedWasmRuntime.getMemoryAddress(dest);
	auto str = r_cast<std::string*>(src);
	if (str->length() > 0) {
		std::memcpy(destPtr, str->c_str(), str->length());
	}
}
DORA_EXPORT void str_write(int64_t dest, const void* src) {
	auto str = r_cast<std::string*>(dest);
	if (str->length() > 0) {
		std::memcpy(&str->front(), src, str->length());
	}
}
DORA_EXPORT void str_write_ptr(int64_t dest, int32_t src) {
	auto srcPtr = SharedWasmRuntime.getMemoryAddress(src);
	auto str = r_cast<std::string*>(dest);
	if (str->length() > 0) {
		std::memcpy(&str->front(), srcPtr, str->length());
	}
}
DORA_EXPORT void str_release(int64_t str) {
	delete r_cast<std::string*>(str);
}

/* Buf */

DORA_EXPORT int64_t buf_new_i32(int32_t len) {
	auto new_vec = new dora_vec_t(std::vector<int32_t>(len));
	return r_cast<int64_t>(new_vec);
}
DORA_EXPORT int64_t buf_new_i64(int32_t len) {
	auto new_vec = new dora_vec_t(std::vector<int64_t>(len));
	return r_cast<int64_t>(new_vec);
}
DORA_EXPORT int64_t buf_new_f32(int32_t len) {
	auto new_vec = new dora_vec_t(std::vector<float>(len));
	return r_cast<int64_t>(new_vec);
}
DORA_EXPORT int64_t buf_new_f64(int32_t len) {
	auto new_vec = new dora_vec_t(std::vector<double>(len));
	return r_cast<int64_t>(new_vec);
}
DORA_EXPORT int32_t buf_len(int64_t v) {
	auto vec = r_cast<dora_vec_t*>(v);
	int32_t size = 0;
	std::visit([&](const auto& arg) {
		size = s_cast<int32_t>(arg.size());
	},
		*vec);
	return size;
}
DORA_EXPORT void buf_read(void* dest, int64_t src) {
	auto vec = r_cast<dora_vec_t*>(src);
	std::visit([&](const auto& arg) {
		if (arg.size() > 0) {
			std::memcpy(dest, arg.data(), arg.size() * sizeof(arg[0]));
		}
	},
		*vec);
}
DORA_EXPORT void buf_read_ptr(int32_t dest, int64_t src) {
	auto destPtr = SharedWasmRuntime.getMemoryAddress(dest);
	auto vec = r_cast<dora_vec_t*>(src);
	std::visit([&](const auto& arg) {
		if (arg.size() > 0) {
			std::memcpy(destPtr, arg.data(), arg.size() * sizeof(arg[0]));
		}
	},
		*vec);
}
DORA_EXPORT void buf_write(int64_t dest, const void* src) {
	auto vec = r_cast<dora_vec_t*>(dest);
	std::visit([&](auto& arg) {
		if (arg.size() > 0) {
			std::memcpy(&arg.front(), src, arg.size() * sizeof(arg[0]));
		}
	},
		*vec);
}
DORA_EXPORT void buf_write_ptr(int64_t dest, int32_t src) {
	auto srcPtr = SharedWasmRuntime.getMemoryAddress(src);
	auto vec = r_cast<dora_vec_t*>(dest);
	std::visit([&](auto& arg) {
		if (arg.size() > 0) {
			std::memcpy(&arg.front(), srcPtr, arg.size() * sizeof(arg[0]));
		}
	},
		*vec);
}
DORA_EXPORT void buf_release(int64_t v) {
	delete r_cast<dora_vec_t*>(v);
}

/* Object */

DORA_EXPORT int32_t object_get_id(int64_t obj) {
	return s_cast<int32_t>(r_cast<Object*>(obj)->getId());
}
DORA_EXPORT int32_t object_get_type(int64_t obj) {
	if (obj) return r_cast<Object*>(obj)->getDoraType();
	return 0;
}
DORA_EXPORT void object_retain(int64_t obj) {
	r_cast<Object*>(obj)->retain();
}
DORA_EXPORT void object_release(int64_t obj) {
	r_cast<Object*>(obj)->release();
}
DORA_EXPORT int64_t object_to_node(int64_t obj) {
	if (auto target = d_cast<Node*>(r_cast<Object*>(obj))) {
		return r_cast<int64_t>(target);
	}
	return 0;
}
DORA_EXPORT int64_t object_to_camera(int64_t obj) {
	if (auto target = d_cast<Camera*>(r_cast<Object*>(obj))) {
		return r_cast<int64_t>(target);
	}
	return 0;
}
DORA_EXPORT int64_t object_to_playable(int64_t obj) {
	if (auto target = d_cast<Playable*>(r_cast<Object*>(obj))) {
		return r_cast<int64_t>(target);
	}
	return 0;
}
DORA_EXPORT int64_t object_to_physics_world(int64_t obj) {
	if (auto target = d_cast<PhysicsWorld*>(r_cast<Object*>(obj))) {
		return r_cast<int64_t>(target);
	}
	return 0;
}
DORA_EXPORT int64_t object_to_body(int64_t obj) {
	if (auto target = d_cast<Body*>(r_cast<Object*>(obj))) {
		return r_cast<int64_t>(target);
	}
	return 0;
}
DORA_EXPORT int64_t object_to_joint(int64_t obj) {
	if (auto target = d_cast<Joint*>(r_cast<Object*>(obj))) {
		return r_cast<int64_t>(target);
	}
	return 0;
}

/* Value */

DORA_EXPORT int64_t value_create_i64(int64_t value) {
	return r_cast<int64_t>(new dora_val_t(value));
}
DORA_EXPORT int64_t value_create_f64(double value) {
	return r_cast<int64_t>(new dora_val_t(value));
}
DORA_EXPORT int64_t value_create_str(int64_t value) {
	auto str = r_cast<std::string*>(value);
	return r_cast<int64_t>(new dora_val_t(*str));
}
DORA_EXPORT int64_t value_create_bool(int32_t value) {
	return r_cast<int64_t>(new dora_val_t(value != 0));
}
DORA_EXPORT int64_t value_create_object(int64_t value) {
	auto obj = r_cast<Object*>(value);
	obj->retain();
	return r_cast<int64_t>(new dora_val_t(obj));
}
DORA_EXPORT int64_t value_create_vec2(int64_t value) {
	return r_cast<int64_t>(new dora_val_t(Vec2_From(value)));
}
DORA_EXPORT int64_t value_create_size(int64_t value) {
	return r_cast<int64_t>(new dora_val_t(Size_From(value)));
}
DORA_EXPORT void value_release(int64_t value) {
	auto v = r_cast<dora_val_t*>(value);
	if (std::holds_alternative<Object*>(*v)) {
		std::get<Object*>(*v)->release();
	}
	delete v;
}
DORA_EXPORT int64_t value_into_i64(int64_t value) {
	return std::get<int64_t>(*r_cast<dora_val_t*>(value));
}
DORA_EXPORT double value_into_f64(int64_t value) {
	const auto& v = *r_cast<dora_val_t*>(value);
	if (std::holds_alternative<int64_t>(v)) {
		return s_cast<double>(std::get<int64_t>(v));
	}
	return std::get<double>(v);
}
DORA_EXPORT int64_t value_into_str(int64_t value) {
	auto str = std::get<std::string>(*r_cast<dora_val_t*>(value));
	return r_cast<int64_t>(new std::string(str));
}
DORA_EXPORT int32_t value_into_bool(int64_t value) {
	return std::get<bool>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}
DORA_EXPORT int64_t value_into_object(int64_t value) {
	return Object_From(std::get<Object*>(*r_cast<dora_val_t*>(value)));
}
DORA_EXPORT int64_t value_into_vec2(int64_t value) {
	return Vec2_Retain(std::get<Vec2>(*r_cast<dora_val_t*>(value)));
}
DORA_EXPORT int64_t value_into_size(int64_t value) {
	return Size_Retain(std::get<Size>(*r_cast<dora_val_t*>(value)));
}
DORA_EXPORT int32_t value_is_i64(int64_t value) {
	return std::holds_alternative<int64_t>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}
DORA_EXPORT int32_t value_is_f64(int64_t value) {
	const auto& v = *r_cast<dora_val_t*>(value);
	return std::holds_alternative<double>(v) || std::holds_alternative<int64_t>(v) ? 1 : 0;
}
DORA_EXPORT int32_t value_is_str(int64_t value) {
	return std::holds_alternative<std::string>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}
DORA_EXPORT int32_t value_is_bool(int64_t value) {
	return std::holds_alternative<bool>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}
DORA_EXPORT int32_t value_is_object(int64_t value) {
	return std::holds_alternative<Object*>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}
DORA_EXPORT int32_t value_is_vec2(int64_t value) {
	return std::holds_alternative<Vec2>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}
DORA_EXPORT int32_t value_is_size(int64_t value) {
	return std::holds_alternative<Size>(*r_cast<dora_val_t*>(value)) ? 1 : 0;
}

/* CallStack */

DORA_EXPORT int64_t call_stack_create() {
	return r_cast<int64_t>(new CallStack());
}
DORA_EXPORT void call_stack_release(int64_t stack) {
	delete r_cast<CallStack*>(stack);
}
DORA_EXPORT void call_stack_push_i64(int64_t stack, int64_t value) {
	r_cast<CallStack*>(stack)->push(value);
}
DORA_EXPORT void call_stack_push_f64(int64_t stack, double value) {
	r_cast<CallStack*>(stack)->push(value);
}
DORA_EXPORT void call_stack_push_str(int64_t stack, int64_t value) {
	r_cast<CallStack*>(stack)->push(*Str_From(value));
}
DORA_EXPORT void call_stack_push_bool(int64_t stack, int32_t value) {
	r_cast<CallStack*>(stack)->push(value != 0);
}
DORA_EXPORT void call_stack_push_object(int64_t stack, int64_t value) {
	r_cast<CallStack*>(stack)->push(r_cast<Object*>(value));
}
DORA_EXPORT void call_stack_push_vec2(int64_t stack, int64_t value) {
	r_cast<CallStack*>(stack)->push(Vec2_From(value));
}
DORA_EXPORT void call_stack_push_size(int64_t stack, int64_t value) {
	r_cast<CallStack*>(stack)->push(Size_From(value));
}
DORA_EXPORT int64_t call_stack_pop_i64(int64_t stack) {
	return std::get<int64_t>(r_cast<CallStack*>(stack)->pop());
}
DORA_EXPORT double call_stack_pop_f64(int64_t stack) {
	auto v = r_cast<CallStack*>(stack)->pop();
	if (std::holds_alternative<int64_t>(v)) {
		return s_cast<double>(std::get<int64_t>(v));
	}
	return std::get<double>(v);
}
DORA_EXPORT int64_t call_stack_pop_str(int64_t stack) {
	return Str_Retain(std::get<std::string>(r_cast<CallStack*>(stack)->pop()));
}
DORA_EXPORT int32_t call_stack_pop_bool(int64_t stack) {
	return std::get<bool>(r_cast<CallStack*>(stack)->pop()) ? 1 : 0;
}
DORA_EXPORT int64_t call_stack_pop_object(int64_t stack) {
	return Object_From(std::get<Object*>(r_cast<CallStack*>(stack)->pop()));
}
DORA_EXPORT int64_t call_stack_pop_vec2(int64_t stack) {
	return Vec2_Retain(std::get<Vec2>(r_cast<CallStack*>(stack)->pop()));
}
DORA_EXPORT int64_t call_stack_pop_size(int64_t stack) {
	return Size_Retain(std::get<Size>(r_cast<CallStack*>(stack)->pop()));
}
DORA_EXPORT int32_t call_stack_pop(int64_t stack) {
	auto cs = r_cast<CallStack*>(stack);
	if (cs->empty()) return 0;
	cs->pop();
	return 1;
}
DORA_EXPORT int32_t call_stack_front_i64(int64_t stack) {
	return std::holds_alternative<int64_t>(r_cast<CallStack*>(stack)->front()) ? 1 : 0;
}
DORA_EXPORT int32_t call_stack_front_f64(int64_t stack) {
	const auto& v = r_cast<CallStack*>(stack)->front();
	return std::holds_alternative<int64_t>(v) || std::holds_alternative<double>(v) ? 1 : 0;
}
DORA_EXPORT int32_t call_stack_front_bool(int64_t stack) {
	return std::holds_alternative<bool>(r_cast<CallStack*>(stack)->front()) ? 1 : 0;
}
DORA_EXPORT int32_t call_stack_front_str(int64_t stack) {
	return std::holds_alternative<std::string>(r_cast<CallStack*>(stack)->front()) ? 1 : 0;
}
DORA_EXPORT int32_t call_stack_front_object(int64_t stack) {
	return std::holds_alternative<Object*>(r_cast<CallStack*>(stack)->front()) ? 1 : 0;
}
DORA_EXPORT int32_t call_stack_front_vec2(int64_t stack) {
	return std::holds_alternative<Vec2>(r_cast<CallStack*>(stack)->front()) ? 1 : 0;
}
DORA_EXPORT int32_t call_stack_front_size(int64_t stack) {
	return std::holds_alternative<Size>(r_cast<CallStack*>(stack)->front()) ? 1 : 0;
}

/* print */

DORA_EXPORT void dora_print(int64_t var) {
	LogInfoThreaded(*Str_From(var));
}

DORA_EXPORT void dora_print_warning(int64_t var) {
	LogWarnThreaded(*Str_From(var));
}

DORA_EXPORT void dora_print_error(int64_t var) {
	LogErrorThreaded(*Str_From(var));
}

/* Vec2 */

DORA_EXPORT int64_t vec2_add(int64_t a, int64_t b) {
	return Vec2_Retain(Vec2_From(a) + Vec2_From(b));
}
DORA_EXPORT int64_t vec2_sub(int64_t a, int64_t b) {
	return Vec2_Retain(Vec2_From(a) - Vec2_From(b));
}
DORA_EXPORT int64_t vec2_mul(int64_t a, int64_t b) {
	return Vec2_Retain(Vec2_From(a) * Vec2_From(b));
}
DORA_EXPORT int64_t vec2_mul_float(int64_t a, float b) {
	return Vec2_Retain(Vec2_From(a) * b);
}
DORA_EXPORT int64_t vec2_div(int64_t a, float b) {
	return Vec2_Retain(Vec2_From(a) / b);
}
DORA_EXPORT float vec2_distance(int64_t a, int64_t b) {
	return Vec2_From(a).distance(Vec2_From(b));
}
DORA_EXPORT float vec2_distance_squared(int64_t a, int64_t b) {
	return Vec2_From(a).distanceSquared(Vec2_From(b));
}
DORA_EXPORT float vec2_length(int64_t a) {
	return Vec2_From(a).length();
}
DORA_EXPORT float vec2_angle(int64_t a) {
	return Vec2_From(a).angle();
}
DORA_EXPORT int64_t vec2_normalize(int64_t a) {
	return Vec2_Retain(Vec2::normalize(Vec2_From(a)));
}
DORA_EXPORT int64_t vec2_perp(int64_t a) {
	return Vec2_Retain(Vec2::perp(Vec2_From(a)));
}
DORA_EXPORT float vec2_dot(int64_t a, int64_t b) {
	return Vec2_From(a).dot(Vec2_From(b));
}
DORA_EXPORT int64_t vec2_clamp(int64_t a, int64_t from, int64_t to) {
	auto b = Vec2_From(a);
	b.clamp(Vec2_From(from), Vec2_From(to));
	return Vec2_Retain(b);
}

/* emit */

DORA_EXPORT void dora_emit(int64_t name, int64_t stack) {
	auto args = r_cast<CallStack*>(stack);
	auto eventName = Str_From(name);
	WasmEventArgs::send(*eventName, args);
}

/* Array */

DORA_EXPORT int32_t array_set(int64_t array, int32_t index, int64_t v) {
	auto arr = r_cast<Array*>(array);
	if (0 <= index && index < s_cast<int32_t>(arr->getCount())) {
		arr->set(index, Value_To(*r_cast<dora_val_t*>(v)));
		return 1;
	}
	return 0;
}
DORA_EXPORT int64_t array_get(int64_t array, int32_t index) {
	auto arr = r_cast<Array*>(array);
	if (0 <= index && index < s_cast<int32_t>(arr->getCount())) {
		return Value_From(arr->get(index).get());
	}
	return 0;
}
DORA_EXPORT int64_t array_first(int64_t array) {
	auto arr = r_cast<Array*>(array);
	if (!arr->isEmpty()) {
		return Value_From(arr->getFirst().get());
	}
	return 0;
}
DORA_EXPORT int64_t array_last(int64_t array) {
	auto arr = r_cast<Array*>(array);
	if (!arr->isEmpty()) {
		return Value_From(arr->getLast().get());
	}
	return 0;
}
DORA_EXPORT int64_t array_random_object(int64_t array) {
	auto arr = r_cast<Array*>(array);
	if (!arr->isEmpty()) {
		return Value_From(arr->getRandomObject().get());
	}
	return 0;
}
DORA_EXPORT void array_add(int64_t array, int64_t item) {
	r_cast<Array*>(array)->add(Value_To(*r_cast<dora_val_t*>(item)));
}
DORA_EXPORT void array_insert(int64_t array, int32_t index, int64_t item) {
	r_cast<Array*>(array)->insert(index, Value_To(*r_cast<dora_val_t*>(item)));
}
DORA_EXPORT int32_t array_contains(int64_t array, int64_t item) {
	return r_cast<Array*>(array)->contains(Value_To(*r_cast<dora_val_t*>(item)).get()) ? 1 : 0;
}
DORA_EXPORT int32_t array_index(int64_t array, int64_t item) {
	return r_cast<Array*>(array)->index(Value_To(*r_cast<dora_val_t*>(item)).get());
}
DORA_EXPORT int64_t array_remove_last(int64_t array) {
	auto arr = r_cast<Array*>(array);
	if (arr->isEmpty()) return 0;
	return Value_From(r_cast<Array*>(array)->removeLast().get());
}
DORA_EXPORT int32_t array_fast_remove(int64_t array, int64_t item) {
	return r_cast<Array*>(array)->fastRemove(Value_To(*r_cast<dora_val_t*>(item)).get()) ? 1 : 0;
}

/* Dictionary */

DORA_EXPORT void dictionary_set(int64_t dict, int64_t key, int64_t value) {
	r_cast<Dictionary*>(dict)->set(*Str_From(key), Value_To(*r_cast<dora_val_t*>(value)));
}
DORA_EXPORT int64_t dictionary_get(int64_t dict, int64_t key) {
	return Value_From(r_cast<Dictionary*>(dict)->get(*Str_From(key)).get());
}

/* Content */

DORA_EXPORT int64_t content_load(int64_t filename) {
	auto result = SharedContent.load(*Str_From(filename));
	if (result.second > 0) {
		return Str_Retain({r_cast<char*>(result.first.get()), result.second});
	}
	return 0;
}

/* Entity */

DORA_EXPORT void entity_set(int64_t e, int64_t k, int64_t v) {
	r_cast<Entity*>(e)->set(*Str_From(k), Value_To(*r_cast<dora_val_t*>(v)));
}
DORA_EXPORT int64_t entity_get(int64_t e, int64_t k) {
	if (auto com = r_cast<Entity*>(e)->getComponent(*Str_From(k))) {
		return Value_From(com);
	} else {
		return 0;
	}
}
DORA_EXPORT int64_t entity_get_old(int64_t e, int64_t k) {
	if (auto com = r_cast<Entity*>(e)->getOldCom(*Str_From(k))) {
		return Value_From(com);
	} else {
		return 0;
	}
}

// EntityGroup

DORA_EXPORT void group_watch(int64_t group, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	auto entityGroup = r_cast<EntityGroup*>(group);
	entityGroup->watch([entityGroup, func, args, deref](Entity* e) {
		args->clear();
		args->push(e);
		for (int index : entityGroup->getComponents()) {
			CallStack_PushValue(args, e->getComponent(index));
		}
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	});
}

// EntityObserver

DORA_EXPORT void observer_watch(int64_t observer, int32_t func, int64_t stack) {
	std::shared_ptr<void> deref(nullptr, [func](auto) {
		SharedWasmRuntime.deref(func);
	});
	auto args = r_cast<CallStack*>(stack);
	auto entityObserver = r_cast<EntityObserver*>(observer);
	entityObserver->watch([entityObserver, func, args, deref](Entity* e) {
		args->clear();
		args->push(e);
		if (entityObserver->getEventType() != Entity::Remove) {
			for (int index : entityObserver->getComponents()) {
				CallStack_PushValue(args, e->getComponent(index));
			}
		}
		SharedWasmRuntime.invoke(func);
		return std::get<bool>(args->pop());
	});
}

// Blackboard

DORA_EXPORT void blackboard_set(int64_t b, int64_t k, int64_t v) {
	r_cast<Platformer::Behavior::Blackboard*>(b)->set(*Str_From(k), Value_To(*r_cast<dora_val_t*>(v)));
}
DORA_EXPORT int64_t blackboard_get(int64_t b, int64_t k) {
	if (auto value = r_cast<Platformer::Behavior::Blackboard*>(b)->get(*Str_From(k))) {
		return Value_From(value);
	} else {
		return 0;
	}
}

// Director

DORA_EXPORT int64_t director_get_scheduler() {
	return Object_From(SharedDirector.getScheduler());
}

DORA_EXPORT int64_t director_get_wasm_scheduler() {
	return Object_From(SharedWasmRuntime.getScheduler());
}

DORA_EXPORT int64_t director_get_post_scheduler() {
	return Object_From(SharedDirector.getScheduler());
}

DORA_EXPORT int64_t director_get_post_wasm_scheduler() {
	return Object_From(SharedWasmRuntime.getPostScheduler());
}

// math

DORA_EXPORT double math_abs(double v) { return std::abs(v); }
DORA_EXPORT float math_acos(float v) { return std::acos(v); }
DORA_EXPORT float math_asin(float v) { return std::asin(v); }
DORA_EXPORT float math_atan(float v) { return std::atan(v); }
DORA_EXPORT float math_atan2(float y, float x) { return std::atan2(y, x); }
DORA_EXPORT float math_ceil(float v) { return std::ceil(v); }
DORA_EXPORT float math_cos(float v) { return std::cos(v); }
DORA_EXPORT float math_deg(float v) { return bx::toDeg(v); }
DORA_EXPORT float math_exp(float v) { return std::exp(v); }
DORA_EXPORT float math_floor(float v) { return std::floor(v); }
DORA_EXPORT float math_fmod(float x, float y) { return std::fmod(x, y); }
DORA_EXPORT float math_log(float v) { return std::log(v); }
DORA_EXPORT float math_rad(float v) { return bx::toRad(v); }
DORA_EXPORT float math_sin(float v) { return std::sin(v); }
DORA_EXPORT float math_sqrt(float v) { return std::sqrt(v); }
DORA_EXPORT float math_tan(float v) { return std::tan(v); }

} // extern "C"

#include "Dora/ActionDefWasm.hpp"
#include "Dora/ActionWasm.hpp"
#include "Dora/AlignNodeWasm.hpp"
#include "Dora/ApplicationWasm.hpp"
#include "Dora/ArrayWasm.hpp"
#include "Dora/AudioWasm.hpp"
#include "Dora/AudioBusWasm.hpp"
#include "Dora/AudioSourceWasm.hpp"
#include "Dora/BodyDefWasm.hpp"
#include "Dora/BodyWasm.hpp"
#include "Dora/BufferWasm.hpp"
#include "Dora/C45Wasm.hpp"
#include "Dora/CacheWasm.hpp"
#include "Dora/Camera2DWasm.hpp"
#include "Dora/CameraOthoWasm.hpp"
#include "Dora/CameraWasm.hpp"
#include "Dora/ClipNodeWasm.hpp"
#include "Dora/ContentWasm.hpp"
#include "Dora/DBParamsWasm.hpp"
#include "Dora/DBQueryWasm.hpp"
#include "Dora/DBRecordWasm.hpp"
#include "Dora/DBWasm.hpp"
#include "Dora/DictionaryWasm.hpp"
#include "Dora/DirectorWasm.hpp"
#include "Dora/DragonBoneWasm.hpp"
#include "Dora/DrawNodeWasm.hpp"
#include "Dora/EaseWasm.hpp"
#include "Dora/EffectWasm.hpp"
#include "Dora/EffekNodeWasm.hpp"
#include "Dora/EntityGroupWasm.hpp"
#include "Dora/EntityObserverWasm.hpp"
#include "Dora/EntityWasm.hpp"
#include "Dora/FixtureDefWasm.hpp"
#include "Dora/GrabberWasm.hpp"
#include "Dora/GridWasm.hpp"
#include "Dora/HttpClientWasm.hpp"
#include "Dora/ImGuiWasm.hpp"
#include "Dora/JointDefWasm.hpp"
#include "Dora/JointWasm.hpp"
#include "Dora/KeyboardWasm.hpp"
#include "Dora/ControllerWasm.hpp"
#include "Dora/LabelWasm.hpp"
#include "Dora/LineWasm.hpp"
#include "Dora/MLQLearnerWasm.hpp"
#include "Dora/ModelWasm.hpp"
#include "Dora/MotorJointWasm.hpp"
#include "Dora/MouseWasm.hpp"
#include "Dora/MoveJointWasm.hpp"
#include "Dora/NVGpaintWasm.hpp"
#include "Dora/NodeWasm.hpp"
#include "Dora/ParticleNodeWasm.hpp"
#include "Dora/PassWasm.hpp"
#include "Dora/PathWasm.hpp"
#include "Dora/PhysicsWorldWasm.hpp"
#include "Dora/Platformer/Behavior/BlackboardWasm.hpp"
#include "Dora/Platformer/Behavior/LeafWasm.hpp"
#include "Dora/Platformer/BulletDefWasm.hpp"
#include "Dora/Platformer/BulletWasm.hpp"
#include "Dora/Platformer/DataWasm.hpp"
#include "Dora/Platformer/Decision/AIWasm.hpp"
#include "Dora/Platformer/Decision/LeafWasm.hpp"
#include "Dora/Platformer/FaceWasm.hpp"
#include "Dora/Platformer/PlatformCameraWasm.hpp"
#include "Dora/Platformer/PlatformWorldWasm.hpp"
#include "Dora/Platformer/TargetAllowWasm.hpp"
#include "Dora/Platformer/UnitActionWasm.hpp"
#include "Dora/Platformer/UnitWasm.hpp"
#include "Dora/Platformer/VisualWasm.hpp"
#include "Dora/Platformer/WasmActionUpdateWasm.hpp"
#include "Dora/PlayableWasm.hpp"
#include "Dora/RectWasm.hpp"
#include "Dora/RenderTargetWasm.hpp"
#include "Dora/SVGDefWasm.hpp"
#include "Dora/SchedulerWasm.hpp"
#include "Dora/SensorWasm.hpp"
#include "Dora/SpineWasm.hpp"
#include "Dora/SpriteEffectWasm.hpp"
#include "Dora/SpriteWasm.hpp"
#include "Dora/Texture2DWasm.hpp"
#include "Dora/TileNodeWasm.hpp"
#include "Dora/TouchWasm.hpp"
#include "Dora/VGNodeWasm.hpp"
#include "Dora/VertexColorWasm.hpp"
#include "Dora/ViewWasm.hpp"
#include "Dora/WorkBookWasm.hpp"
#include "Dora/WorkSheetWasm.hpp"
#include "Dora/nvgWasm.hpp"

NS_DORA_BEGIN

static void linkAutoModule(wasm3::module3& mod) {
	linkArray(mod);
	linkDictionary(mod);
	linkRect(mod);
	linkApplication(mod);
	linkDirector(mod);
	linkEntity(mod);
	linkEntityGroup(mod);
	linkEntityObserver(mod);
	linkWorkBook(mod);
	linkWorkSheet(mod);
	linkContent(mod);
	linkPath(mod);
	linkScheduler(mod);
	linkCamera(mod);
	linkCamera2D(mod);
	linkCameraOtho(mod);
	linkPass(mod);
	linkEffect(mod);
	linkSpriteEffect(mod);
	linkView(mod);
	linkActionDef(mod);
	linkAction(mod);
	linkGrabber(mod);
	linkNode(mod);
	linkTexture2D(mod);
	linkSprite(mod);
	linkGrid(mod);
	linkTouch(mod);
	linkEase(mod);
	linkLabel(mod);
	linkRenderTarget(mod);
	linkClipNode(mod);
	linkVertexColor(mod);
	linkDrawNode(mod);
	linkLine(mod);
	linkParticleNode(mod);
	linkPlayable(mod);
	linkModel(mod);
	linkSpine(mod);
	linkDragonBone(mod);
	linkAlignNode(mod);
	linkEffekNode(mod);
	linkTileNode(mod);
	linkPhysicsWorld(mod);
	linkFixtureDef(mod);
	linkBodyDef(mod);
	linkSensor(mod);
	linkBody(mod);
	linkJointDef(mod);
	linkJoint(mod);
	linkMoveJoint(mod);
	linkMotorJoint(mod);
	linkCache(mod);
	linkAudio(mod);
	linkAudioBus(mod);
	linkAudioSource(mod);
	linkKeyboard(mod);
	linkController(mod);
	linkMouse(mod);
	linkSVGDef(mod);
	linkDBQuery(mod);
	linkDBParams(mod);
	linkDBRecord(mod);
	linkDB(mod);
	linkC45(mod);
	linkMLQLearner(mod);
	linkHttpClient(mod);
	linkPlatformerTargetAllow(mod);
	linkPlatformerFace(mod);
	linkPlatformerBulletDef(mod);
	linkPlatformerBullet(mod);
	linkPlatformerVisual(mod);
	linkPlatformerBehaviorBlackboard(mod);
	linkPlatformerBehaviorLeaf(mod);
	linkPlatformerDecisionAI(mod);
	linkPlatformerDecisionLeaf(mod);
	linkPlatformerWasmActionUpdate(mod);
	linkPlatformerUnitAction(mod);
	linkPlatformerUnit(mod);
	linkPlatformerPlatformCamera(mod);
	linkPlatformerPlatformWorld(mod);
	linkPlatformerData(mod);
	linkBuffer(mod);
	linkImGui(mod);
	linkNVGpaint(mod);
	linknvg(mod);
	linkVGNode(mod);
}

static void linkDoraModule(wasm3::module3& mod) {
	linkAutoModule(mod);

	mod.link_optional("*", "str_new", str_new);
	mod.link_optional("*", "str_len", str_len);
	mod.link_optional("*", "str_read", str_read);
	mod.link_optional("*", "str_read_ptr", str_read_ptr);
	mod.link_optional("*", "str_write", str_write);
	mod.link_optional("*", "str_write_ptr", str_write_ptr);
	mod.link_optional("*", "str_release", str_release);

	mod.link_optional("*", "buf_new_i32", buf_new_i32);
	mod.link_optional("*", "buf_new_i64", buf_new_i64);
	mod.link_optional("*", "buf_new_f32", buf_new_f32);
	mod.link_optional("*", "buf_new_f64", buf_new_f64);
	mod.link_optional("*", "buf_len", buf_len);
	mod.link_optional("*", "buf_read", buf_read);
	mod.link_optional("*", "buf_read_ptr", buf_read_ptr);
	mod.link_optional("*", "buf_write", buf_write);
	mod.link_optional("*", "buf_write_ptr", buf_write_ptr);
	mod.link_optional("*", "buf_release", buf_release);

	mod.link_optional("*", "object_get_id", object_get_id);
	mod.link_optional("*", "object_get_type", object_get_type);
	mod.link_optional("*", "object_retain", object_retain);
	mod.link_optional("*", "object_release", object_release);

	mod.link_optional("*", "object_to_node", object_to_node);
	mod.link_optional("*", "object_to_camera", object_to_camera);
	mod.link_optional("*", "object_to_playable", object_to_playable);
	mod.link_optional("*", "object_to_physics_world", object_to_physics_world);
	mod.link_optional("*", "object_to_body", object_to_body);
	mod.link_optional("*", "object_to_joint", object_to_joint);

	mod.link_optional("*", "value_create_i64", value_create_i64);
	mod.link_optional("*", "value_create_f64", value_create_f64);
	mod.link_optional("*", "value_create_str", value_create_str);
	mod.link_optional("*", "value_create_bool", value_create_bool);
	mod.link_optional("*", "value_create_object", value_create_object);
	mod.link_optional("*", "value_create_vec2", value_create_vec2);
	mod.link_optional("*", "value_create_size", value_create_size);
	mod.link_optional("*", "value_release", value_release);
	mod.link_optional("*", "value_into_i64", value_into_i64);
	mod.link_optional("*", "value_into_f64", value_into_f64);
	mod.link_optional("*", "value_into_str", value_into_str);
	mod.link_optional("*", "value_into_bool", value_into_bool);
	mod.link_optional("*", "value_into_object", value_into_object);
	mod.link_optional("*", "value_into_vec2", value_into_vec2);
	mod.link_optional("*", "value_into_size", value_into_size);
	mod.link_optional("*", "value_is_i64", value_is_i64);
	mod.link_optional("*", "value_is_f64", value_is_f64);
	mod.link_optional("*", "value_is_str", value_is_str);
	mod.link_optional("*", "value_is_bool", value_is_bool);
	mod.link_optional("*", "value_is_object", value_is_object);
	mod.link_optional("*", "value_is_vec2", value_is_vec2);
	mod.link_optional("*", "value_is_size", value_is_size);

	mod.link_optional("*", "call_stack_create", call_stack_create);
	mod.link_optional("*", "call_stack_release", call_stack_release);
	mod.link_optional("*", "call_stack_push_i64", call_stack_push_i64);
	mod.link_optional("*", "call_stack_push_f64", call_stack_push_f64);
	mod.link_optional("*", "call_stack_push_str", call_stack_push_str);
	mod.link_optional("*", "call_stack_push_bool", call_stack_push_bool);
	mod.link_optional("*", "call_stack_push_object", call_stack_push_object);
	mod.link_optional("*", "call_stack_push_vec2", call_stack_push_vec2);
	mod.link_optional("*", "call_stack_push_size", call_stack_push_size);
	mod.link_optional("*", "call_stack_pop_i64", call_stack_pop_i64);
	mod.link_optional("*", "call_stack_pop_f64", call_stack_pop_f64);
	mod.link_optional("*", "call_stack_pop_str", call_stack_pop_str);
	mod.link_optional("*", "call_stack_pop_bool", call_stack_pop_bool);
	mod.link_optional("*", "call_stack_pop_object", call_stack_pop_object);
	mod.link_optional("*", "call_stack_pop_vec2", call_stack_pop_vec2);
	mod.link_optional("*", "call_stack_pop_size", call_stack_pop_size);
	mod.link_optional("*", "call_stack_pop", call_stack_pop);
	mod.link_optional("*", "call_stack_front_i64", call_stack_front_i64);
	mod.link_optional("*", "call_stack_front_f64", call_stack_front_f64);
	mod.link_optional("*", "call_stack_front_str", call_stack_front_str);
	mod.link_optional("*", "call_stack_front_bool", call_stack_front_bool);
	mod.link_optional("*", "call_stack_front_object", call_stack_front_object);
	mod.link_optional("*", "call_stack_front_vec2", call_stack_front_vec2);
	mod.link_optional("*", "call_stack_front_size", call_stack_front_size);

	mod.link_optional("*", "dora_print", dora_print);
	mod.link_optional("*", "dora_print_warning", dora_print_warning);
	mod.link_optional("*", "dora_print_error", dora_print_error);

	mod.link_optional("*", "vec2_add", vec2_add);
	mod.link_optional("*", "vec2_sub", vec2_sub);
	mod.link_optional("*", "vec2_mul", vec2_mul);
	mod.link_optional("*", "vec2_mul_float", vec2_mul_float);
	mod.link_optional("*", "vec2_div", vec2_div);
	mod.link_optional("*", "vec2_distance", vec2_distance);
	mod.link_optional("*", "vec2_distance_squared", vec2_distance_squared);
	mod.link_optional("*", "vec2_length", vec2_length);
	mod.link_optional("*", "vec2_angle", vec2_angle);
	mod.link_optional("*", "vec2_normalize", vec2_normalize);
	mod.link_optional("*", "vec2_perp", vec2_perp);
	mod.link_optional("*", "vec2_dot", vec2_dot);
	mod.link_optional("*", "vec2_clamp", vec2_clamp);

	mod.link_optional("*", "dora_emit", dora_emit);

	mod.link_optional("*", "content_load", content_load);

	mod.link_optional("*", "array_set", array_set);
	mod.link_optional("*", "array_get", array_get);
	mod.link_optional("*", "array_first", array_first);
	mod.link_optional("*", "array_last", array_last);
	mod.link_optional("*", "array_random_object", array_random_object);
	mod.link_optional("*", "array_add", array_add);
	mod.link_optional("*", "array_insert", array_insert);
	mod.link_optional("*", "array_contains", array_contains);
	mod.link_optional("*", "array_index", array_index);
	mod.link_optional("*", "array_remove_last", array_remove_last);
	mod.link_optional("*", "array_fast_remove", array_fast_remove);

	mod.link_optional("*", "dictionary_set", dictionary_set);
	mod.link_optional("*", "dictionary_get", dictionary_get);

	mod.link_optional("*", "entity_set", entity_set);
	mod.link_optional("*", "entity_get", entity_get);
	mod.link_optional("*", "entity_get_old", entity_get_old);

	mod.link_optional("*", "group_watch", group_watch);

	mod.link_optional("*", "observer_watch", observer_watch);

	mod.link_optional("*", "blackboard_set", blackboard_set);
	mod.link_optional("*", "blackboard_get", blackboard_get);

	mod.link_optional("*", "director_get_wasm_scheduler", director_get_wasm_scheduler);
	mod.link_optional("*", "director_get_post_wasm_scheduler", director_get_post_wasm_scheduler);

	mod.link_optional("*", "math_abs", math_abs);
	mod.link_optional("*", "math_acos", math_acos);
	mod.link_optional("*", "math_asin", math_asin);
	mod.link_optional("*", "math_atan", math_asin);
	mod.link_optional("*", "math_atan2", math_atan2);
	mod.link_optional("*", "math_ceil", math_ceil);
	mod.link_optional("*", "math_cos", math_cos);
	mod.link_optional("*", "math_deg", math_deg);
	mod.link_optional("*", "math_exp", math_exp);
	mod.link_optional("*", "math_floor", math_floor);
	mod.link_optional("*", "math_fmod", math_fmod);
	mod.link_optional("*", "math_log", math_log);
	mod.link_optional("*", "math_rad", math_rad);
	mod.link_optional("*", "math_sin", math_sin);
	mod.link_optional("*", "math_sqrt", math_sqrt);
	mod.link_optional("*", "math_tan", math_tan);
}

int WasmRuntime::_callFromWasm = 0;

WasmRuntime::WasmRuntime()
	: _loading(false) {
}

WasmRuntime::~WasmRuntime() { }

int32_t WasmRuntime::loadFuncs() {
	auto versionFunc = New<wasm3::function>(_runtime->find_function("dora_wasm_version"));
	auto version = versionFunc->call<int32_t>();
	_callFunc = New<wasm3::function>(_runtime->find_function("call_function"));
	_derefFunc = New<wasm3::function>(_runtime->find_function("deref_function"));
	return version;
}

bool WasmRuntime::executeMainFile(String filename) {
	if (_wasm.first || _loading) {
		Warn("only one WASM module can be executed");
		return false;
	}
	try {
		_loading = true;
		_callFromWasm++;
		DEFER({
			_callFromWasm--;
			_loading = false;
		});
		PROFILE("Loader"_slice, filename);
		{
			PROFILE("Loader"_slice, filename.toString() + " [Load]"s);
			_wasm = SharedContent.load(filename);
			_env = New<wasm3::environment>();
			_runtime = New<wasm3::runtime>(_env->new_runtime(DORA_WASM_STACK_SIZE));
			auto mod = _env->parse_module(_wasm.first.get(), _wasm.second);
			_runtime->load(mod);
			mod.link_default();
			linkDoraModule(mod);
			int32_t version = loadFuncs();
			if (doraWASMVersion != version) {
				_env = nullptr;
				_runtime = nullptr;
				_wasm = {nullptr, 0};
				Error("expecting dora WASM version {}, got {}", VersionToStr(doraWASMVersion), VersionToStr(version));
				return false;
			}
		}
		wasm3::function mainFn = _runtime->find_function("_start");
		scheduleUpdate();
		mainFn.call_argv();
		return true;
	} catch (std::runtime_error& e) {
		auto message = _runtime->get_error_message();
		Error("failed to load wasm module: {}, due to: {}{}", filename.toString(), e.what(), message == Slice::Empty ? ""s : ": "s + message);
		WasmRuntime::clear();
		return false;
	}
}

void WasmRuntime::executeMainFileAsync(String filename, const std::function<void(bool)>& handler) {
	if (_wasm.first || _loading) {
		Warn("only one wasm module can be executed, clear the current module before executing another");
		return;
	}
	_loading = true;
	auto file = filename.toString();
	SharedContent.loadAsyncData(filename, [file, handler, this](OwnArray<uint8_t>&& data, size_t size) {
		if (!data) {
			handler(false);
			_loading = false;
			Error("failed to load wasm file \"{}\".", file);
			return;
		}
		_wasm = {std::move(data), size};
		SharedAsyncThread.run(
			[file, this, doraVer = doraWASMVersion] {
				try {
					_env = New<wasm3::environment>();
					_runtime = New<wasm3::runtime>(_env->new_runtime(DORA_WASM_STACK_SIZE));
					auto mod = New<wasm3::module3>(_env->parse_module(_wasm.first.get(), _wasm.second));
					_runtime->load(*mod);
					mod->link_default();
					linkDoraModule(*mod);
					auto version = loadFuncs();
					if (doraVer != version) {
						Error("expecting dora WASM file of version {}, got {}", VersionToStr(doraVer), VersionToStr(version));
						_env = nullptr;
						_runtime = nullptr;
						_wasm = {nullptr, 0};
						return Values::alloc(Own<wasm3::module3>(), Own<wasm3::function>());
					}
					auto mainFn = New<wasm3::function>(_runtime->find_function("_start"));
					return Values::alloc(std::move(mod), std::move(mainFn));
				} catch (std::runtime_error& e) {
					auto message = _runtime->get_error_message();
					Error("failed to load wasm module: {}, due to: {}{}", file, e.what(), message == Slice::Empty ? ""s : ": "s + message);
					return Values::alloc(Own<wasm3::module3>(), Own<wasm3::function>());
				}
			},
			[file, handler, this](Own<Values> values) {
				try {
					_callFromWasm++;
					DEFER({
						_callFromWasm--;
						_loading = false;
					});
					PROFILE("Loader"_slice, file);
					Own<wasm3::module3> mod;
					Own<wasm3::function> mainFn;
					values->get(mod, mainFn);
					if (mod) {
						scheduleUpdate();
						mainFn->call_argv();
						handler(true);
					} else
						handler(false);
				} catch (std::runtime_error& e) {
					Error("failed to execute wasm module: {}, due to: {}{}", file, e.what(), _runtime->get_error_message() == Slice::Empty ? Slice::Empty : ": "s + _runtime->get_error_message());
					handler(false);
				}
			});
	});
}

enum class FuncType {
	StaticLinked = 0,
	WasmProvided = 1,
	CFuncPointer = 2,
	Unknown
};

void WasmRuntime::invoke(int32_t funcId) {
	auto funcType = s_cast<FuncType>(funcId >> 24);
	switch (funcType) {
		case FuncType::StaticLinked: {
			call_function(funcId);
			return;
		}
		case FuncType::WasmProvided: {
			AssertUnless(_callFunc, "wasm module is not ready");
			try {
				_callFromWasm++;
				DEFER(_callFromWasm--);
				_callFunc->call(funcId);
			} catch (std::runtime_error& e) {
				Error("failed to execute wasm callback due to: {}{}", e.what(), _runtime->get_error_message() == Slice::Empty ? Slice::Empty : ": "s + _runtime->get_error_message());
			}
			return;
		}
		case FuncType::CFuncPointer: {
			if (doraCallFunction) {
				doraCallFunction(funcId);
			}
			return;
		}
		default: {
			Issue("got unexpected func type {}", s_cast<int>(funcType));
			return;
		}
	}
}

void WasmRuntime::deref(int32_t funcId) {
	auto funcType = s_cast<FuncType>(funcId >> 24);
	switch (funcType) {
		case FuncType::StaticLinked: {
			deref_function(funcId);
			return;
		}
		case FuncType::WasmProvided: {
			if (_derefFunc) {
				_derefFunc->call(funcId);
			}
			return;
		}
		case FuncType::CFuncPointer: {
			if (doraDerefFunction) {
				doraDerefFunction(funcId);
			}
			return;
		}
		default: {
			Issue("got unexpected func type {}", s_cast<int>(funcType));
			return;
		}
	}
}

Scheduler* WasmRuntime::getScheduler() {
	AssertUnless(_scheduler, "should schedule WASM update before getting the scheduler");
	return _scheduler;
}

Scheduler* WasmRuntime::getPostScheduler() {
	AssertUnless(_postScheduler, "should schedule WASM update before getting the post scheduler");
	return _postScheduler;
}

uint32_t WasmRuntime::getMemorySize() const noexcept {
	uint32_t totalSize = 0;
	if (_wasm.first) {
		totalSize += _wasm.second;
	}
	if (_runtime) {
		totalSize += _runtime->get_memory_size() + DORA_WASM_STACK_SIZE;
	}
	return totalSize;
}

void WasmRuntime::unscheduleUpdate() {
	if (_scheduling) {
		*_scheduling = false;
		_scheduling = nullptr;
	}
	_scheduler = nullptr;
	_postScheduler = nullptr;
}

void WasmRuntime::scheduleUpdate() {
	unscheduleUpdate();
	_scheduling = std::make_shared<bool>(true);
	_scheduler = Scheduler::create();
	_postScheduler = Scheduler::create();
	SharedDirector.getScheduler()->schedule([scheduling = _scheduling, scheduler = WRef<Scheduler>(_scheduler)](double deltaTime) {
		if (!*scheduling) {
			return true;
		}
		if (scheduler) {
			scheduler->update(deltaTime);
			return false;
		}
		return true;
	});
	SharedDirector.getPostScheduler()->schedule([scheduling = _scheduling, scheduler = WRef<Scheduler>(_postScheduler)](double deltaTime) {
		if (!*scheduling) {
			return true;
		}
		if (scheduler) {
			scheduler->update(deltaTime);
			return false;
		}
		return true;
	});
}

void WasmRuntime::clear() {
	unscheduleUpdate();
	_callFunc = nullptr;
	_derefFunc = nullptr;
	_runtime = nullptr;

	_env = nullptr;
	_runtime = nullptr;
	_wasm = {nullptr, 0};
}

bool WasmRuntime::isInWasm() {
	return _callFromWasm > 0;
}

uint8_t* WasmRuntime::getMemoryAddress(int32_t wasmAddr) {
	return _runtime->get_address(wasmAddr);
}

void WasmRuntime::buildWaAsync(String fullPath, const std::function<void(String)>& callback) {
#ifdef DORA_NO_WA
	DORA_UNUSED_PARAM(fullPath);
	Error("Wa build not supported");
	callback("Wa build not supported"s);
#else // !DORA_NO_WA
#if BX_PLATFORM_ANDROID
	SharedApplication.invokeInRender([fullPath = fullPath.toString(), callback]() {
		auto result = WaBuild(c_cast<char*>(fullPath.c_str()));
		SharedApplication.invokeInLogic([str = std::string(result), callback]() {
			callback(str);
		});
		WaFreeCString(result);
	});
#else // BX_PLATFORM_ANDROID
	if (!_thread) {
		_thread = SharedAsyncThread.newThread();
	}
	_thread->run([fullPath = fullPath.toString()]() {
		auto result = WaBuild(c_cast<char*>(fullPath.c_str()));
		std::string data(result);
		WaFreeCString(result);
		return Values::alloc(std::move(data));
	}, [callback](Own<Values> values) {
		std::string data;
		values->get(data);
		callback(data);
	});
#endif // BX_PLATFORM_ANDROID
#endif // !DORA_NO_WA
}

void WasmRuntime::formatWaAsync(String fullPath, const std::function<void(String)>& callback) {
#ifdef DORA_NO_WA
	DORA_UNUSED_PARAM(fullPath);
	Error("Wa format not supported");
	callback(Slice::Empty);
#else // !DORA_NO_WA
#if BX_PLATFORM_ANDROID
	SharedApplication.invokeInRender([fullPath = fullPath.toString(), callback]() {
		auto result = WaFormat(c_cast<char*>(fullPath.c_str()));
		SharedApplication.invokeInLogic([str = std::string(result), callback]() {
			callback(str);
		});
		WaFreeCString(result);
	});
#else // BX_PLATFORM_ANDROID
	if (!_thread) {
		_thread = SharedAsyncThread.newThread();
	}
	_thread->run([fullPath = fullPath.toString()]() {
		auto result = WaFormat(c_cast<char*>(fullPath.c_str()));
		std::string data(result);
		WaFreeCString(result);
		return Values::alloc(std::move(data));
	}, [callback](Own<Values> values) {
		std::string data;
		values->get(data);
		callback(data);
	});
#endif // BX_PLATFORM_ANDROID
#endif // !DORA_NO_WA
}

NS_DORA_END
