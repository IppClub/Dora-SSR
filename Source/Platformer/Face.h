/* Copyright (c) 2018 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DOROTHY_BEGIN
class Node;
NS_DOROTHY_END

NS_DOROTHY_PLATFORMER_BEGIN

/** @brief A face is a combination of sprites and particles.
 When a face is removing, its particles stop emitting and its sprites are all hide.
 And later the entire face is truly removed from memory once it gets totally invisible.  

 Faces can attach to each other just as nodes.

 Faces can be 1 of 6 types:
	Face::Unkown  0
	Face::Clip         1
	Face::Image     2
	Face::Frame     3
	Face::Particle   4
	Face::Custom   5

 Face is just data define, use toNode() method to get visible instance.
*/
class Face : public Object
{
public:
	enum {Unknown = 0, Clip = 1, Image = 2, Frame = 3, Particle = 4, Custom = 5};
	void addChild(Face* face);
	bool removeChild(Face* face);
	/** Get a new instance of the face. */
	Node* toNode();
	/** Type of face, Unknown, Clip, Image, Frame, Particle, User. */
	uint32 getType() const;
	/** Different type has different faceStr:
	     enum      type             faceStr
          1             Clip            "loli.clip|0"
          2             Image        "loli.png"
          3             Frame        "loli.frame", "loli.png::60,60,5,0.8" or "loli.clip|0::60,60,5,0.8"
          4             Particle      "loli.par"
	*/
	CREATE_FUNC(Face);
private:
	Face(String file, const Vec2& point, float scale, float angle);
	Face(const function<Node*()>& func, const Vec2& point, float scale, float angle);
	string _file;
	Uint32 _type;
	float _scale;
	Vec2 _pos;
	float _angle;
	function<Node*()> _userCreateFunc;
	RefVector<Face> _children;
	DORA_TYPE_OVERRIDE(Face);
};

NS_DOROTHY_PLATFORMER_END
