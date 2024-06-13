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

#ifndef USE_EXTLIBS
#include "miniz.h"
#else
#include <zlib.h>
#endif
#include "tmxlite/FreeFuncs.hpp"
#include "tmxlite/Types.hpp"
#include "tmxlite/detail/Log.hpp"

#include <cstring>

bool tmx::decompress(const char* source, std::vector<unsigned char>& dest, std::size_t inSize, std::size_t expectedSize)
{
    if (!source)
    {
        LOG("Input string is empty, decompression failed.", Logger::Type::Error);
        return false;
    }

//#ifdef USE_EXTLIBS


//#else
    int currentSize = static_cast<int>(expectedSize);
    std::vector<unsigned char> byteArray(expectedSize / sizeof(unsigned char));
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.next_in = (Bytef*)source;
    stream.avail_in = static_cast<unsigned int>(inSize);
    stream.next_out = (Bytef*)byteArray.data();
    stream.avail_out = static_cast<unsigned int>(expectedSize);

    //we'd prefer to use inflateInit2 but it appears 
    //to be incorrect in miniz. This is fine for zlib
    //compressed data, but gzip compressed streams
    //will fail to inflate.
#ifdef USE_EXTLIBS
    if (inflateInit2(&stream, 15 + 32) != Z_OK)
#else
    if (inflateInit(&stream) != Z_OK)
#endif
    {
        LOG("inflate init failed", Logger::Type::Error);
        return false;
    }

    int result = 0;
    do
    {
        result = inflate(&stream, Z_SYNC_FLUSH);

        switch (result)
        {
        default: break;
        case Z_NEED_DICT:
        case Z_STREAM_ERROR:
            result = Z_DATA_ERROR;
        case Z_DATA_ERROR:
            Logger::log("If using gzip or zstd compression try using zlib instead", Logger::Type::Info);
        case Z_MEM_ERROR:
            inflateEnd(&stream);
            Logger::log("inflate() returned " +  std::to_string(result), Logger::Type::Error);
            return false;
        }

        if (result != Z_STREAM_END)
        {
            int oldSize = currentSize;
            currentSize *= 2;
            std::vector<unsigned char> newArray(currentSize / sizeof(unsigned char));
            std::memcpy(newArray.data(), byteArray.data(), currentSize / 2);
            byteArray = std::move(newArray);

            stream.next_out = (Bytef*)(byteArray.data() + oldSize);
            stream.avail_out = oldSize;

        }
    } while (result != Z_STREAM_END);

    if (stream.avail_in != 0)
    {
        LOG("stream.avail_in is 0", Logger::Type::Error);
        LOG("zlib decompression failed.", Logger::Type::Error);
        return false;
    }

    const int outSize = currentSize - stream.avail_out;
    inflateEnd(&stream);

    std::vector<unsigned char> newArray(outSize / sizeof(unsigned char));
    std::memcpy(newArray.data(), byteArray.data(), outSize);
    byteArray = std::move(newArray);

    //copy bytes to vector
    dest.insert(dest.begin(), byteArray.begin(), byteArray.end());
//#endif
    return true;
}

std::ostream& operator << (std::ostream& os, const tmx::Colour& c)
{
    os << "RGBA: " << (int)c.r << ", " << (int)c.g << ", " << (int)c.b << ", " << (int)c.a;
    return os;
}
