/**
 * Copyright (c) 2006-2023 LOVE Development Team
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 **/

// Modified for Dora: bounded EOF reads and exact packet/page seek positions.
#include "OggDemuxer.h"

namespace love
{
namespace video
{
namespace theora
{

OggDemuxer::OggDemuxer(love::filesystem::File *file)
	: file(file), streamInited(false), videoSerial(0), eos(false)
{
	ogg_sync_init(&sync);
}

OggDemuxer::~OggDemuxer()
{
	if (streamInited) ogg_stream_clear(&stream);
	ogg_sync_clear(&sync);
}

bool OggDemuxer::readPage()
{
	for (;;)
	{
		int result = ogg_sync_pageout(&sync, &page);
		if (result == 1)
		{
			pageValid = true;
			pageOffset = file->tell() - (sync.fill - sync.returned) - page.header_len - page.body_len;
			return true;
		}
		if (result < 0) continue;
		char *buffer = ogg_sync_buffer(&sync, 8192);
		if (!buffer) throw love::Exception("Could not allocate Ogg read buffer");
		const auto count = file->read(buffer, 8192);
		if (count <= 0) return false;
		if (ogg_sync_wrote(&sync, count) != 0)
			throw love::Exception("Invalid Ogg read buffer");
	}
}

void OggDemuxer::trackPage()
{
	const long sequence = ogg_page_pageno(&page);
	if (previousPage >= 0 && static_cast<uint32>(sequence) != static_cast<uint32>(previousPage) + 1)
		throw love::Exception("Missing or corrupt Ogg video page");
	previousPage = sequence;
	bool discard = ogg_page_continued(&page) && !packetPending;
	unsigned int starts = 0;
	for (int segment = 0; segment < page.header[26]; ++segment)
	{
		if (!packetPending && !discard)
		{
			pendingPosition = {pageOffset, starts++};
			packetPending = true;
		}
		if (page.header[27 + segment] < 255)
		{
			if (discard) discard = false;
			else
			{
				packetPositions.push_back(pendingPosition);
				packetPending = false;
			}
		}
	}
}

bool OggDemuxer::readPacket(ogg_packet &packet, bool mustSucceed)
{
	if (!streamInited)
		throw love::Exception("Reading from OggDemuxer before initialization (engine bug)");
	for (;;)
	{
		const int result = ogg_stream_packetout(&stream, &packet);
		if (result == 1)
		{
			if (packetPositions.empty()) throw love::Exception("Invalid Ogg packet position");
			packetPosition = packetPositions.front();
			packetPositions.pop_front();
			eos = false;
			return false;
		}
		if (result < 0) throw love::Exception("Missing or corrupt Ogg video packet");
		if ((pageValid && ogg_page_serialno(&page) == videoSerial && ogg_page_eos(&page)) || !readPage())
		{
			eos = true;
			packet = {};
			if (mustSucceed) throw love::Exception("Unexpected end of Ogg video");
			return true;
		}
		if (ogg_page_serialno(&page) != videoSerial) continue;
		trackPage();
		if (ogg_stream_pagein(&stream, &page) != 0) throw love::Exception("Invalid Ogg video page");
	}
}

bool OggDemuxer::isEos() const { return eos.load(); }
const std::string &OggDemuxer::getFilename() const { return file->getFilename(); }
OggDemuxer::PacketPosition OggDemuxer::getPacketPosition() const { return packetPosition; }

OggDemuxer::StreamType OggDemuxer::determineType()
{
	ogg_packet packet;
	if (ogg_stream_packetpeek(&stream, &packet) == 1 && packet.bytes >= 7
		&& (packet.packet[0] & 0x80) && std::strncmp((const char *)packet.packet + 1, "theora", 6) == 0)
		return TYPE_THEORA;
	return TYPE_UNKNOWN;
}

OggDemuxer::StreamType OggDemuxer::findStream()
{
	if (streamInited) ogg_stream_clear(&stream);
	streamInited = false;
	eos = false;
	packetPositions.clear();
	packetPending = false;
	previousPage = -1;
	pageValid = false;
	if (!file->seek(0)) return TYPE_UNKNOWN;
	ogg_sync_reset(&sync);
	while (readPage() && ogg_page_bos(&page))
	{
		videoSerial = ogg_page_serialno(&page);
		if (ogg_stream_init(&stream, videoSerial) != 0) return TYPE_UNKNOWN;
		streamInited = true;
		ogg_stream_pagein(&stream, &page);
		if (determineType() == TYPE_THEORA)
		{
			trackPage();
			return TYPE_THEORA;
		}
		ogg_stream_clear(&stream);
		streamInited = false;
	}
	return TYPE_UNKNOWN;
}

bool OggDemuxer::seek(ogg_packet &packet, PacketPosition position)
{
	if (!streamInited || !file->seek(position.offset)) return false;
	ogg_sync_reset(&sync);
	ogg_stream_reset(&stream);
	packetPositions.clear();
	packetPending = false;
	previousPage = -1;
	eos = false;
	// The previous page no longer describes the stream after a seek.
	pageValid = false;
	for (unsigned int i = 0; i <= position.skip; ++i)
		if (readPacket(packet)) return false;
	return true;
}

} // theora
} // video
} // love
