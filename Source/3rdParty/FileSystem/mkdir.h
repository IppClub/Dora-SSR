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
	#include <stdarg.h>
#endif

#ifdef _MSC_VER
	#define MKDIR(a) _mkdir(a)
	#define RMDIR(a) _rmdir(a)
#else
	#define MKDIR(a) mkdir(a,0755)
	#define RMDIR(a) rmdir(a)
#endif

#ifdef USE_COPY_FILE
static void CopyFile(const char* src, const char* dst)
{
	char buf[BUFSIZ];
    size_t size;

#ifdef _MSC_VER
	FILE* source = fopen(src, "rb");
	FILE* dest = fopen(dst,"wb");
	while (size = fread(buf,1,BUFSIZ,source))
	{
		fwrite(buf,1,size,dest);
	}
	fclose(source);
	fclose(dest);
#else
    int source = open(src, O_RDONLY, 0);
    int dest = open(dst, O_WRONLY | O_CREAT, 0644);

    while ((size = read(source, buf, BUFSIZ)) > 0)
	{
        write(dest, buf, size);
    }

    close(source);
    close(dest);
#endif
}
#endif // USE_COPY_FILE

static int FileExist(const char* filename)
{
	struct stat buf;
	return ::stat(filename, &buf);
}

static int CreateDir(const char* dir, size_t len)
{
	const int MAX_PATH_LEN = 256;
	if (len > MAX_PATH_LEN - 2) return -1;
	char pszDir[MAX_PATH_LEN];
	strcpy(pszDir, dir);

	if (pszDir[len - 1] != '\\' && pszDir[len - 1] != '/')
	{
		pszDir[len] = '/';
		pszDir[len + 1] = '\0';
	}

	for (size_t i = 0; i < len + 1; i++)
	{
		if (i != 0 && (pszDir[i] == '\\' || pszDir[i] == '/') && pszDir[i - 1] != ':')
		{
			pszDir[i] = '\0';
			int iRet = FileExist(pszDir);
			if (iRet != 0)
			{
				iRet = MKDIR(pszDir);
				if (iRet != 0)
				{
					return -1;
				}
			}
			pszDir[i] = '/';
		}
	}
	return 0;
}

#endif
