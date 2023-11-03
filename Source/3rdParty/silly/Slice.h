/**
 * Copyright (C) 2017, IppClub. All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#pragma once

#include <cassert>
#include <cstring>
#include <list>
#include <memory>
#include <string>

namespace silly {

namespace slice {

// A Slice object wraps a "const char *" or a "const std::string&" but
// without copying their contents.
class Slice {
private:
	struct TrustedInitTag { };

	constexpr Slice(const char* s, size_t n, TrustedInitTag)
		: str_(s)
		, len_(n) { }

public:
	// implicit conversion from std::string to Slice
	Slice(const std::string& s)
		: Slice(s.data(), s.size()) { }

	Slice(const char* s)
		: Slice(s, s ? strlen(s) : 0) { }

	Slice(const char* s, size_t n)
		: str_(s)
		, len_(n) { }

	Slice(std::pair<const char*, size_t> sp)
		: str_(sp.first)
		, len_(sp.second) { }

	Slice(std::string_view sv)
		: str_(sv.data())
		, len_(sv.size()) { }

	Slice(std::u8string_view sv)
		: str_(reinterpret_cast<const char*>(sv.data()))
		, len_(sv.size()) { }

	constexpr Slice(std::nullptr_t p = nullptr)
		: str_(nullptr)
		, len_(0) { }

	explicit inline operator std::string() const {
		return std::string(str_, len_);
	}

	inline const char& operator[](size_t n) const {
		return str_[n];
	}

	inline size_t size() const {
		return len_;
	}

	inline const char* rawData() const {
		return str_;
	}

	inline std::string toString() const {
		return std::string(str_, len_);
	}

	inline std::string_view toView() const {
		return std::string_view(str_, len_);
	}

	inline bool empty() const {
		return len_ == 0;
	}

	// similar with std::string::compare
	// http://en.cppreference.com/w/cpp/string/basic_string/compare
	int compare(const Slice& rhs) const;

	void skip(size_t n) {
		assert(n <= len_);
		str_ += n;
		len_ -= n;
	}

	void skipRight(size_t n) {
		assert(n <= len_);
		len_ -= n;
	}

	void copyTo(char* dest, bool appendEndingNull = true) const {
		memcpy(dest, str_, len_);
		if (appendEndingNull) {
			dest[len_] = '\0';
		}
	}

	Slice& trimSpace() {
		if (empty()) return *this;
		size_t start = 0, end = len_ - 1;
		while (start < end && std::isspace(static_cast<unsigned char>(str_[start]))) {
			start++;
		}
		while (start < end && std::isspace(static_cast<unsigned char>(str_[end]))) {
			end--;
		}
		str_ += start;
		len_ = end - start + 1;
		return *this;
	}

	Slice& trimZero() {
		assert(len_ > 0);
		size_t end = len_ - 1;
		while (0 < end && (str_[end] == '0' || str_[end] == '.')) {
			if (str_[end--] == '.') break;
		}
		len_ = end + 1;
		return *this;
	}

	typedef const char* const_iterator;

	inline const_iterator begin() const {
		return str_;
	}

	inline const_iterator end() const {
		return str_ + len_;
	}

	const char& front() const {
		assert(!empty());
		return *begin();
	}

	const char& back() const {
		assert(!empty());
		return *(end() - 1);
	}

	Slice left(size_t n) const {
		if (n <= len_) {
			return Slice(str_, n);
		} else {
			return *this;
		}
	}

	Slice right(size_t n) const {
		if (n <= len_) {
			return Slice(str_ + len_ - n, n);
		} else {
			return *this;
		}
	}

	std::string toLower() const;

	std::string toUpper() const;

	std::list<Slice> split(Slice delimer) const;

	static const std::string Empty;

	float toFloat() const;

	int toInt(int base = 10) const;

	static std::string join(const std::list<std::string>& list, Slice delimer = Empty);

	constexpr friend Slice operator""_slice(const char* s, size_t n);

	class CStr {
	public:
		CStr(const char* str, size_t len) {
			if (str) {
				if (*(str + len) == '\0') {
					_cstr = str;
				} else {
					_str.assign(str, len);
				}
			}
		}
		inline operator const char*() const { return get(); }
		inline const char* get() const {
			if (_cstr) {
				return _cstr;
			} else {
				return _str.c_str();
			}
		}

	private:
		const char* _cstr = nullptr;
		std::string _str;
	};

	inline CStr c_str() const {
		return CStr(str_, len_);
	}

private:
	const char* str_;
	size_t len_;
};

inline bool operator==(const Slice& lhs, const Slice& rhs) {
	return lhs.compare(rhs) == 0;
}

inline bool operator!=(const Slice& lhs, const Slice& rhs) {
	return !(lhs == rhs);
}

inline std::string operator+(const std::string& lhs, const Slice& rhs) {
	return lhs + rhs.toString();
}

constexpr Slice operator""_slice(const char* s, size_t n) {
	return Slice(s, n, Slice::TrustedInitTag{});
}

} // namespace slice

} // namespace silly
