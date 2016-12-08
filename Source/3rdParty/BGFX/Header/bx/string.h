/*
 * Copyright 2010-2016 Branimir Karadzic. All rights reserved.
 * License: https://github.com/bkaradzic/bx#license-bsd-2-clause
 */

#ifndef BX_STRING_H_HEADER_GUARD
#define BX_STRING_H_HEADER_GUARD

#include "bx.h"
#include <alloca.h>
#include <ctype.h>  // tolower
#include <stdarg.h> // va_list
#include <stdio.h>  // vsnprintf, vsnwprintf
#include <string.h>
#include <wchar.h>  // wchar_t

#include "bx/allocator.h"
#include "bx/hash.h"

#ifndef va_copy
#	define va_copy(_a, _b) (_a) = (_b)
#endif // va_copy

namespace bx
{
	///
	inline bool toBool(const char* _str)
	{
		char ch = (char)::tolower(_str[0]);
		return ch == 't' ||  ch == '1';
	}

	/// Case insensitive string compare.
	inline int32_t stricmp(const char* _a, const char* _b)
	{
#if BX_CRT_MSVC
		return ::_stricmp(_a, _b);
#else
		return ::strcasecmp(_a, _b);
#endif // BX_COMPILER_
	}

	///
	inline size_t strnlen(const char* _str, size_t _max)
	{
		const char* ptr;
		for (ptr = _str; 0 < _max && *ptr != '\0'; ++ptr, --_max) {};
		return ptr - _str;
	}

	/// Copy _num characters from string _src to _dst buffer of maximum _dstSize capacity
	/// including zero terminator. Copy will be terminated with '\0'.
	inline size_t strlncpy(char* _dst, size_t _dstSize, const char* _src, size_t _num = -1)
	{
		BX_CHECK(NULL != _dst, "_dst can't be NULL!");
		BX_CHECK(NULL != _src, "_src can't be NULL!");
		BX_CHECK(0 < _dstSize, "_dstSize can't be 0!");

		const size_t len = strnlen(_src, _num);
		const size_t max = _dstSize-1;
		const size_t num = (len < max ? len : max);
		strncpy(_dst, _src, num);
		_dst[num] = '\0';

		return num;
	}

	/// Find substring in string. Limit search to _size.
	inline const char* strnstr(const char* _str, const char* _find, size_t _size)
	{
		char first = *_find;
		if ('\0' == first)
		{
			return _str;
		}

		const char* cmp = _find + 1;
		size_t len = strlen(cmp);
		do
		{
			for (char match = *_str++; match != first && 0 < _size; match = *_str++, --_size)
			{
				if ('\0' == match)
				{
					return NULL;
				}
			}

			if (0 == _size)
			{
				return NULL;
			}

		} while (0 != strncmp(_str, cmp, len) );

		return --_str;
	}

	/// Find substring in string. Case insensitive.
	inline const char* stristr(const char* _str, const char* _find)
	{
		const char* ptr = _str;

		for (size_t len = strlen(_str), searchLen = strlen(_find)
		    ; len >= searchLen
		    ; ++ptr, --len)
		{
			// Find start of the string.
			while (tolower(*ptr) != tolower(*_find) )
			{
				++ptr;
				--len;

				// Search pattern lenght can't be longer than the string.
				if (searchLen > len)
				{
					return NULL;
				}
			}

			// Set pointers.
			const char* string = ptr;
			const char* search = _find;

			// Start comparing.
			while (tolower(*string++) == tolower(*search++) )
			{
				// If end of the 'search' string is reached, all characters match.
				if ('\0' == *search)
				{
					return ptr;
				}
			}
		}

		return NULL;
	}

	/// Find substring in string. Case insensitive. Limit search to _max.
	inline const char* stristr(const char* _str, const char* _find, size_t _max)
	{
		const char* ptr = _str;

		size_t       stringLen = strnlen(_str, _max);
		const size_t findLen   = strlen(_find);

		for (; stringLen >= findLen; ++ptr, --stringLen)
		{
			// Find start of the string.
			while (tolower(*ptr) != tolower(*_find) )
			{
				++ptr;
				--stringLen;

				// Search pattern lenght can't be longer than the string.
				if (findLen > stringLen)
				{
					return NULL;
				}
			}

			// Set pointers.
			const char* string = ptr;
			const char* search = _find;

			// Start comparing.
			while (tolower(*string++) == tolower(*search++) )
			{
				// If end of the 'search' string is reached, all characters match.
				if ('\0' == *search)
				{
					return ptr;
				}
			}
		}

		return NULL;
	}

	/// Find new line. Returns pointer after new line terminator.
	inline const char* strnl(const char* _str)
	{
		for (; '\0' != *_str; _str += strnlen(_str, 1024) )
		{
			const char* eol = strnstr(_str, "\r\n", 1024);
			if (NULL != eol)
			{
				return eol + 2;
			}

			eol = strnstr(_str, "\n", 1024);
			if (NULL != eol)
			{
				return eol + 1;
			}
		}

		return _str;
	}

	/// Find end of line. Retuns pointer to new line terminator.
	inline const char* streol(const char* _str)
	{
		for (; '\0' != *_str; _str += strnlen(_str, 1024) )
		{
			const char* eol = strnstr(_str, "\r\n", 1024);
			if (NULL != eol)
			{
				return eol;
			}

			eol = strnstr(_str, "\n", 1024);
			if (NULL != eol)
			{
				return eol;
			}
		}

		return _str;
	}

	/// Skip whitespace.
	inline const char* strws(const char* _str)
	{
		for (; isspace(*_str); ++_str) {};
		return _str;
	}

	/// Skip non-whitespace.
	inline const char* strnws(const char* _str)
	{
		for (; !isspace(*_str); ++_str) {};
		return _str;
	}

	/// Skip word.
	inline const char* strword(const char* _str)
	{
		for (char ch = *_str++; isalnum(ch) || '_' == ch; ch = *_str++) {};
		return _str-1;
	}

	/// Find matching block.
	inline const char* strmb(const char* _str, char _open, char _close)
	{
		int count = 0;
		for (char ch = *_str++; ch != '\0' && count >= 0; ch = *_str++)
		{
			if (ch == _open)
			{
				count++;
			}
			else if (ch == _close)
			{
				count--;
				if (0 == count)
				{
					return _str-1;
				}
			}
		}

		return NULL;
	}

	// Normalize string to sane line endings.
	inline void eolLF(char* _out, size_t _size, const char* _str)
	{
		if (0 < _size)
		{
			char* end = _out + _size - 1;
			for (char ch = *_str++; ch != '\0' && _out < end; ch = *_str++)
			{
				if ('\r' != ch)
				{
					*_out++ = ch;
				}
			}

			*_out = '\0';
		}
	}

	// Finds identifier.
	inline const char* findIdentifierMatch(const char* _str, const char* _word)
	{
		size_t len = strlen(_word);
		const char* ptr = strstr(_str, _word);
		for (; NULL != ptr; ptr = strstr(ptr + len, _word) )
		{
			if (ptr != _str)
			{
				char ch = *(ptr - 1);
				if (isalnum(ch) || '_' == ch)
				{
					continue;
				}
			}

			char ch = ptr[len];
			if (isalnum(ch) || '_' == ch)
			{
				continue;
			}

			return ptr;
		}

		return ptr;
	}

	// Finds any identifier from NULL terminated array of identifiers.
	inline const char* findIdentifierMatch(const char* _str, const char* _words[])
	{
		for (const char* word = *_words; NULL != word; ++_words, word = *_words)
		{
			const char* match = findIdentifierMatch(_str, word);
			if (NULL != match)
			{
				return match;
			}
		}

		return NULL;
	}

	/// Cross platform implementation of vsnprintf that returns number of
	/// characters which would have been written to the final string if
	/// enough space had been available.
	inline int32_t vsnprintf(char* _str, size_t _count, const char* _format, va_list _argList)
	{
#if BX_COMPILER_MSVC
		va_list argListCopy;
		va_copy(argListCopy, _argList);
		int32_t len = ::vsnprintf_s(_str, _count, size_t(-1), _format, argListCopy);
		va_end(argListCopy);
		return -1 == len ? ::_vscprintf(_format, _argList) : len;
#else
		return ::vsnprintf(_str, _count, _format, _argList);
#endif // BX_COMPILER_MSVC
	}

	/// Cross platform implementation of vsnwprintf that returns number of
	/// characters which would have been written to the final string if
	/// enough space had been available.
	inline int32_t vsnwprintf(wchar_t* _str, size_t _count, const wchar_t* _format, va_list _argList)
	{
#if BX_COMPILER_MSVC
		va_list argListCopy;
		va_copy(argListCopy, _argList);
		int32_t len = ::_vsnwprintf_s(_str, _count, size_t(-1), _format, argListCopy);
		va_end(argListCopy);
		return -1 == len ? ::_vscwprintf(_format, _argList) : len;
#elif defined(__MINGW32__)
		return ::vsnwprintf(_str, _count, _format, _argList);
#else
		return ::vswprintf(_str, _count, _format, _argList);
#endif // BX_COMPILER_MSVC
	}

	///
	inline int32_t snprintf(char* _str, size_t _count, const char* _format, ...) // BX_PRINTF_ARGS(3, 4)
	{
		va_list argList;
		va_start(argList, _format);
		int32_t len = vsnprintf(_str, _count, _format, argList);
		va_end(argList);
		return len;
	}

	///
	inline int32_t swnprintf(wchar_t* _out, size_t _count, const wchar_t* _format, ...)
	{
		va_list argList;
		va_start(argList, _format);
		int32_t len = vsnwprintf(_out, _count, _format, argList);
		va_end(argList);
		return len;
	}

	///
	template <typename Ty>
	inline void stringPrintfVargs(Ty& _out, const char* _format, va_list _argList)
	{
		char temp[2048];

		char* out = temp;
		int32_t len = bx::vsnprintf(out, sizeof(temp), _format, _argList);
		if ( (int32_t)sizeof(temp) < len)
		{
			out = (char*)alloca(len+1);
			len = bx::vsnprintf(out, len, _format, _argList);
		}
		out[len] = '\0';
		_out.append(out);
	}

	///
	template <typename Ty>
	inline void stringPrintf(Ty& _out, const char* _format, ...)
	{
		va_list argList;
		va_start(argList, _format);
		stringPrintfVargs(_out, _format, argList);
		va_end(argList);
	}

	/// Replace all instances of substring.
	template <typename Ty>
	inline Ty replaceAll(const Ty& _str, const char* _from, const char* _to)
	{
		Ty str = _str;
		size_t startPos = 0;
		const size_t fromLen = strlen(_from);
		const size_t toLen   = strlen(_to);
		while ( (startPos = str.find(_from, startPos) ) != Ty::npos)
		{
			str.replace(startPos, fromLen, _to);
			startPos += toLen;
		}

		return str;
	}

	/// Extract base file name from file path.
	inline const char* baseName(const char* _filePath)
	{
		const char* bs       = strrchr(_filePath, '\\');
		const char* fs       = strrchr(_filePath, '/');
		const char* slash    = (bs > fs ? bs : fs);
		const char* colon    = strrchr(_filePath, ':');
		const char* basename = slash > colon ? slash : colon;
		if (NULL != basename)
		{
			return basename+1;
		}

		return _filePath;
	}

	/// Convert size in bytes to human readable string.
	inline void prettify(char* _out, size_t _count, uint64_t _size)
	{
		uint8_t idx = 0;
		double size = double(_size);
		while (_size != (_size&0x7ff)
		&&     idx < 9)
		{
			_size >>= 10;
			size *= 1.0/1024.0;
			++idx;
		}

		snprintf(_out, _count, "%0.2f %c%c", size, "BkMGTPEZY"[idx], idx > 0 ? 'B' : '\0');
	}

	/*
	 * Copyright (c) 1998 Todd C. Miller <Todd.Miller@courtesan.com>
	 *
	 * Permission to use, copy, modify, and distribute this software for any
	 * purpose with or without fee is hereby granted, provided that the above
	 * copyright notice and this permission notice appear in all copies.
	 *
	 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
	 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
	 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
	 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
	 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
	 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
	 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
	 */

	/// Copy src to string dst of size siz.  At most siz-1 characters
	/// will be copied.  Always NUL terminates (unless siz == 0).
	/// Returns strlen(src); if retval >= siz, truncation occurred.
	inline size_t strlcpy(char* _dst, const char* _src, size_t _siz)
	{
		char* dd = _dst;
		const char* ss = _src;
		size_t nn = _siz;

		/* Copy as many bytes as will fit */
		if (nn != 0)
		{
			while (--nn != 0)
			{
				if ( (*dd++ = *ss++) == '\0')
				{
					break;
				}
			}
		}

		/* Not enough room in dst, add NUL and traverse rest of src */
		if (nn == 0)
		{
			if (_siz != 0)
			{
				*dd = '\0';  /* NUL-terminate dst */
			}

			while (*ss++)
			{
			}
		}

		return(ss - _src - 1); /* count does not include NUL */
	}

	/// Appends src to string dst of size siz (unlike strncat, siz is the
	/// full size of dst, not space left).  At most siz-1 characters
	/// will be copied.  Always NUL terminates (unless siz <= strlen(dst)).
	/// Returns strlen(src) + MIN(siz, strlen(initial dst)).
	/// If retval >= siz, truncation occurred.
	inline size_t strlcat(char* _dst, const char* _src, size_t _siz)
	{
		char* dd = _dst;
		const char *s = _src;
		size_t nn = _siz;
		size_t dlen;

		/* Find the end of dst and adjust bytes left but don't go past end */
		while (nn-- != 0 && *dd != '\0')
		{
			dd++;
		}

		dlen = dd - _dst;
		nn = _siz - dlen;

		if (nn == 0)
		{
			return(dlen + strlen(s));
		}

		while (*s != '\0')
		{
			if (nn != 1)
			{
				*dd++ = *s;
				nn--;
			}
			s++;
		}
		*dd = '\0';

		return(dlen + (s - _src)); /* count does not include NUL */
	}

	/// Non-zero-terminated string view.
	class StringView
	{
	public:
		StringView()
		{
			clear();
		}

		StringView(const StringView& _rhs)
		{
			set(_rhs.m_ptr, _rhs.m_len);
		}

		StringView& operator=(const StringView& _rhs)
		{
			set(_rhs.m_ptr, _rhs.m_len);
			return *this;
		}

		StringView(const char* _ptr, uint32_t _len = UINT16_MAX)
		{
			set(_ptr, _len);
		}

		void set(const char* _ptr, uint32_t _len = UINT16_MAX)
		{
			clear();

			if (NULL != _ptr)
			{
				uint32_t len = uint32_t(strnlen(_ptr, _len) );
				if (0 != len)
				{
					m_len = len;
					m_ptr = _ptr;
				}
			}
		}

		void clear()
		{
			m_ptr = "";
			m_len = 0;
		}

		const char* getPtr() const
		{
			return m_ptr;
		}

		const char* getTerm() const
		{
			return m_ptr + m_len;
		}

		bool isEmpty() const
		{
			return 0 == m_len;
		}

		uint32_t getLength() const
		{
			return m_len;
		}

	protected:
		friend uint32_t hashMurmur2A(const StringView& _data);

		const char* m_ptr;
		uint32_t    m_len;
	};

	inline uint32_t hashMurmur2A(const StringView& _data)
	{
		return hashMurmur2A(_data.m_ptr, _data.m_len);
	}

	inline uint32_t hashMurmur2A(const char* _data)
	{
		return hashMurmur2A(StringView(_data) );
	}

	/// ASCII string
	template<bx::AllocatorI** AllocatorT>
	class StringT : public StringView
	{
	public:
		StringT()
			: StringView("", 0)
		{
		}

		StringT(const StringT<AllocatorT>& _rhs)
		{
			set(_rhs.m_ptr, _rhs.m_len);
		}

		StringT<AllocatorT>& operator=(const StringT<AllocatorT>& _rhs)
		{
			set(_rhs.m_ptr, _rhs.m_len);
			return *this;
		}

		StringT(const char* _ptr, uint32_t _len = UINT32_MAX)
		{
			set(_ptr, _len);
		}

		StringT(const StringView& _rhs)
		{
			set(_rhs.getPtr(), _rhs.getLength() );
		}

		~StringT()
		{
			clear();
		}

		void set(const char* _ptr, uint32_t _len = UINT32_MAX)
		{
			clear();
			append(_ptr, _len);
		}

		void append(const char* _ptr, uint32_t _len = UINT32_MAX)
		{
			if (0 != _len)
			{
				uint32_t old = m_len;
				uint32_t len = m_len + uint32_t(strnlen(_ptr, _len) );
				char* ptr = (char*)BX_REALLOC(*AllocatorT, 0 != m_len ? const_cast<char*>(m_ptr) : NULL, len+1);
				m_len = len;
				strlncpy(ptr + old, len-old+1, _ptr, _len);

				*const_cast<char**>(&m_ptr) = ptr;
			}
		}

		void clear()
		{
			if (0 != m_len)
			{
				BX_FREE(*AllocatorT, const_cast<char*>(m_ptr) );

				StringView::clear();
			}
		}
	};

} // namespace bx

#endif // BX_STRING_H_HEADER_GUARD
