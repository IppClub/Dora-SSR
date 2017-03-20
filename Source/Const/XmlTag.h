/* Copyright (c) 2017 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Common/Utils.h"

NS_DOROTHY_BEGIN

namespace Xml
{

namespace Clip
{
	ENUM_START(Element)
	{
		Dorothy = 'A',
		Clip = 'B',
	}
	ENUM_END(Element)

	ENUM_START(Dorothy)
	{
		File = 'A',
	}
	ENUM_END(Dorothy)

	ENUM_START(Clip)
	{
		Name = 'A',
		Rect = 'B',
	}
	ENUM_END(Clip)
}

namespace Effect
{
	ENUM_START(Element)
	{
		Dorothy = 'A',
		Effect = 'B',
	}
	ENUM_END(Element)

	ENUM_START(Effect)
	{
		Name = 'A',
		File = 'B',
	}
	ENUM_END(Effect)
};

namespace Frame
{
	ENUM_START(Element)
	{
		Dorothy = 'A',
		Clip = 'B',
	}
	ENUM_END(Element)

	ENUM_START(Dorothy)
	{
		File = 'A',
		Duration = 'B',
	}
	ENUM_END(Dorothy)

	ENUM_START(Clip)
	{
		Rect = 'A',
	}
	ENUM_END(Clip)
};

namespace Model
{
	ENUM_START(Element)
	{
		Dorothy = 'A',
		Sprite = 'B',
		KeyAnimation = 'C',
		KeyFrame = 'D',
		FrameAnimation = 'E',
		Look = 'F',
		Sound = 'G',
		Track = 'H',
		LookName = 'I',
		AnimationName = 'J',
		KeyPoint = 'K',
	}
	ENUM_END(Element)

	ENUM_START(Dorothy)
	{
		File = 'A',
		FaceRight = 'B',
		Size = 'D',
	}
	ENUM_END(Dorothy)

	ENUM_START(Sprite)
	{
		Key = 'A',
		Visible = 'B',
		Opacity = 'C',
		Position = 'D',
		Scale = 'E',
		Rotation = 'F',
		Skew = 'G',
		Name = 'H',
		Clip = 'I',
		Front = 'J',
	}
	ENUM_END(Sprite)

	ENUM_START(KeyFrame)
	{
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
	}
	ENUM_END(KeyFrame)

	ENUM_START(FrameAnimation)
	{
		File = 'A',
		Delay = 'B',
	}
	ENUM_END(FrameAnimation)

	ENUM_START(Look)
	{
		Name = 'H',
	}
	ENUM_END(Look)

	ENUM_START(Track)
	{
		File = 'A',
	}
	ENUM_END(Track)

	ENUM_START(LookName)
	{
		Index = 'C',
		Name = 'H'
	}
	ENUM_END(LookName)

	ENUM_START(AnimationName)
	{
		Index = 'C',
		Name = 'H'
	}
	ENUM_END(AnimationName)

	ENUM_START(KeyPoint)
	{
		Key = 'A',
		Position = 'B'
	}
	ENUM_END(KeyPoint)
};

} // namespace Xml

NS_DOROTHY_END
