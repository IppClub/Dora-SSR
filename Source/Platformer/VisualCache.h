/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Node/Node.h"
#include "Other/rapidxml_sax3.hpp"

NS_DOROTHY_BEGIN
class ParticleNode;
class Sprite;
class Action;
NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN

class Visual : public Node
{
public:
	virtual void start() = 0;
	virtual bool isPlaying() = 0;
	virtual void stop() = 0;
	virtual Visual* autoRemove() = 0;
	static Visual* create(String name);
	DORA_TYPE_OVERRIDE(Visual);
};

class ParticleVisual : public Visual
{
public:
	virtual void start() override;
	virtual bool isPlaying() override;
	virtual void stop() override;
	virtual Visual* autoRemove() override;
	virtual bool init() override;
	ParticleNode* getParticle() const;
	CREATE_FUNC(ParticleVisual);
protected:
	ParticleVisual(String filename);
private:
	WRef<ParticleNode> _particle;
};

class SpriteVisual : public Visual
{
public:
	virtual void start() override;
	virtual bool isPlaying() override;
	virtual void stop() override;
	virtual Visual* autoRemove() override;
	virtual bool init() override;
	Sprite* getSprite() const;
	CREATE_FUNC(SpriteVisual);
protected:
	SpriteVisual(String filename);
private:
	bool _isAutoRemoved;
	Ref<Sprite> _sprite;
	Ref<Action> _action;
};

/** @brief Data define type for visual item. */
class VisualType : public Object
{
public:
	enum {Unkown = 0, Particle = 1, Frame = 2};
	VisualType(String filename);
	/** Get a running effect instance of this effect type. */
	Visual* toVisual() const;
	const string& getFilename() const;
private:
	string _file;
	Uint32 _type;
};

/** @brief The visual interface class for loading and creating visual item instance.
 There are two types of visuals, particle and frame animation which is a sequence of image changes in a row.
 The particle file ends with ".par" and the frame animation file ends with ".frame".
*/
class VisualCache : public rapidxml::xml_sax2_handler
{
public:
	~VisualCache();
	/** Load an visual item file into memory. */
	bool load(String filename);
	bool update(String content);
	/** Clear all visual item data from memory. */
	bool unload();
	/** Create a new visual item instance. */
	Visual* create(String name);
	const string& getFileByName(String name);
protected:
	VisualCache();
private:
	virtual void xmlSAX2StartElement(const char* name, size_t len, const vector<AttrSlice>& attrs) override;
	virtual void xmlSAX2EndElement(const char* name, size_t len) override;
	virtual void xmlSAX2Text(const char* s, size_t len) override;
	unordered_map<string, Own<VisualType>> _visuals;
	string _path;
	rapidxml::xml_sax3_parser<> _parser;
	SINGLETON_REF(VisualCache, Director);
};

#define SharedVisualCache \
	Dorothy::Singleton<Dorothy::Platformer::VisualCache>::shared()

NS_DOROTHY_PLATFORMER_END
