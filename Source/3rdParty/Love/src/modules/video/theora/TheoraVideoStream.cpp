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

// Modified for Dora: bounded parsing, timestamped playback and keyframe-based seeking.

// STL
#include <iostream>
#include <algorithm>
#include <cmath>

// LOVE
#include "TheoraVideoStream.h"

using love::filesystem::File;

namespace love
{
namespace video
{
namespace theora
{

TheoraVideoStream::TheoraVideoStream(love::filesystem::File *file)
	: demuxer(file)
	, headerParsed(false)
	, decoder(nullptr)
	, frameReady(false)
	, lastFrame(0)
	, nextFrame(0)
{
	if (demuxer.findStream() != OggDemuxer::TYPE_THEORA)
		throw love::Exception("Invalid video file, video is not theora");

	th_info_init(&videoInfo);

	frontBuffer = new Frame();
	backBuffer = new Frame();

	try
	{
		parseHeader();
	}
	catch (...)
	{
		if (decoder) th_decode_free(decoder);
		if (setup) th_setup_free(setup);
		delete backBuffer;
		delete frontBuffer;
		th_info_clear(&videoInfo);
		throw;
	}

	frameSync.set(new DeltaSync(), Acquire::NORETAIN);
}

TheoraVideoStream::~TheoraVideoStream()
{
	if (setup) th_setup_free(setup);
	if (decoder)
		th_decode_free(decoder);

	th_info_clear(&videoInfo);

	delete frontBuffer;
	delete backBuffer;
}

int TheoraVideoStream::getWidth() const
{
	if (headerParsed)
		return videoInfo.pic_width;
	else
		return 0;
}

int TheoraVideoStream::getHeight() const
{
	if (headerParsed)
		return videoInfo.pic_height;
	else
		return 0;
}

const std::string &TheoraVideoStream::getFilename() const
{
	return demuxer.getFilename();
}

void TheoraVideoStream::setSync(FrameSync *frameSync)
{
	love::thread::Lock l(bufferMutex);
	this->frameSync = frameSync;
}

const void *TheoraVideoStream::getFrontBuffer() const
{
	return frontBuffer;
}

size_t TheoraVideoStream::getSize() const
{
	return sizeof(Frame);
}

bool TheoraVideoStream::isPlaying() const
{
	return frameSync->isPlaying() && !demuxer.isEos();
}

template<typename T>
inline void scaleFormat(th_pixel_fmt fmt, T &x, T &y)
{
	switch(fmt)
	{
	case TH_PF_420:
		y /= 2;
	case TH_PF_422:
		x /= 2;
		break;
	default:
		break;
	}
}


void TheoraVideoStream::parseHeader()
{
	if (headerParsed) return;
	th_comment comment;
	th_comment_init(&comment);
	try
	{
		int result;
		do
		{
			demuxer.readPacket(packet, true);
			result = th_decode_headerin(&videoInfo, &comment, &setup, &packet);
			if (result < 0) throw love::Exception("Invalid Theora header");
		} while (result > 0);
		decoder = th_decode_alloc(&videoInfo, setup);
		if (!decoder || videoInfo.pic_width == 0 || videoInfo.pic_height == 0
			|| videoInfo.fps_numerator == 0 || videoInfo.fps_denominator == 0)
			throw love::Exception("Invalid Theora video dimensions or frame rate");
	}
	catch (...)
	{
		th_comment_clear(&comment);
		throw;
	}
	th_comment_clear(&comment);
	Frame *buffers[2] = {backBuffer, frontBuffer};
	yPlaneXOffset = cPlaneXOffset = videoInfo.pic_x;
	yPlaneYOffset = cPlaneYOffset = videoInfo.pic_y;
	scaleFormat(videoInfo.pixel_fmt, cPlaneXOffset, cPlaneYOffset);
	for (auto *buffer : buffers)
	{
		buffer->cw = buffer->yw = videoInfo.pic_width;
		buffer->ch = buffer->yh = videoInfo.pic_height;
		scaleFormat(videoInfo.pixel_fmt, buffer->cw, buffer->ch);
		buffer->yplane = new unsigned char[size_t(buffer->yw) * buffer->yh];
		buffer->cbplane = new unsigned char[size_t(buffer->cw) * buffer->ch];
		buffer->crplane = new unsigned char[size_t(buffer->cw) * buffer->ch];
		memset(buffer->yplane, 16, size_t(buffer->yw) * buffer->yh);
		memset(buffer->cbplane, 128, size_t(buffer->cw) * buffer->ch);
		memset(buffer->crplane, 128, size_t(buffer->cw) * buffer->ch);
	}
	headerParsed = true;
	packetPending = true;
}

void TheoraVideoStream::buildSeekIndex()
{
	if (indexBuilt) return;
	seekPoints.clear();
	if (demuxer.findStream() != OggDemuxer::TYPE_THEORA)
		throw love::Exception("Could not rewind Theora video");
	int64 frame = -1;
	size_t unanchored = 0;
	while (!demuxer.readPacket(packet))
	{
		if (th_packet_isheader(&packet)) continue;
		++frame;
		if (th_packet_iskeyframe(&packet) == 1)
			seekPoints.push_back({demuxer.getPacketPosition(), frame});
		if (packet.granulepos >= 0)
		{
			const int64 actual = th_granule_frame(decoder, packet.granulepos);
			const int64 correction = actual - frame;
			// Granules timestamp the final packet of a page. Anchor keyframes
			// preceding that packet too, including streams with an initial offset.
			for (size_t i = unanchored; i < seekPoints.size(); ++i)
				seekPoints[i].frame += correction;
			unanchored = seekPoints.size();
			frame = actual;
		}
	}
	if (seekPoints.empty()) throw love::Exception("Theora video has no keyframe");
	indexBuilt = true;
}

void TheoraVideoStream::seek(double offset)
{
	VideoStream::seek(offset);
	seekRequested.store(true);
}

void TheoraVideoStream::seekDecoder(double target)
{
	buildSeekIndex();
	const double fps = double(videoInfo.fps_numerator) / videoInfo.fps_denominator;
	auto point = std::upper_bound(seekPoints.begin(), seekPoints.end(), target,
		[fps](double time, const SeekPoint &key) { return time < key.frame / fps; });
	if (point != seekPoints.begin()) --point;
	if (!demuxer.seek(packet, point->position))
		throw love::Exception("Could not seek to Theora keyframe");
	// A P-frame cannot be reconstructed from the frames of the old position.
	// Recreate decoder reference images, then decode from the indexed keyframe.
	th_decode_free(decoder);
	decoder = th_decode_alloc(&videoInfo, setup);
	if (!decoder) throw love::Exception("Could not reset Theora decoder");
	const int shift = videoInfo.keyframe_granule_shift;
	const int64 bias = 1 - th_granule_frame(decoder, int64(1) << shift);
	ogg_int64_t granule = (point->frame + bias) << shift;
	if (th_decode_ctl(decoder, TH_DECCTL_SET_GRANPOS, &granule, sizeof(granule)) != 0)
		throw love::Exception("Invalid Theora keyframe timestamp");
	packetPending = true;
	lastFrame = nextFrame = point->frame / fps;
	love::thread::Lock lock(bufferMutex);
	frameReady = false;
}

void TheoraVideoStream::threadedFillBackBuffer(double dt)
{
	StrongRef<FrameSync> sync;
	{
		love::thread::Lock lock(bufferMutex);
		sync = frameSync;
	}
	const bool requested = seekRequested.exchange(false);
	sync->update(dt);
	// Preserve the displayed image when paused or when an audio Source ends.
	// An explicit paused seek still decodes and publishes its target frame.
	if (!requested && !sync->isPlaying()) return;
	const double position = sync->getPosition();
	const double frameTime = double(videoInfo.fps_denominator) / videoInfo.fps_numerator;
	const bool backwards = position < previousPosition;
	previousPosition = position;
	if (requested || backwards || (!demuxer.isEos() && position >= nextFrame + 6 * frameTime))
		seekDecoder(position);
	bool hasFrame = false;
	while (!demuxer.isEos() && position + 1e-9 >= nextFrame)
	{
		if (!packetPending && demuxer.readPacket(packet)) break;
		// A page granule can reveal a timestamp gap. Hold the current image
		// until this packet's presentation time rather than displaying it early.
		if (packet.granulepos >= 0)
		{
			const double start = th_granule_time(decoder, packet.granulepos) - frameTime;
			if (start > position + 1e-9)
			{
				packetPending = true;
				nextFrame = start;
				break;
			}
		}
		packetPending = false;
		if (packet.granulepos >= 0)
			th_decode_ctl(decoder, TH_DECCTL_SET_GRANPOS, &packet.granulepos, sizeof(packet.granulepos));
		ogg_int64_t granule;
		const int result = th_decode_packetin(decoder, &packet, &granule);
		if (result < 0) throw love::Exception("Invalid Theora video packet");
		// A duplicate image still occupies a complete frame interval.
		nextFrame = th_granule_time(decoder, granule);
		lastFrame = std::max(0.0, nextFrame - frameTime);
		hasFrame = true;
	}
	if (!hasFrame) return;
	th_ycbcr_buffer planes;
	if (th_decode_ycbcr_out(decoder, planes) != 0)
		throw love::Exception("Could not read Theora video frame");
	// Copy only after all decoding: decoder-owned planes can rotate between packets.
	love::thread::Lock lock(bufferMutex);
	frameReady = false;
	for (int y = 0; y < backBuffer->yh; ++y)
		memcpy(backBuffer->yplane + backBuffer->yw * y,
			planes[0].data + planes[0].stride * (y + yPlaneYOffset) + yPlaneXOffset, backBuffer->yw);
	for (int y = 0; y < backBuffer->ch; ++y)
	{
		memcpy(backBuffer->cbplane + backBuffer->cw * y,
			planes[1].data + planes[1].stride * (y + cPlaneYOffset) + cPlaneXOffset, backBuffer->cw);
		memcpy(backBuffer->crplane + backBuffer->cw * y,
			planes[2].data + planes[2].stride * (y + cPlaneYOffset) + cPlaneXOffset, backBuffer->cw);
	}
	frameReady = true;
}
void TheoraVideoStream::fillBackBuffer()
{
	// Done in worker thread
}

bool TheoraVideoStream::swapBuffers()
{
	love::thread::Lock l(bufferMutex);
	if (!frameReady)
		return false;
	frameReady = false;

	Frame *temp = frontBuffer;
	frontBuffer = backBuffer;
	backBuffer = temp;

	return true;
}

} // theora
} // video
} // love
