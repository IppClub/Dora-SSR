/* Copyright (c) 2021 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <utility>
#include <new>

NS_DOROTHY_BEGIN

#ifndef DEFAULT_CHUNK_CAPACITY
#define DEFAULT_CHUNK_CAPACITY 4096 // 4KB
#endif // DEFAULT_CHUNK_CAPACITY

#ifndef DEFAULT_WARNING_SIZE
#define DEFAULT_WARNING_SIZE 1024 // 1MB
#endif // DEFAULT_WARNING_SIZE

class IMemoryPool
{
public:
	virtual ~IMemoryPool() { }
	virtual int getCapacity() const = 0;
	virtual int collect() = 0;
};

class MemoryPool
{
public:
	static void push(IMemoryPool* pool);
	static int getCapacity();
	static int collect();
};

template<class Item, int CHUNK_CAPACITY = DEFAULT_CHUNK_CAPACITY, int WARNING_SIZE = DEFAULT_WARNING_SIZE>
class MemoryPoolImpl : public IMemoryPool
{
#define ITEM_SIZE sizeof(Item)
public:
	MemoryPoolImpl() :
		_chunk(new Chunk()),
		_freeList(nullptr)
	{
		static_assert(ITEM_SIZE >= sizeof(intptr_t),
			"Size of pool item must be greater or equal to the size of a pointer.");
		MemoryPool::push(this);
	}
	virtual ~MemoryPoolImpl()
	{
		MemoryPoolImpl::deleteChunk(_chunk);
	}
	void* alloc()
	{
		if (_freeList)
		{
			FreeList* head = _freeList;
			_freeList = _freeList->next;
			return r_cast<void*>(head);
		}
		else
		{
			if (_chunk->size + ITEM_SIZE > CHUNK_CAPACITY)
			{
				_chunk = new Chunk(_chunk);
				int consumption = MemoryPoolImpl::getCapacity();
				if (consumption > WARNING_SIZE * 1024)
				{
					Warn("MemoryPool consumes %d KB memory larger than {} KB for type {}",
						consumption / 1024, WARNING_SIZE, typeid(Item).name());
				}
			}
			char* addr = _chunk->buffer + _chunk->size;
			_chunk->size += ITEM_SIZE;
			return r_cast<void*>(addr);
		}
	}
	void free(void* addr)
	{
		FreeList* freeItem = r_cast<FreeList*>(addr);
		freeItem->next = _freeList;
		_freeList = freeItem;
	}
	template<class... Args>
	Item* newItem(Args&&... args)
	{
		Item* mem = r_cast<Item*>(MemoryPoolImpl::alloc());
		return new (mem) Item(std::forward<Args>(args)...);
	}
	void deleteItem(Item* item)
	{
		item->~Item();
		MemoryPoolImpl::free(r_cast<void*>(item));
	}
	virtual int getCapacity() const override
	{
		int chunkCount = 0;
		for (Chunk* chunk = _chunk; chunk; chunk = chunk->next)
		{
			++chunkCount;
		}
		return chunkCount * CHUNK_CAPACITY;
	}
	virtual int collect() override
	{
		int oldSize = getCapacity();
		Chunk* prevChunk = nullptr;
		FreeList* sortedChunkList = nullptr;
		FreeList* sortedChunkListTail = nullptr;
		FreeList* prev = nullptr;
		for (Chunk* chunk = _chunk->next; chunk;)
		{
			size_t begin = (size_t)chunk->buffer;
			size_t end = begin + CHUNK_CAPACITY;
			int count = 0;
			FreeList* chunkList = nullptr;
			FreeList* chunkListTail = nullptr;
			prev = nullptr;
			for (FreeList* list = _freeList; list;)
			{
				size_t loc = (size_t)list;
				if (begin <= loc && loc < end)
				{
					++count;
					FreeList* temp = list;
					if (prev) prev->next = list->next;
					else _freeList = list->next;
					list = list->next;
					temp->next = chunkList;
					chunkList = temp;
					if (!chunkListTail) chunkListTail = chunkList;
				}
				else
				{
					prev = list;
					list = list->next;
				}
			}
			if (count == int(CHUNK_CAPACITY / ITEM_SIZE))
			{
				Chunk* temp = chunk;
				if (prevChunk) prevChunk->next = chunk->next;
				else _chunk->next = chunk->next;
				chunk = chunk->next;
				delete temp;
			}
			else
			{
				if (sortedChunkListTail)
				{
					sortedChunkListTail->next = chunkList;
				}
				else sortedChunkList = chunkList;
				sortedChunkListTail = chunkListTail;
				prevChunk = chunk;
				chunk = chunk->next;
			}
		}
		if (prev) prev->next = sortedChunkList;
		else _freeList = sortedChunkList;
		int newSize = getCapacity();
		return oldSize - newSize;
	}
private:
	struct FreeList
	{
		FreeList* next;
	};
	struct Chunk
	{
		Chunk(Chunk* next = nullptr) :
			buffer(new char[CHUNK_CAPACITY]),
			size(0),
			next(next)
		{ }
		~Chunk() { delete[] buffer; }
		int size;
		char* buffer;
		Chunk* next;
	};
	FreeList* _freeList;
	Chunk* _chunk;
	void deleteChunk(Chunk* chunk)
	{
		if (chunk)
		{
			MemoryPoolImpl::deleteChunk(chunk->next);
			delete chunk;
		}
	}
};

#define USE_MEMORY_POOL_SIZE(type, CAPSIZE, WARNSIZE) \
public: \
	inline void* operator new(size_t) { return _memory.alloc(); } \
	inline void operator delete(void* ptr, size_t) { _memory.free(ptr); } \
	static int poolCollect() \
	{ \
		return _memory.collect(); \
	} \
	static int getPoolSize() \
	{ \
		return _memory.getCapacity(); \
	} \
private: \
	static MemoryPoolImpl<type, CAPSIZE, WARNSIZE> _memory

#define USE_MEMORY_POOL(type) \
	USE_MEMORY_POOL_SIZE(type, DEFAULT_CHUNK_CAPACITY, DEFAULT_WARNING_SIZE)

#define MEMORY_POOL_SIZE(type, CAPSIZE, WARNSIZE) \
	MemoryPoolImpl<type, CAPSIZE, WARNSIZE> type::_memory

#define MEMORY_POOL(type) \
	MEMORY_POOL_SIZE(type, DEFAULT_CHUNK_CAPACITY, DEFAULT_WARNING_SIZE)

NS_DOROTHY_END
