// MIT License

// Copyright (c) 2021 Vadim Grigoruk @nesbox // grigoruk@gmail.com
// Copyright (c) 2022 bzt png chunk stuff

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "tic80/ext/png.h"
#include "tic80/defines.h"

#include <string.h>
#include <stdlib.h>

#include "lodepng.h"
using namespace lodepnglib;
#include "tic80/tic_assert.h"

#define EXTRA_CHUNK "caRt"
#define RGBA_SIZE sizeof(u32)

png_buffer png_create(s32 size)
{
    return (png_buffer){(u8*)malloc(size), size};
}

png_img png_read(png_buffer buf, png_buffer *cart)
{
    png_img res = { 0 };

    // Check PNG signature
    if (buf.size >= 8 && buf.data[0] == 0x89 && buf.data[1] == 0x50 &&
        buf.data[2] == 0x4E && buf.data[3] == 0x47 &&
        buf.data[4] == 0x0D && buf.data[5] == 0x0A &&
        buf.data[6] == 0x1A && buf.data[7] == 0x0A)
    {
        LodePNGState state;
        lodepng_state_init(&state);

        // Enable reading unknown chunks
        state.decoder.remember_unknown_chunks = 1;
        state.decoder.read_text_chunks = 0;

        unsigned char* image = NULL;
        unsigned width, height;
        unsigned error = lodepng_decode(&image, &width, &height, &state, buf.data, buf.size);

        if (!error)
        {
            res.width = (s32)width;
            res.height = (s32)height;
            res.data = (u8*)image;

            // Read in cartridge data from chunk if possible
            if (cart)
            {
                cart->data = NULL;
                cart->size = 0;

                // Search for EXTRA_CHUNK in unknown chunks after IDAT (position 2)
                if (state.info_png.unknown_chunks_data[2] && state.info_png.unknown_chunks_size[2] > 0)
                {
                    const unsigned char* chunk = state.info_png.unknown_chunks_data[2];
                    const unsigned char* end = chunk + state.info_png.unknown_chunks_size[2];

                    while (chunk < end)
                    {
                        if (lodepng_chunk_type_equals(chunk, EXTRA_CHUNK))
                        {
                            unsigned length = lodepng_chunk_length(chunk);
                            const unsigned char* data = lodepng_chunk_data_const(chunk);

                            cart->size = (s32)length;
                            cart->data = (u8*)malloc(cart->size);
                            if (cart->data)
                            {
                                memcpy(cart->data, data, cart->size);
                            }
                            else
                            {
                                cart->size = 0;
                            }
                            break;
                        }
                        chunk = lodepng_chunk_next_const(chunk, end);
                    }
                }
            }
        }
        else
        {
            // If decode failed, free any allocated memory
            if (image)
                free(image);
        }

        lodepng_state_cleanup(&state);
    }

    return res;
}

png_buffer png_write(png_img src, png_buffer cart)
{
    png_buffer result = { 0 };

    if (src.data && src.width > 0 && src.height > 0)
    {
        LodePNGState state;
        lodepng_state_init(&state);

        // Set output color mode to RGBA 8-bit
        state.info_raw.colortype = LCT_RGBA;
        state.info_raw.bitdepth = 8;

        // Save cartridge data in a chunk too. This supports bigger cartridges than steganography
        if (cart.data && cart.size > 0 && cart.size <= 0x7fffff)
        {
            // Create the custom chunk
            unsigned char* chunk_data = NULL;
            size_t chunk_size = 0;
            unsigned error = lodepng_chunk_create(&chunk_data, &chunk_size, (unsigned)cart.size, EXTRA_CHUNK, cart.data);

            if (!error && chunk_data)
            {
                // Append chunk to position 2 (after IDAT)
                error = lodepng_chunk_append(&state.info_png.unknown_chunks_data[2],
                                            &state.info_png.unknown_chunks_size[2],
                                            chunk_data);
                free(chunk_data);
            }
        }

        unsigned char* out = NULL;
        size_t outsize = 0;
        unsigned error = lodepng_encode(&out, &outsize, src.data, (unsigned)src.width, (unsigned)src.height, &state);

        if (!error && out)
        {
            result.data = out;
            result.size = (s32)outsize;
        }
        else
        {
            if (out)
                free(out);
        }

        lodepng_state_cleanup(&state);
    }

    return result;
}

typedef union
{
    struct
    {
        u32 bits:8;
        u32 size:24;
    };

    u8 data[RGBA_SIZE];
} Header;

static_assert(sizeof(Header) == RGBA_SIZE, "header_size");

#define BITS_IN_BYTE 8
#define HEADER_BITS 4
#define HEADER_SIZE (sizeof(Header) * BITS_IN_BYTE / HEADER_BITS)

static inline void bitcpy(u8* dst, u32 to, const u8* src, u32 from, u32 size)
{
    for(s32 i = 0; i < size; i++, to++, from++)
        BITCHECK(src[from >> 3], from & 7)
            ? _BITSET(dst[to >> 3], to & 7)
            : _BITCLEAR(dst[to >> 3], to & 7);
}

static inline s32 ceildiv(s32 a, s32 b)
{
    return (a + b - 1) / b;
}

png_buffer png_encode(png_buffer cover, png_buffer cart)
{
    png_img png = png_read(cover, NULL);

    const s32 cartBits = cart.size * BITS_IN_BYTE;
    const s32 coverSize = png.width * png.height * RGBA_SIZE - HEADER_SIZE;
	Header header = {(u32)CLAMP(ceildiv(cartBits, coverSize), 1, BITS_IN_BYTE), (u32)cart.size};

    // only save with steganography if there are enough pixels for the size of the cartidge
    if (coverSize >= cartBits)
    {
        for (s32 i = 0; i < HEADER_SIZE; i++)
            bitcpy(png.data, i << 3, header.data, i * HEADER_BITS, HEADER_BITS);

        u8* dst = png.data + HEADER_SIZE;
        s32 end = ceildiv(cartBits, header.bits);
        for (s32 i = 0; i < end; i++)
            bitcpy(dst, i << 3, cart.data, i * header.bits, header.bits);

        for (s32 i = end; i < coverSize; i++)
            bitcpy(dst, i << 3, (const u8[]){(u8)rand()}, 0, header.bits);
    }

    png_buffer out = png_write(png, cart);

    free(png.data);

    return out;
}

png_buffer png_decode(png_buffer cover)
{
    png_buffer cart = { 0 };
    png_img png = png_read(cover, &cart);

    // if we have a data from a png chunk, use that
    if (cart.data && cart.size > 0)
    {
        if (png.data)
            free(png.data);
        return cart;
    }

    // otherwise fallback to steganography
    if (png.data)
    {
        Header header;

        for (s32 i = 0; i < HEADER_SIZE; i++)
            bitcpy(header.data, i * HEADER_BITS, png.data, i << 3, HEADER_BITS);

        if (header.bits > 0
            && header.bits <= BITS_IN_BYTE
            && header.size > 0
            && header.size <= png.width * png.height * RGBA_SIZE * header.bits / BITS_IN_BYTE - HEADER_SIZE)
        {
            s32 aligned = header.size + ceildiv(header.size * BITS_IN_BYTE % header.bits, BITS_IN_BYTE);
            png_buffer out = { (u8*)malloc(aligned), header.size };

            const u8* from = png.data + HEADER_SIZE;
            for (s32 i = 0, end = ceildiv(header.size * BITS_IN_BYTE, header.bits); i < end; i++)
                bitcpy(out.data, i * header.bits, from, i << 3, header.bits);

            free(png.data);

            return out;
        }
    }

    return (png_buffer) { 0 };
}
