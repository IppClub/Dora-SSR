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

// Modified for Dora: bounded decoding and indexed keyframe seeking.

#ifndef LOVE_VIDEO_THEORA_OGGDEMUXER_H
#define LOVE_VIDEO_THEORA_OGGDEMUXER_H

// STL
#include <atomic>
#include <deque>

// LOVE
#include "filesystem/File.h"

// OGG
#include <ogg/ogg.h>

namespace love
{
namespace video
{
namespace theora
{

class OggDemuxer
{
public:
	enum StreamType
	{
		TYPE_THEORA,
		TYPE_UNKNOWN,
	};

	OggDemuxer(love::filesystem::File *file);
	~OggDemuxer();
	struct PacketPosition
	{
		uint64 offset = 0;
		unsigned int skip = 0;
	};

	StreamType findStream();
	bool readPacket(ogg_packet &packet, bool mustSucceed = false);
	bool isEos() const;
	const std::string &getFilename() const;
	PacketPosition getPacketPosition() const;
	bool seek(ogg_packet &packet, PacketPosition position);

private:
	StrongRef<love::filesystem::File> file;

	ogg_sync_state sync;
	ogg_stream_state stream;
	ogg_page page;

	bool streamInited;
	int videoSerial;
	std::atomic<bool> eos;
	uint64 pageOffset = 0;
	bool pageValid = false;
	PacketPosition packetPosition;
	PacketPosition pendingPosition;
	std::deque<PacketPosition> packetPositions;
	bool packetPending = false;
	long previousPage = -1;

	bool readPage();
	void trackPage();
	StreamType determineType();
}; // OggDemuxer

} // theora
} // video
} // love

#endif // LOVE_VIDEO_THEORA_OGGDEMUXER_H
