/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <new>
#include <utility>

NS_DORA_BEGIN

#ifndef DEFAULT_CHUNK_CAPACITY
#define DEFAULT_CHUNK_CAPACITY 4096 // 4KB
#endif // DEFAULT_CHUNK_CAPACITY

#ifndef DEFAULT_WARNING_SIZE
#define DEFAULT_WARNING_SIZE 1024 // 1MB
#endif // DEFAULT_WARNING_SIZE

class MemoryPool {
public:
	MemoryPool(int itemSize, int chunkCapacity);
	~MemoryPool();
	void* alloc();
	void free(void* addr);
	int getItemSize() const;
	int getCapacity() const;
	int collect();
	static MemoryPool* get(int itemSize);
	static int getTotalCapacity();
	static int collectAll();

private:
	struct FreeList {
		FreeList* next;
	};
	struct Chunk {
		Chunk(int capacity, Chunk* next = nullptr)
			: buffer(new char[capacity])
			, size(0)
			, next(next) { }
		~Chunk() { delete[] buffer; }
		int size;
		char* buffer;
		Chunk* next;
	};
	int _itemSize;
	int _chunkCapacity;
	FreeList* _freeList;
	Chunk* _chunk;
	void deleteChunk(Chunk* chunk);
};

template <class Item>
class MemoryPoolImpl {
#define ITEM_SIZE sizeof(Item)
public:
	MemoryPoolImpl() {
		static_assert(ITEM_SIZE >= sizeof(intptr_t),
			"Size of pool item must be greater or equal to the size of a pointer.");
		_pool = MemoryPool::get(ITEM_SIZE);
	}
	inline void* alloc() {
		return _pool->alloc();
	}
	inline void free(void* addr) {
		_pool->free(addr);
	}

private:
	MemoryPool* _pool;
};

#define USE_MEMORY_POOL(type) \
public: \
	inline void* operator new(size_t) { return _memory.alloc(); } \
	inline void operator delete(void* ptr, size_t) { _memory.free(ptr); } \
\
private: \
	static MemoryPoolImpl<type> _memory

#define MEMORY_POOL(type) \
	MemoryPoolImpl<type> type::_memory

NS_DORA_END
