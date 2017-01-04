/* Copyright (c) 2016 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include "Const/Define.h"
#include <utility>
#include <new>

NS_DOROTHY_BEGIN

template<class Item, int CHUNK_CAPACITY = 4096, int WARNING_SIZE = 1024>// 4KB 1MB
class MemoryPool
{
#define ITEM_SIZE sizeof(Item)
public:
	MemoryPool() :
		_chunk(new Chunk()),
		_freeList(nullptr)
	{
		static_assert(ITEM_SIZE >= sizeof(intptr_t),
			"Size of pool item must be greater or equal to the size of a pointer.");
	}
	~MemoryPool()
	{
		MemoryPool::deleteChunk(_chunk);
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
				int consumption = MemoryPool::capacity();
				if (consumption > WARNING_SIZE * 1024)
				{
					Log("[WARNING] MemoryPool consumes %d KB memory larger than %d KB for type %s",
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
		Item* mem = r_cast<Item*>(MemoryPool<Item, CHUNK_CAPACITY>::alloc());
		return new (mem) Item(std::forward<Args>(args)...);
	}
	void deleteItem(Item* item)
	{
		item->~Item();
		MemoryPool<Item, CHUNK_CAPACITY>::free(r_cast<void*>(item));
	}
	int capacity()
	{
		int chunkCount = 0;
		for (Chunk* chunk = _chunk; chunk; chunk = chunk->next)
		{
			++chunkCount;
		}
		return chunkCount * CHUNK_CAPACITY;
	}
	void shrink()
	{
		Chunk* prevChunk = nullptr;
		FreeList* sortedChunkList = nullptr; // 总空闲队列
		FreeList* sortedChunkListTail = nullptr; // 总空闲队列尾
		FreeList* prev = nullptr; // 前一个遍历到的原回收队列的item
		for (Chunk* chunk = _chunk->next; chunk;) // 从_chunk的next开始检测，保留根部的chunk不被释放
		{
			size_t begin = (size_t)chunk->buffer;
			size_t end = begin + CHUNK_CAPACITY;
			int count = 0;
			FreeList* chunkList = nullptr; // 找到的属于当前的chunk的item队列
			FreeList* chunkListTail = nullptr; // 当前的chunk的item队列尾
			prev = nullptr; // 遍历的前一个item
			for (FreeList* list = _freeList; list;) // 遍历整个回收来的item队列
			{
				size_t loc = (size_t)list;
				if (begin <= loc && loc < end) // 检查当前item是否属于当前的chunk
				{
					++count; // 记录找到属于chunk的空闲item的数量
					FreeList* temp = list;
					if (prev) prev->next = list->next; // 从链表中间取出当前的item
					else _freeList = list->next; // 从链表头部取出当前的item
					list = list->next; // 遍历到下一个item
					temp->next = chunkList;
					chunkList = temp; // 将找到的item添加到当前chunk的item队列头部
					if (!chunkListTail) chunkListTail = chunkList; // 记录尾节点
				}
				else
				{
					prev = list; // 记录上一个item
					list = list->next; // 遍历到下一个item
				}
			}
			if (count == (int)(CHUNK_CAPACITY / ITEM_SIZE)) // 发现chunk中的所有item都是空闲的
			{
				Chunk* temp = chunk;
				if (prevChunk) prevChunk->next = chunk->next; // 从链表中间取出当前的chunk
				else _chunk->next = chunk->next; // 从链表头部取出当前的chunk
				chunk = chunk->next; // 遍历到下一个chunk
				delete temp; // 删除当前chunk
			}
			else
			{
				if (sortedChunkListTail)
				{
					sortedChunkListTail->next = chunkList; // 往总空闲队列的尾部添加当前chunk的空闲队列
				}
				else sortedChunkList = chunkList; // 记录总空闲队列的头部
				sortedChunkListTail = chunkListTail; // 总空闲队列的尾部设置为当前chunk空闲队列的尾部
				prevChunk = chunk; // 记录上一个chunk
				chunk = chunk->next; // 遍历到下一个chunk
			}
		}
		if (prev) prev->next = sortedChunkList; // prev现在为原回收队列的队尾，往队尾接上总空闲队列
		else _freeList = sortedChunkList; // 将回收队列设置为总空闲队列
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
		~Chunk() { delete [] buffer; }
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
			MemoryPool::deleteChunk(chunk->next);
			delete chunk;
		}
	}
};

#define USE_MEMORY_POOL_SIZE(type, SIZE) \
public:\
	inline void* operator new(size_t size) { return _memory.alloc(); }\
	inline void operator delete(void* ptr, size_t size) { _memory.free(ptr); }\
	static int poolCollect()\
	{\
		int oldSize = _memory.capacity();\
		_memory.shrink();\
		int newSize = _memory.capacity();\
		return oldSize - newSize;\
	}\
	static int poolSize()\
	{\
		return _memory.capacity();\
	}\
private:\
	static MemoryPool<type, SIZE> _memory

#define USE_MEMORY_POOL(type) USE_MEMORY_POOL_SIZE(type, 4096)

#define MEMORY_POOL_SIZE(type, SIZE) \
MemoryPool<type, SIZE> type::_memory

#define MEMORY_POOL(type) MEMORY_POOL_SIZE(type, 4096)

NS_DOROTHY_END
