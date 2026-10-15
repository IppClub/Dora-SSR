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

 function: CPU ID Check

 ********************************************************************/

#if defined(__INTEL_COMPILER)&&defined(_WIN32)&&defined(_USRDLL)
#if defined(_WIN64)
#include <intrin.h>
#endif

extern int __intel_cpu_indicator;

void __intel_cpu_indicator_init(void)
{
	unsigned int t, u;
#if !defined(_WIN64)
    _asm {
		mov	eax,1
		cpuid
		mov	t, edx
		mov	u, ecx
	}
#else
	{
		int CPUInfo[4];
		__cpuid(CPUInfo, 1);
		u = CPUInfo[2];
		t = CPUInfo[3];
	}
#endif
	/* SSE3 Check */
	if(u&0x0000001)
	{
		__intel_cpu_indicator = 0x800;
		return;
	}
	/* SSE2 Check */
	if(t&0x4000000)
	{
		__intel_cpu_indicator = 0x200;
		return;
	}
	/* SSE Check */
	if(t&0x2000000)
	{
		__intel_cpu_indicator = 0x100;
		return;
	}
	__intel_cpu_indicator = 1;
}
#endif
