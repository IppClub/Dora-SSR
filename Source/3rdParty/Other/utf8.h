// Copyright (c) 2008-2009 Bjoern Hoehrmann <bjoern@hoehrmann.de>
// See http://bjoern.hoehrmann.de/utf-8/decoder/dfa/ for details.

#ifndef UTF8_H_HEADER_GUARD
#define UTF8_H_HEADER_GUARD

#include <stdint.h>
#include <vector>

#define UTF8_ACCEPT 0
#define UTF8_REJECT 1

uint32_t utf8_decode(uint32_t* _state, uint32_t* _codep, uint8_t _ch);

int utf8_count_characters(const char* utf8str);

std::vector<uint32_t> utf8_get_characters(const char* utf8str);

bool utf8_isspace(uint32_t ch);

void utf8_trim_ws(std::vector<uint32_t>& str);

uint32_t utf8_find_last_not_char(const std::vector<uint32_t>& str, uint32_t ch);

uint32_t utf8_find_last_not_alnum(const std::vector<uint32_t>& str);

#endif // UTF8_H_HEADER_GUARD
