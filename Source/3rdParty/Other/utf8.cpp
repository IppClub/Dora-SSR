// Copyright (c) 2008-2009 Bjoern Hoehrmann <bjoern@hoehrmann.de>
// See http://bjoern.hoehrmann.de/utf-8/decoder/dfa/ for details.
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

#include "Other/utf8.h"
#include <cctype>
#include <cstring>

static const uint8_t s_utf8d[364] =
{
	// The first part of the table maps bytes to character classes that
	// to reduce the size of the transition table and create bitmasks.
	 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,  9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,
	 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,  7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,
	 8,8,2,2,2,2,2,2,2,2,2,2,2,2,2,2,  2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
	10,3,3,3,3,3,3,3,3,3,3,3,3,4,3,3, 11,6,6,6,5,8,8,8,8,8,8,8,8,8,8,8,

	// The second part is a transition table that maps a combination
	// of a state of the automaton and a character class to a state.
	 0,12,24,36,60,96,84,12,12,12,48,72, 12,12,12,12,12,12,12,12,12,12,12,12,
	12, 0,12,12,12,12,12, 0,12, 0,12,12, 12,24,12,12,12,12,12,24,12,24,12,12,
	12,12,12,12,12,12,12,24,12,12,12,12, 12,24,12,12,12,12,12,12,12,24,12,12,
	12,12,12,12,12,12,12,36,12,36,12,12, 12,36,12,12,12,12,12,36,12,36,12,12,
	12,36,12,12,12,12,12,12,12,12,12,12
};

uint32_t utf8_decode(uint32_t* _state, uint32_t* _codep, uint8_t _ch)
{
	uint32_t byte = _ch;
	uint32_t type = s_utf8d[byte];

	*_codep = (*_state != UTF8_ACCEPT) ?
		(byte & 0x3fu) | (*_codep << 6) :
		(0xff >> type) & (byte);

	*_state = s_utf8d[256 + *_state + type];
	return *_state;
}

int utf8_count_characters(const char* utf8str)
{
	uint32_t codepoint = 0;
	uint32_t state = 0;
	int count = 0;
	const char* str = utf8str;
	const char* end = str + strlen(str);
	for (; *str && str < end; ++str)
	{
		if (utf8_decode(&state, &codepoint, *str) == UTF8_ACCEPT)
		{
			count++;
		}
	}
	return state == UTF8_ACCEPT ? count : 0;
}

std::vector<uint32_t> utf8_get_characters(const char* utf8str)
{
	std::vector<uint32_t> characters;
	uint32_t codepoint = 0;
	uint32_t state = UTF8_ACCEPT;
	const char* str = utf8str;
	const char* end = str + strlen(str);
	for (; *str && str < end; ++str)
	{
		if (utf8_decode(&state, &codepoint, *str) == UTF8_ACCEPT)
		{
			characters.push_back(codepoint);
		}
	}
	if (state != UTF8_ACCEPT)
	{
		characters.clear();
	}
	return characters;
}

void utf8_each_character(const char* utf8str, const std::function<bool(int, uint32_t)>& callback)
{
	uint32_t codepoint = 0;
	uint32_t state = UTF8_ACCEPT;
	const char* str = utf8str;
	const char* end = str + strlen(str);
	for (; *str && str < end; ++str)
	{
		if (utf8_decode(&state, &codepoint, *str) == UTF8_ACCEPT)
		{
			if (callback((int)(str - utf8str), codepoint))
			{
				return;
			}
		}
	}
}

bool utf8_isspace(uint32_t ch)
{
	return  (ch >= 0x0009 && ch <= 0x000D) || ch == 0x0020 || ch == 0x0085 || ch == 0x00A0 || ch == 0x1680
		|| (ch >= 0x2000 && ch <= 0x200A) || ch == 0x2028 || ch == 0x2029 || ch == 0x202F
		|| ch == 0x205F || ch == 0x3000;
}

static void utf8_trim_from(std::vector<uint32_t>& str, int index)
{
	int size = (int)str.size();
	if (index >= size || index < 0)
	{
		return;
	}
	str.erase(str.begin() + index, str.begin() + size);
}

void utf8_trim_ws(std::vector<uint32_t>& str)
{
	if (str.empty())
	{
		return;
	}
	int last_index = (int)str.size() - 1;
	// Only start trimming if the last character is whitespace..
	if (utf8_isspace(str[last_index]))
	{
		for (int i = last_index - 1; i >= 0; --i)
		{
			if (utf8_isspace(str[i]))
			{
				last_index = i;
			}
			else
			{
				break;
			}
		}
		utf8_trim_from(str, last_index);
	}
}

uint32_t utf8_find_last_not_char(const std::vector<uint32_t>& str, uint32_t ch)
{
	int len = (int)str.size();
	int i = len - 1;
	for (; i >= 0; --i)
	{
		if (str[i] != ch)
		{
			return i;
		}
	}
	return i;
}

uint32_t utf8_find_last_not_alnum(const std::vector<uint32_t>& str)
{
	int len = (int)str.size();
	int i = len - 1;
	for (; i >= 0; --i)
	{
		if (str[i] > 255 || !std::isalnum(str[i]))
		{
			return i;
		}
	}
	return i;
}
