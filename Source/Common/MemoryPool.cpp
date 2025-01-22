/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#include "Const/Header.h"

#include "Common/MemoryPool.h"

NS_DORA_BEGIN

MemoryPool::MemoryPool(int itemSize, int chunkCapacity)
	: _itemSize(itemSize)
	, _chunkCapacity(chunkCapacity)
	, _chunk(new Chunk(chunkCapacity))
	, _freeList(nullptr) { }

MemoryPool::~MemoryPool() {
	deleteChunk(_chunk);
}

void* MemoryPool::alloc() {
	if (_freeList) {
		FreeList* head = _freeList;
		_freeList = _freeList->next;
		return r_cast<void*>(head);
	} else {
		if (_chunk->size + _itemSize > _chunkCapacity) {
			_chunk = new Chunk(_chunkCapacity, _chunk);
			int consumption = getCapacity();
			if (consumption > DEFAULT_WARNING_SIZE * 1024) {
				static bool warned = false;
				if (!warned) {
					warned = true;
					Warn("MemoryPool consumes memory larger than {} KB for item of size {} B", DEFAULT_WARNING_SIZE, _itemSize);
				}
			}
		}
		char* addr = _chunk->buffer + _chunk->size;
		_chunk->size += _itemSize;
		return r_cast<void*>(addr);
	}
}

void MemoryPool::free(void* addr) {
	FreeList* freeItem = r_cast<FreeList*>(addr);
	freeItem->next = _freeList;
	_freeList = freeItem;
}

int MemoryPool::collect() {
	int oldSize = getCapacity();
	Chunk* prevChunk = nullptr;
	FreeList* sortedChunkList = nullptr;
	FreeList* sortedChunkListTail = nullptr;
	FreeList* prev = nullptr;
	for (Chunk* chunk = _chunk->next; chunk;) {
		size_t begin = (size_t)chunk->buffer;
		size_t end = begin + _chunkCapacity;
		int count = 0;
		FreeList* chunkList = nullptr;
		FreeList* chunkListTail = nullptr;
		prev = nullptr;
		for (FreeList* list = _freeList; list;) {
			size_t loc = (size_t)list;
			if (begin <= loc && loc < end) {
				++count;
				FreeList* temp = list;
				if (prev)
					prev->next = list->next;
				else
					_freeList = list->next;
				list = list->next;
				temp->next = chunkList;
				chunkList = temp;
				if (!chunkListTail) chunkListTail = chunkList;
			} else {
				prev = list;
				list = list->next;
			}
		}
		if (count == int(_chunkCapacity / _itemSize)) {
			Chunk* temp = chunk;
			if (prevChunk)
				prevChunk->next = chunk->next;
			else
				_chunk->next = chunk->next;
			chunk = chunk->next;
			delete temp;
		} else {
			if (sortedChunkListTail) {
				sortedChunkListTail->next = chunkList;
			} else
				sortedChunkList = chunkList;
			sortedChunkListTail = chunkListTail;
			prevChunk = chunk;
			chunk = chunk->next;
		}
	}
	if (prev)
		prev->next = sortedChunkList;
	else
		_freeList = sortedChunkList;
	int newSize = getCapacity();
	return oldSize - newSize;
}

void MemoryPool::deleteChunk(Chunk* chunk) {
	if (chunk) {
		deleteChunk(chunk->next);
		delete chunk;
	}
}

int MemoryPool::getItemSize() const {
	return _itemSize;
}

int MemoryPool::getCapacity() const {
	int chunkCount = 0;
	for (Chunk* chunk = _chunk; chunk; chunk = chunk->next) {
		++chunkCount;
	}
	return chunkCount * _chunkCapacity;
}

static std::list<Own<MemoryPool>>& getMemoryPools() {
	static std::list<Own<MemoryPool>> pools;
	return pools;
}

MemoryPool* MemoryPool::get(int itemSize) {
	auto& pools = getMemoryPools();
	for (const auto& pool : pools) {
		if (pool->getItemSize() == itemSize) {
			return pool.get();
		}
	}
	return pools.emplace_back(New<MemoryPool>(itemSize, DEFAULT_CHUNK_CAPACITY)).get();
}

int MemoryPool::getTotalCapacity() {
	int capacity = 0;
	auto& pools = getMemoryPools();
	for (const auto& pool : pools) {
		capacity += pool->getCapacity();
	}
	return capacity;
}

int MemoryPool::collectAll() {
	int collected = 0;
	auto& pools = getMemoryPools();
	for (const auto& pool : pools) {
		collected += pool->collect();
	}
	return collected;
}

NS_DORA_END
