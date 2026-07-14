/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Effect/Material.h"

NS_DORA_BEGIN

Material::Material()
	: _type(MaterialType::Unlit)
	, _transparent(false)
	, _doubleSided(false)
	, _depthTest(true)
	, _depthWrite(true)
	, _baseColor(Color::White)
	, _metallic(0.0f)
	, _roughness(1.0f)
	, _alphaCutoff(0.5f) { }

void Material::setType(MaterialType var) {
	_type = var;
}

MaterialType Material::getType() const noexcept {
	return _type;
}

void Material::setTransparent(bool var) {
	_transparent = var;
}

bool Material::isTransparent() const noexcept {
	return _transparent;
}

void Material::setDoubleSided(bool var) {
	_doubleSided = var;
}

bool Material::isDoubleSided() const noexcept {
	return _doubleSided;
}

void Material::setDepthTest(bool var) {
	_depthTest = var;
}

bool Material::isDepthTest() const noexcept {
	return _depthTest;
}

void Material::setDepthWrite(bool var) {
	_depthWrite = var;
}

bool Material::isDepthWrite() const noexcept {
	return _depthWrite;
}

void Material::setBaseColor(Color var) {
	_baseColor = var;
	setVec4("u_baseColor"_slice, var.toVec4());
}

Color Material::getBaseColor() const noexcept {
	return _baseColor;
}

void Material::setMetallic(float var) {
	_metallic = var;
}

float Material::getMetallic() const noexcept {
	return _metallic;
}

void Material::setRoughness(float var) {
	_roughness = var;
}

float Material::getRoughness() const noexcept {
	return _roughness;
}

void Material::setAlphaCutoff(float var) {
	_alphaCutoff = var;
	setFloat("u_alphaCutoff"_slice, var);
}

float Material::getAlphaCutoff() const noexcept {
	return _alphaCutoff;
}

const RefVector<Pass>& Material::getPasses() const noexcept {
	return _passes;
}

void Material::add(Pass* pass) {
	if (pass) {
		_passes.push_back(pass);
	}
}

Pass* Material::getPass(uint32_t index) const {
	return index < _passes.size() ? _passes[index].get() : nullptr;
}

void Material::clear() {
	_passes.clear();
	_textures.clear();
}

void Material::setTexture(String slot, Texture2D* texture, uint8_t stage) {
	std::string name = slot.toString();
	_textures[name] = texture;
	for (Pass* pass : _passes) {
		pass->set(slot, texture, stage);
	}
}

Texture2D* Material::getTexture(String slot) const {
	auto it = _textures.find(slot.toString());
	return it != _textures.end() ? it->second.get() : nullptr;
}

void Material::setFloat(String name, float value) {
	for (Pass* pass : _passes) {
		pass->set(name, value);
	}
}

void Material::setVec4(String name, const Vec4& value) {
	for (Pass* pass : _passes) {
		pass->set(name, value);
	}
}

void Material::setMatrix(String name, const Matrix& value) {
	for (Pass* pass : _passes) {
		pass->set(name, value);
	}
}

NS_DORA_END
