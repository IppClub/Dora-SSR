/*********************************************************************
Matt Marchant 2016 - 2023
http://trederia.blogspot.com

tmxlite - Zlib license.

This software is provided 'as-is', without any express or
implied warranty. In no event will the authors be held
liable for any damages arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute
it freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented;
you must not claim that you wrote the original software.
If you use this software in a product, an acknowledgment
in the product documentation would be appreciated but
is not required.

2. Altered source versions must be plainly marked as such,
and must not be misrepresented as being the original software.

3. This notice may not be removed or altered from any
source distribution.
*********************************************************************/

template <typename T>
Vector2<T> operator + (const Vector2<T>& l, const Vector2<T>& r)
{
    return { l.x + r.x, l.y + r.y };
}

template <typename T>
Vector2<T>& operator += (Vector2<T>& l, const Vector2<T>& r)
{
    l.x += r.x;
    l.y += r.y;
    return l;
}

template <typename T>
Vector2<T> operator - (const Vector2<T>& l, const Vector2<T>& r)
{
    return { l.x - r.x, l.y - r.y };
}

template <typename T>
Vector2<T>& operator -= (Vector2<T>& l, const Vector2<T>& r)
{
    l.x -= r.x;
    l.y -= r.y;
    return l;
}

template <typename T>
Vector2<T> operator * (const Vector2<T>& l, const Vector2<T>& r)
{
    return { l.x * r.x, l.y * r.y };
}

template <typename T>
Vector2<T>& operator *= (Vector2<T>& l, const Vector2<T>& r)
{
    l.x *= r.x;
    l.y *= r.y;
    return l;
}

template <typename T>
Vector2<T> operator * (const Vector2<T>& l, T r)
{
    return { l.x * r, l.y * r };
}

template <typename T>
Vector2<T>& operator *= (Vector2<T>& l, T r)
{
    l.x *= r;
    l.y *= r;
    return l;
}

template <typename T>
Vector2<T> operator / (const Vector2<T>& l, const Vector2<T>& r)
{
    return { l.x / r.x, l.y / r.y };
}

template <typename T>
Vector2<T>& operator /= (Vector2<T>& l, const Vector2<T>& r)
{
    l.x /= r.x;
    l.y /= r.y;
    return l;
}

template <typename T>
Vector2<T> operator / (const Vector2<T>& l, T r)
{
    return { l.x / r, l.y / r };
}

template <typename T>
Vector2<T>& operator /= (Vector2<T>& l, T r)
{
    l.x /= r;
    l.y /= r;
    return l;
}