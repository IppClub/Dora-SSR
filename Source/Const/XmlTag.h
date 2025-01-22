/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

NS_DORA_BEGIN

namespace Xml {

namespace Clip {
enum struct Element {
	Dorothy = 'A',
	Clip = 'B',
};

enum struct Dorothy {
	File = 'A',
};

enum struct Clip {
	Name = 'A',
	Rect = 'B',
};
} // namespace Clip

enum struct Particle {
	Dorothy = 'A',
	Angle = 'B', // float
	AngleVariance = 'C', // float
	BlendFuncDestination = 'D', // uint32_t
	BlendFuncSource = 'E', // uint32_t
	Duration = 'F', // float
	EmissionRate = 'G', // float
	FinishColor = 'H', // Vec4
	FinishColorVariance = 'I', // Vec4
	RotationStart = 'J', // float
	RotationStartVariance = 'K', // float
	RotationEnd = 'L', // float
	RotationEndVariance = 'M', // float
	FinishParticleSize = 'N', // float
	FinishParticleSizeVariance = 'O', // float
	MaxParticles = 'P', // uint32_t
	ParticleLifespan = 'Q', // float
	ParticleLifespanVariance = 'R', // float
	StartPosition = 'S', // Vec2
	StartPositionVariance = 'T', // Vec2
	StartColor = 'U', // Vec4
	StartColorVariance = 'V', // Vec4
	StartParticleSize = 'W', // float
	StartParticleSizeVariance = 'X', // float
	TextureName = 'Y', // string
	TextureRect = 'Z', // Rect
	EmitterMode = 'a', // EmitterType
	/* gravity */
	RotationIsDir = 'b', // bool
	Gravity = 'c', // Vec2
	Speed = 'd', // float
	SpeedVariance = 'e', // float
	RadialAcceleration = 'f', // float
	RadialAccelVariance = 'g', // float
	TangentialAcceleration = 'h', // float
	TangentialAccelVariance = 'i', // float
	/* radius */
	StartRadius = 'j', // float
	StartRadiusVariance = 'k', // float
	FinishRadius = 'l', // float
	FinishRadiusVariance = 'm', // float
	RotatePerSecond = 'n', // float
	RotatePerSecondVariance = 'o', // float
};

namespace Visual {
enum struct Element {
	Dorothy = 'A',
	Visual = 'B',
};

enum struct Visual {
	Name = 'A',
	File = 'B',
};
} // namespace Visual

namespace Frame {
enum struct Element {
	Dorothy = 'A',
	Clip = 'B',
};

enum struct Dorothy {
	File = 'A',
	Duration = 'B',
};

enum struct Clip {
	Rect = 'A',
};
}; // namespace Frame

namespace Model {
enum struct Element {
	Dorothy = 'A',
	Sprite = 'B',
	KeyAnimation = 'C',
	KeyFrame = 'D',
	FrameAnimation = 'E',
	Look = 'F',
	LookName = 'I',
	AnimationName = 'J',
	KeyPoint = 'K',
};

enum struct Dorothy {
	File = 'A',
	Size = 'D',
};

enum struct Sprite {
	Key = 'A',
	Opacity = 'C',
	Position = 'D',
	Scale = 'E',
	Rotation = 'F',
	Skew = 'G',
	Name = 'H',
	Clip = 'I',
	Front = 'J',
};

enum struct KeyFrame {
	Duration = 'A',
	Visible = 'B',
	Opacity = 'C',
	Position = 'D',
	Scale = 'E',
	Rotation = 'F',
	Skew = 'G',
	EaseOpacity = 'H',
	EasePos = 'I',
	EaseScale = 'J',
	EaseRotate = 'K',
	EaseSkew = 'L',
	Event = 'M',
};

enum struct FrameAnimation {
	File = 'A',
	Delay = 'B',
};

enum struct Look {
	Name = 'H',
};

enum struct LookName {
	Index = 'C',
	Name = 'H'
};

enum struct AnimationName {
	Index = 'C',
	Name = 'H'
};

enum struct KeyPoint {
	Key = 'A',
	Position = 'B'
};
}; // namespace Model

} // namespace Xml

NS_DORA_END
