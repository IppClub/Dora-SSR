/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node3D.h"

NS_DORA_BEGIN

class Model3DDef;

class Model3D : public Node3D {
public:
	PROPERTY(float, Speed);
	PROPERTY_READONLY(float, Duration);
	PROPERTY_READONLY(float, Elapsed);
	PROPERTY_READONLY_BOOL(Playing);
	PROPERTY_READONLY_BOOL(Paused);
	virtual bool init() override;
	float play(String name = String{}, bool loop = false);
	void stop();
	void pause();
	void resume();
	virtual void cleanup() override;
	bool update(double deltaTime) override;
	CREATE_FUNC_NOT_NULL(Model3D);

protected:
	Model3D(String path);
	Model3D();
	virtual ~Model3D();

private:
	void destroyInstance();
	std::string _filename;
	Ref<Model3DDef> _modelDef;
	uint64_t _instance;
	bool _playing;
	bool _paused;
	DORA_TYPE_OVERRIDE(Model3D);
};

NS_DORA_END
