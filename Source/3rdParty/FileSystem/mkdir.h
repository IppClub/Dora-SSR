#ifndef __MKDIR__
#define __MKDIR__

#include <sys/stat.h>
#include <cstdio>
#ifdef _MSC_VER
	#include <direct.h>
	#pragma warning (disable : 4996)
#else
	#include <fcntl.h>
	#include <unistd.h>
#endif

#ifdef _MSC_VER
	#define MKDIR(a) _mkdir(a)
	#define RMDIR(a) _rmdir(a)
#else
	#define MKDIR(a) mkdir(a,0755)
	#define RMDIR(a) rmdir(a)
#endif

#endif // __MKDIR__
