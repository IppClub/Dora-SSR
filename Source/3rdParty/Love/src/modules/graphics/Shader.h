/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Altered for Dora: this keeps LOVE 11.5's public Shader uniform contract
 * while shader compilation, reflection, and submission are supplied by the
 * state-local Dora graphics backend.
 */

#pragma once

#include "common/Object.h"
#include "Texture.h"

#include <cstddef>
#include <string>

namespace love::graphics
{

class Shader : public Object
{
public:
	static love::Type type;

	enum UniformType
	{
		UNIFORM_FLOAT,
		UNIFORM_MATRIX,
		UNIFORM_INT,
		UNIFORM_UINT,
		UNIFORM_BOOL,
		UNIFORM_SAMPLER,
		UNIFORM_UNKNOWN,
		UNIFORM_MAX_ENUM
	};

	struct MatrixSize
	{
		short columns = 0;
		short rows = 0;
	};

	struct UniformInfo
	{
		int location = -1;
		int count = 0;
		union
		{
			int components;
			MatrixSize matrix;
		};
		UniformType baseType = UNIFORM_UNKNOWN;
		TextureType textureType = TEXTURE_2D;
		bool isDepthSampler = false;
		std::string name;
		union
		{
			void *data;
			float *floats;
			int *ints;
			unsigned int *uints;
		};
		std::size_t dataSize = 0;
		Texture **textures = nullptr;

		UniformInfo() : components(0), data(nullptr) { }
	};

	virtual ~Shader() = default;
	virtual std::string getWarnings() const = 0;
	virtual const UniformInfo *getUniformInfo(const std::string &name) const = 0;
	virtual void updateUniform(const UniformInfo *info, int count,
		bool colors = false) = 0;
	virtual void sendTextures(const UniformInfo *info, Texture **textures,
		int count) = 0;
	virtual bool hasUniform(const std::string &name) const = 0;
};

} // namespace love::graphics
