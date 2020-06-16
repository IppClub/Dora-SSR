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

namespace silly {

namespace slice {

const std::string Slice::Empty;

int Slice::compare(const Slice &rhs) const {
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

std::list<Slice> Slice::split(const Slice& delims) const {
  std::string text = toString();
  std::string delimers = delims.toString();
  std::list<Slice> tokens;
  std::size_t start = 0, end = 0;
  while ((end = text.find(delimers, start)) < text.size()) {
    tokens.push_back(Slice(str_ + start, end - start));
	start = end + delimers.size();
  }
  if (start < text.size()) {
    tokens.push_back(Slice(str_ + start, len_ - start));
  }
  return tokens;
}

float Slice::stof(const Slice& str) {
  return static_cast<float>(std::atof(str.toString().c_str()));
}

int Slice::stoi(const Slice& str) {
  return std::atoi(str.toString().c_str());
}

} // namespace slice

} // namespace silly
