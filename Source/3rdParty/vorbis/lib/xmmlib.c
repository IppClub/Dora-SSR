/********************************************************************
 *                                                                  *
 * THIS FILE IS PART OF THE OggVorbis SOFTWARE CODEC SOURCE CODE.   *
 * USE, DISTRIBUTION AND REPRODUCTION OF THIS LIBRARY SOURCE IS     *
 * GOVERNED BY A BSD-STYLE SOURCE LICENSE INCLUDED WITH THIS SOURCE *
 * IN 'COPYING'. PLEASE READ THESE TERMS BEFORE DISTRIBUTING.       *
 *                                                                  *
 * THE OggVorbis SOURCE CODE IS (C) COPYRIGHT 1994-2003             *
 * by the XIPHOPHORUS Company http://www.xiph.org/                  *
 *                                                                  *
 ********************************************************************

 function: SSE Function Library

 ********************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <memory.h>
#include "xmmlib.h"

#if	defined(__SSE__)
_MM_ALIGN16 const uint32_t PCS_NNRN[4]	 = {0x00000000, 0x80000000, 0x00000000, 0x00000000};
_MM_ALIGN16 const uint32_t PCS_NNRR[4]	 = {0x80000000, 0x80000000, 0x00000000, 0x00000000};
_MM_ALIGN16 const uint32_t PCS_NRNN[4]	 = {0x00000000, 0x00000000, 0x80000000, 0x00000000};
_MM_ALIGN16 const uint32_t PCS_NRNR[4]	 = {0x80000000, 0x00000000, 0x80000000, 0x00000000};
_MM_ALIGN16 const uint32_t PCS_NRRN[4]	 = {0x00000000, 0x80000000, 0x80000000, 0x00000000};
_MM_ALIGN16 const uint32_t PCS_NRRR[4]	 = {0x80000000, 0x80000000, 0x80000000, 0x00000000};
_MM_ALIGN16 const uint32_t PCS_RNNN[4]	 = {0x00000000, 0x00000000, 0x00000000, 0x80000000};
_MM_ALIGN16 const uint32_t PCS_RNRN[4]	 = {0x00000000, 0x80000000, 0x00000000, 0x80000000};
_MM_ALIGN16 const uint32_t PCS_RNRR[4]	 = {0x80000000, 0x80000000, 0x00000000, 0x80000000};
_MM_ALIGN16 const uint32_t PCS_RRNN[4]	 = {0x00000000, 0x00000000, 0x80000000, 0x80000000};
_MM_ALIGN16 const uint32_t PCS_RNNR[4]	 = {0x80000000, 0x00000000, 0x00000000, 0x80000000};
_MM_ALIGN16 const uint32_t PCS_RRRR[4]	 = {0x80000000, 0x80000000, 0x80000000, 0x80000000};
_MM_ALIGN16 const uint32_t PCS_NNNR[4]	 = {0x80000000, 0x00000000, 0x00000000, 0x00000000};
_MM_ALIGN16 const uint32_t PABSMASK[4]	 = {0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF, 0x7FFFFFFF};
_MM_ALIGN16 const uint32_t PSTARTEDGEM1[4]	 = {0x00000000, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF};
_MM_ALIGN16 const uint32_t PSTARTEDGEM2[4]	 = {0x00000000, 0x00000000, 0xFFFFFFFF, 0xFFFFFFFF};
_MM_ALIGN16 const uint32_t PSTARTEDGEM3[4]	 = {0x00000000, 0x00000000, 0x00000000, 0xFFFFFFFF};
_MM_ALIGN16 const uint32_t PENDEDGEM1[4]	 = {0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000};
_MM_ALIGN16 const uint32_t PENDEDGEM2[4]	 = {0xFFFFFFFF, 0xFFFFFFFF, 0x00000000, 0x00000000};
_MM_ALIGN16 const uint32_t PENDEDGEM3[4]	 = {0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000};

_MM_ALIGN16 const uint32_t PMASKTABLE[4*16] = {
	0x00000000, 0x00000000, 0x00000000, 0x00000000,
	0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000,
	0x00000000, 0xFFFFFFFF, 0x00000000, 0x00000000,
	0xFFFFFFFF, 0xFFFFFFFF, 0x00000000, 0x00000000,
	0x00000000, 0x00000000, 0xFFFFFFFF, 0x00000000,
	0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0x00000000,
	0x00000000, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000,
	0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000,
	0x00000000, 0x00000000, 0x00000000, 0xFFFFFFFF,
	0xFFFFFFFF, 0x00000000, 0x00000000, 0xFFFFFFFF,
	0x00000000, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
	0xFFFFFFFF, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
	0x00000000, 0x00000000, 0xFFFFFFFF, 0xFFFFFFFF,
	0xFFFFFFFF, 0x00000000, 0xFFFFFFFF, 0xFFFFFFFF,
	0x00000000, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF,
	0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
};

_MM_ALIGN16 const float PFV_0[4]    = { 0.0f, 0.0f, 0.0f, 0.0f};
_MM_ALIGN16 const float PFV_1[4]    = { 1.0f, 1.0f, 1.0f, 1.0f};
_MM_ALIGN16 const float PFV_2[4]    = { 2.0f, 2.0f, 2.0f, 2.0f};
_MM_ALIGN16 const float PFV_4[4]    = { 4.0f, 4.0f, 4.0f, 4.0f};
_MM_ALIGN16 const float PFV_8[4]    = { 8.0f, 8.0f, 8.0f, 8.0f};
_MM_ALIGN16 const float PFV_INIT[4] = { 0.0f, 1.0f, 2.0f, 3.0f};
_MM_ALIGN16 const float PFV_0P5[4]  = { 0.5f, 0.5f, 0.5f, 0.5f};
_MM_ALIGN16 const float PFV_M0P5[4] = {-0.5f,-0.5f,-0.5f,-0.5f};

#endif /* defined(__SSE__) */

const int bitCountTable[16] = {
	0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4
};

#if	0
/*---------------------------------------------------------------------------
// for calcurate performance
//-------------------------------------------------------------------------*/
static double perfsum[16];
static unsigned long perfcount[16];

unsigned __int64* _perf_start(void)
{
    unsigned __int64* stime;
#pragma omp critical
  {
    stime = malloc(sizeof(*stime));
    *stime = _rdtsc();
  }
  return stime;
}

void _perf_end(unsigned __int64 *stime, int index)
{
  *stime = _rdtsc() - *stime;
#pragma omp critical
  {
	perfsum[index] += (double)(*stime);
	perfcount[index] ++;
  }
  free(stime);
}

void _perf_result(int index)
{
  printf("\nPerfSum   = %f\n", perfsum[index]);
  printf("PerfCount = %d\n", perfcount[index]);
  printf("PerfAvg   = %f\n", perfsum[index]/(double)perfcount[index]);
}
#endif

/*---------------------------------------------------------------------------
// 16Byte Allignment malloc
//-------------------------------------------------------------------------*/
void* xmm_malloc(size_t size)
{
#ifdef _WIN32
	return (void*)_aligned_malloc(size, 16);
#else
	int offset = 15 + 2*sizeof(void*);
	void* p1 = (void*)malloc(size + offset);
	void** p2 = (void**)(((size_t)(p1) + offset) & ~15);
	if (p1 == NULL) return NULL;
	p2[-1] = (void*)size;
	p2[-2] = p1;
	return p2;
#endif
}
/*---------------------------------------------------------------------------
// 16Byte Allignment calloc
//-------------------------------------------------------------------------*/
void* xmm_calloc(size_t nitems, size_t size)
{
	unsigned char*	t_RetPtr	 = (unsigned char*)xmm_malloc(nitems*size);

	if(t_RetPtr)
	{
#ifdef	__SSE__
		size_t	i,j, k;
		__m128	XMM0, XMM1, XMM2, XMM3;
		XMM0	 =
		XMM1	 =
		XMM2	 =
		XMM3	 = _mm_setzero_ps();
		k	 = nitems*size;
		j	 = k&(~127);
		for(i=0;i<j;i+=128)
		{
			_mm_stream_ps((float*)(t_RetPtr+i    ), XMM0);
			_mm_stream_ps((float*)(t_RetPtr+i+ 16), XMM1);
			_mm_stream_ps((float*)(t_RetPtr+i+ 32), XMM2);
			_mm_stream_ps((float*)(t_RetPtr+i+ 48), XMM3);
			_mm_stream_ps((float*)(t_RetPtr+i+ 64), XMM0);
			_mm_stream_ps((float*)(t_RetPtr+i+ 80), XMM1);
			_mm_stream_ps((float*)(t_RetPtr+i+ 96), XMM2);
			_mm_stream_ps((float*)(t_RetPtr+i+112), XMM3);
		}
		j	 = k&(~63);
		for(;i<j;i+=64)
		{
			_mm_stream_ps((float*)(t_RetPtr+i    ), XMM0);
			_mm_stream_ps((float*)(t_RetPtr+i+ 16), XMM1);
			_mm_stream_ps((float*)(t_RetPtr+i+ 32), XMM2);
			_mm_stream_ps((float*)(t_RetPtr+i+ 48), XMM3);
		}
		j	 = k&(~31);
		for(;i<j;i+=32)
		{
			_mm_stream_ps((float*)(t_RetPtr+i    ), XMM0);
			_mm_stream_ps((float*)(t_RetPtr+i+ 16), XMM1);
		}
		j	 = k&(~15);
		for(;i<j;i+=16)
		{
			_mm_stream_ps((float*)(t_RetPtr+i    ), XMM0);
		}
		j	 = k&(~7);
		for(;i<j;i+=8)
		{
			_mm_storel_pi((__m64*)(t_RetPtr+i   ), XMM0);
		}
		j	 = k&(~3);
		for(;i<j;i+=4)
		{
			_mm_store_ss((float*)(t_RetPtr+i)   , XMM0);
		}
		for(;i<k;i++)
			*(t_RetPtr+i    )	 = 0;
		_mm_sfence();
#else
		memset(t_RetPtr, 0, nitems*size);
#endif
	}
	return	(void*)t_RetPtr;
}
/*---------------------------------------------------------------------------
// 16Byte Allignment free
//-------------------------------------------------------------------------*/
void xmm_free(void* a_AlignedPtr)
{
    if(a_AlignedPtr)
#ifdef _WIN32
        _aligned_free(a_AlignedPtr);
#else
        free(((void**)a_AlignedPtr)[-2]);
#endif
}
/*---------------------------------------------------------------------------
// 16Byte Allignment realloc
//-------------------------------------------------------------------------*/
void* xmm_realloc(void *block, size_t size)
{
#ifdef _WIN32
	return (void*)_aligned_realloc(block, size, 16);
#else
	void *newblock = 0;
	size_t blsize = 0;
	if (!block) return xmm_malloc(size);
	blsize = (size_t) ((void**)block)[-1];
	if (size <= blsize) return block;
	newblock = xmm_malloc(size);
	memcpy(newblock, block, blsize);
	xmm_free(block);
	return newblock;
#endif
}
/*---------------------------------------------------------------------------
// 16Byte Allignment alloca
//-------------------------------------------------------------------------*/
void* xmm_align(void *t_Ptr)
{
	unsigned char*	t_RetPtr		 = 0;
	if(t_Ptr){
		t_RetPtr	 = (unsigned char*)(( ((intptr_t)t_Ptr+15)/16)*16);
	}
	return	(void*)t_RetPtr;
}
