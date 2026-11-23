/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

package org.ippclub.dorassr;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/** Rewrites the compiled manifest of Dora's own, monolithic APK. */
final class GameManifest {
	private static final int XML = 0x0003;
	private static final int STRING_POOL = 0x0001;
	private static final int START_ELEMENT = 0x0102;
	private static final int END_ELEMENT = 0x0103;
	private static final int UTF8_FLAG = 0x100;
	private static final int TYPE_REFERENCE = 0x01;
	private static final int TYPE_STRING = 0x03;
	private static final int TYPE_INT_DEC = 0x10;

	private GameManifest() {}

	static byte[] rewrite(byte[] manifest, String originalId, String gameId, String title,
			int versionCode, String versionName, int iconId) throws IOException {
		ByteBuffer data = buffer(manifest);
		if (u16(data, 0) != XML || u16(data, 2) != 8 || data.getInt(4) != manifest.length) {
			throw new IOException("Invalid binary Android manifest");
		}
		int poolStart = 8;
		int poolSize = data.getInt(poolStart + 4);
		StringPool pool = new StringPool(data, poolStart, poolSize);
		boolean foundPackage = false;
		boolean foundVersionCode = false;
		boolean foundVersionName = false;
		boolean foundLabel = false;
		boolean foundIcon = false;
		int filterStart = -1;
		boolean launcherFilter = false;
		int omitPermission = -1;
		int bodyStart = poolStart + poolSize;
		ByteArrayOutputStream body = new ByteArrayOutputStream();
		for (int chunk = poolStart + poolSize; chunk < data.capacity();) {
			int headerSize = u16(data, chunk + 2);
			int chunkSize = data.getInt(chunk + 4);
			if (chunkSize < 8 || chunkSize > data.capacity() - chunk) {
				throw new IOException("Invalid manifest chunk");
			}
			int chunkType = u16(data, chunk);
			if (chunkType == START_ELEMENT || chunkType == END_ELEMENT) {
				String tag = pool.get(data.getInt(chunk + headerSize + 4));
				if (chunkType == START_ELEMENT && "intent-filter".equals(tag)) {
					filterStart = chunk;
					launcherFilter = false;
				} else if (chunkType == END_ELEMENT && "intent-filter".equals(tag) && filterStart >= 0) {
					if (!launcherFilter) {
						body.write(manifest, bodyStart, filterStart - bodyStart);
						bodyStart = chunk + chunkSize;
					}
					filterStart = -1;
				} else if (chunkType == END_ELEMENT && omitPermission >= 0) {
					body.write(manifest, bodyStart, omitPermission - bodyStart);
					bodyStart = chunk + chunkSize;
					omitPermission = -1;
				}
			}
			if (chunkType == START_ELEMENT) {
				int element = chunk + headerSize;
				String tag = pool.get(data.getInt(element + 4));
				int attributeStart = element + u16(data, element + 8);
				int attributeSize = u16(data, element + 10);
				int count = u16(data, element + 12);
				if (attributeSize < 20 || attributeStart + attributeSize * (long) count > chunk + chunkSize) {
					throw new IOException("Invalid manifest attributes");
				}
				for (int i = 0; i < count; ++i) {
					int at = attributeStart + i * attributeSize;
					String name = pool.get(data.getInt(at + 4));
					int type = data.get(at + 15) & 255;
					int value = data.getInt(at + 16);
					String text = type == TYPE_STRING ? pool.get(value) : "";
					if (filterStart >= 0 && "action".equals(tag) && "name".equals(name)
							&& "android.intent.action.MAIN".equals(text)) {
						launcherFilter = true;
					} else if ("uses-permission".equals(tag) && "name".equals(name)
							&& "android.permission.REQUEST_INSTALL_PACKAGES".equals(text)) {
						omitPermission = chunk;
					} else if ("manifest".equals(tag) && "package".equals(name) && originalId.equals(text)) {
						setText(data, at, pool.add(gameId));
						foundPackage = true;
					} else if ("manifest".equals(tag) && "versionCode".equals(name)) {
						data.putInt(at + 8, -1);
						data.put(at + 15, (byte) TYPE_INT_DEC);
						data.putInt(at + 16, versionCode);
						foundVersionCode = true;
					} else if ("manifest".equals(tag) && "versionName".equals(name)) {
						setText(data, at, pool.add(versionName));
						foundVersionName = true;
					} else if ("application".equals(tag) && "label".equals(name)) {
						setText(data, at, pool.add(title));
						foundLabel = true;
					} else if ("application".equals(tag) && ("icon".equals(name) || "roundIcon".equals(name))) {
						data.putInt(at + 8, -1);
						data.put(at + 15, (byte) TYPE_REFERENCE);
						data.putInt(at + 16, iconId);
						if ("icon".equals(name)) foundIcon = true;
					} else if (("authorities".equals(name) || "permission".equals(name)
							|| ("permission".equals(tag) && "name".equals(name))
							|| ("uses-permission".equals(tag) && "name".equals(name)))
							&& text.startsWith(originalId + ".")) {
						setText(data, at, pool.add(gameId + text.substring(originalId.length())));
					} else if ("activity".equals(tag) && "name".equals(name) && text.startsWith(".")) {
						setText(data, at, pool.add(GameManifest.class.getPackage().getName() + text));
					}
				}
			}
			chunk += chunkSize;
		}
		if (!foundPackage || !foundVersionCode || !foundVersionName || !foundLabel || !foundIcon) {
			throw new IOException("The Dora APK manifest is missing game export metadata");
		}
		byte[] newPool = pool.encode();
		body.write(manifest, bodyStart, manifest.length - bodyStart);
		ByteBuffer result = buffer(new byte[poolStart + newPool.length + body.size()]);
		result.put(manifest, 0, poolStart).put(newPool).put(body.toByteArray());
		result.putInt(4, result.capacity());
		return result.array();
	}

	private static void setText(ByteBuffer data, int at, int index) {
		data.putInt(at + 8, index);
		data.put(at + 15, (byte) TYPE_STRING);
		data.putInt(at + 16, index);
	}

	private static ByteBuffer buffer(byte[] bytes) {
		return ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN);
	}

	private static int u16(ByteBuffer data, int position) {
		return data.getShort(position) & 0xffff;
	}

	private static final class StringPool {
		private final ByteBuffer data;
		private final int start;
		private final int size;
		private final int header;
		private final int count;
		private final int flags;
		private final int strings;
		private final boolean utf8;
		private final List<String> additions = new ArrayList<>();

		StringPool(ByteBuffer data, int start, int size) throws IOException {
			this.data = data;
			this.start = start;
			this.size = size;
			header = u16(data, start + 2);
			count = data.getInt(start + 8);
			flags = data.getInt(start + 16);
			strings = data.getInt(start + 20);
			utf8 = (flags & UTF8_FLAG) != 0;
			if (u16(data, start) != STRING_POOL || header < 28 || data.getInt(start + 12) != 0
					|| count < 0 || strings < header + count * 4L || strings > size
					|| size > data.capacity() - start) {
				throw new IOException("Unsupported manifest string pool");
			}
		}

		String get(int index) throws IOException {
			if (index < 0 || index >= count) throw new IOException("Invalid manifest string index");
			int at = start + strings + data.getInt(start + header + index * 4);
			int bytes;
			if (utf8) {
				at += (data.get(at) & 0x80) == 0 ? 1 : 2;
				int length = data.get(at++) & 255;
				bytes = (length & 0x80) == 0 ? length : ((length & 0x7f) << 8) | (data.get(at++) & 255);
			} else {
				int length = u16(data, at);
				at += 2;
				if ((length & 0x8000) != 0) {
					length = ((length & 0x7fff) << 16) | u16(data, at);
					at += 2;
				}
				bytes = Math.multiplyExact(length, 2);
			}
			if (bytes < 0 || at < start + strings || bytes > start + size - at) {
				throw new IOException("Invalid manifest string");
			}
			return new String(data.array(), at, bytes, utf8 ? StandardCharsets.UTF_8 : StandardCharsets.UTF_16LE);
		}

		int add(String text) {
			additions.add(text);
			return count + additions.size() - 1;
		}

		byte[] encode() throws IOException {
			ByteArrayOutputStream encoded = new ByteArrayOutputStream();
			int[] offsets = new int[additions.size()];
			int oldBytes = size - strings;
			for (int i = 0; i < offsets.length; ++i) {
				offsets[i] = oldBytes + encoded.size();
				String text = additions.get(i);
				byte[] bytes = text.getBytes(utf8 ? StandardCharsets.UTF_8 : StandardCharsets.UTF_16LE);
				if (text.length() > 0x7fff || bytes.length > 0x7fff) throw new IOException("Game metadata is too long");
				if (utf8) {
					writeLength(encoded, text.length());
					writeLength(encoded, bytes.length);
				} else {
					encoded.write(text.length() & 255);
					encoded.write(text.length() >>> 8);
				}
				encoded.write(bytes);
				encoded.write(0);
				if (!utf8) encoded.write(0);
			}
			while ((encoded.size() & 3) != 0) encoded.write(0);
			int stringStart = strings + offsets.length * 4;
			ByteBuffer result = buffer(new byte[size + offsets.length * 4 + encoded.size()]);
			result.put(data.array(), start, header + count * 4);
			for (int offset : offsets) result.putInt(offset);
			result.position(stringStart);
			result.put(data.array(), start + strings, oldBytes).put(encoded.toByteArray());
			result.putInt(4, result.capacity()).putInt(8, count + offsets.length)
					.putInt(16, flags & ~1).putInt(20, stringStart);
			return result.array();
		}

		private static void writeLength(ByteArrayOutputStream stream, int length) {
			if (length > 127) stream.write((length >>> 8) | 0x80);
			stream.write(length & 255);
		}
	}
}
