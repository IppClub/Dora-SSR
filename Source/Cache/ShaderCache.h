/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN

class Shader : public Object {
public:
	PROPERTY_READONLY(bgfx::ShaderHandle, Handle);
	virtual ~Shader();
	CREATE_FUNC_NOT_NULL(Shader);

protected:
	Shader(bgfx::ShaderHandle handle);

private:
	bgfx::ShaderHandle _handle;
};

class ShaderCache : public NonCopyable {
public:
	virtual ~ShaderCache() { }
	void update(String name, Shader* shader);
	/** @brief fragment or vertex shader */
	Shader* load(String filename);
	void loadAsync(String filename, const std::function<void(Shader*)>& handler);
	bool unload(Shader* shader);
	bool unload(String filename);
	bool unload();
	void removeUnused();

protected:
	ShaderCache();
	std::string getShaderPath() const;

private:
	StringMap<Ref<Shader>> _shaders;
	SINGLETON_REF(ShaderCache, BGFXDora);
};

#define SharedShaderCache \
	Dora::Singleton<Dora::ShaderCache>::shared()

NS_DORA_END
