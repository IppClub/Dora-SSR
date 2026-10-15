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

#include "Slice.h"
#include <cstdlib>
#include <sstream>
#include <limits>

namespace silly {

namespace slice {

const std::string Slice::Empty;

int Slice::compare(const Slice& rhs) const {
	if (len_ < rhs.len_)
		return -1;
	else if (len_ > rhs.len_)
		return 1;
	else {
		// It's illegal to pass nullptr to memcmp.
		if (str_ && rhs.str_)
			return memcmp(str_, rhs.str_, len_);
		return 0;
	}
}

std::string Slice::toLower() const {
	std::string tmp = toString();
	for (size_t i = 0; i < tmp.length(); i++) {
		tmp[i] = (char)tolower(tmp[i]);
	}
	return tmp;
}

std::string Slice::toUpper() const {
	std::string tmp = toString();
	for (size_t i = 0; i < tmp.length(); i++) {
		tmp[i] = (char)toupper(tmp[i]);
	}
	return tmp;
}

std::list<Slice> Slice::split(Slice delims) const {
	std::string_view text{str_, len_};
	std::string_view delimers{delims.rawData(), delims.size()};
	std::list<Slice> tokens;
	std::size_t start = 0, end = 0;
	while ((end = text.find(delimers, start)) < text.size()) {
		tokens.push_back(Slice(str_ + start, end - start).trimSpace());
		start = end + delimers.size();
	}
	if (start < text.size()) {
		tokens.push_back(Slice(str_ + start, len_ - start).trimSpace());
	}
	return tokens;
}

float Slice::toFloat() const {
	return static_cast<float>(std::atof(c_str()));
}

int Slice::toInt(int base) const {
	errno = 0;
	const long l = std::strtol(c_str(), nullptr, base);
	if (errno == ERANGE) {
		return std::numeric_limits<int>::max();
	}
	return static_cast<int>(l);
}

std::string Slice::join(const std::list<std::string>& list, Slice delimer) {
	if (list.empty())
		return Empty;
	else if (list.size() == 1)
		return list.front();
	auto begin = ++list.begin();
	std::ostringstream stream;
	stream << list.front();
	if (delimer.empty()) {
		for (auto it = begin; it != list.end(); ++it) {
			stream << *it;
		}
	} else {
		std::string_view sep = delimer.toView();
		for (auto it = begin; it != list.end(); ++it) {
			stream << sep << *it;
		}
	}
	return stream.str();
}

} // namespace slice

} // namespace silly
