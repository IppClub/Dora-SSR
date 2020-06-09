/****************************************************************************
Copyright (c) 2010 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "Const/Header.h"
using namespace Dorothy;
#include "Zip/Support/ZipUtils.h"
#include "Zip/Support/unzip.h"

#include <zlib.h>
#include <assert.h>
#include <stdlib.h>
#include <ctype.h>

// --------------------- ZipFile ---------------------
// from unzip.cpp
#define UNZ_MAXFILENAMEINZIP 256

struct ZipEntryInfo
{
	unz_file_pos pos;
	uLong uncompressed_size;
};

class ZipFilePrivate
{
public:
	unzFile zipFile;
	std::unordered_map<std::string, ZipEntryInfo> fileList;
	std::unordered_set<std::string> folderList;
};

ZipFile::ZipFile(const std::string& zipFile, const std::string& filter):
m_data(new ZipFilePrivate)
{
	m_data->zipFile = unzOpen(zipFile.c_str());
	if (m_data->zipFile)
	{
		setFilter(filter);
	}
}

ZipFile::~ZipFile()
{
	if (m_data && m_data->zipFile)
	{
		unzClose(m_data->zipFile);
	}
	delete m_data;
	m_data = nullptr;
}

bool ZipFile::setFilter(const std::string& filterStr)
{
	bool ret = false;
	BLOCK_START
	{
		BREAK_IF(!m_data);
		BREAK_IF(!m_data->zipFile);

		std::string filter(filterStr);

		// clear existing file list
		m_data->fileList.clear();
		m_data->folderList.clear();

		// UNZ_MAXFILENAMEINZIP + 1 - it is done so in unzLocateFile
		char szCurrentFileName[UNZ_MAXFILENAMEINZIP + 1];
		unz_file_info64 fileInfo;

		// go through all files and store position information about the required files
		int err = unzGoToFirstFile64(m_data->zipFile, &fileInfo,
			szCurrentFileName, sizeof(szCurrentFileName) - 1);
		while (err == UNZ_OK)
		{
			unz_file_pos posInfo;
			int posErr = unzGetFilePos(m_data->zipFile, &posInfo);
			if (posErr == UNZ_OK)
			{
				std::string currentFileName(szCurrentFileName);
				// cache info about filtered files only (like 'assets/')
				if (filter.empty() || currentFileName.substr(0, filter.length()) == filter)
				{
					ZipEntryInfo entry;
					entry.pos = posInfo;
					entry.uncompressed_size = (uLong)fileInfo.uncompressed_size;
					m_data->fileList[currentFileName] = entry;
					size_t pos = currentFileName.rfind('/');
					while (pos != std::string::npos)
					{
						currentFileName = currentFileName.substr(0, pos);
						m_data->folderList.insert(currentFileName);
						pos = currentFileName.rfind('/');
					}
				}
			}
			// next file - also get the information about it
			err = unzGoToNextFile64(m_data->zipFile, &fileInfo,
				szCurrentFileName, sizeof(szCurrentFileName) - 1);
		}
		ret = true;
	}
	BLOCK_END

	return ret;
}

std::list<std::string> ZipFile::getDirEntries(const std::string& path, bool isFolder)
{
	std::string searchName(path == "." ? std::string() : path);
	char last = searchName[searchName.length() - 1];
	if (last == '/' || last == '\\')
	{
		searchName.erase(--searchName.end());
	}
	size_t pos = 0;
	while ((pos = searchName.find("\\", pos)) != std::string::npos)
	{
		searchName[pos] = '/';
	}
	std::list<std::string> results;
	if (isFolder)
	{
		for (const auto& folder : m_data->folderList)
		{
			if (searchName == folder.substr(0, searchName.length()))
			{
				size_t pos = folder.find('/', searchName.length() + 1);
				if (pos == std::string::npos)
				{
					if (searchName.length() < folder.length())
					{
						string name = folder.substr(searchName.length() + 1);
						if (name != "." && name != "..")
						{
							results.push_back(name);
						}
					}
				}
			}
		}
	}
	else
	{
		for (const auto& it : m_data->fileList)
		{
			const std::string& file = it.first;
			if (searchName == file.substr(0, searchName.length()))
			{
				size_t pos = file.find('/', searchName.length() + 1);
				if (pos == std::string::npos)
				{
					if (searchName.length() < file.length())
					{
						results.push_back(file.substr(searchName.length() + 1));
					}
				}
			}
		}
	}
	return results;
}

std::list<std::string> ZipFile::getAllFiles(const std::string& path)
{
	std::string searchName(path == "." ? std::string() : path);
	char last = searchName[searchName.length() - 1];
	if (last == '/' || last == '\\')
	{
		searchName.erase(--searchName.end());
	}
	size_t pos = 0;
	while ((pos = searchName.find("\\", pos)) != std::string::npos)
	{
		searchName[pos] = '/';
	}
	std::list<std::string> results;
	for (const auto& it : m_data->fileList)
	{
		const std::string& file = it.first;
		if (searchName == file.substr(0, searchName.length()))
		{
			if (searchName.length() < file.length())
			{
				results.push_back(file.substr(searchName.length() + 1));
			}
		}
	}
	return results;
}

bool ZipFile::fileExists(const std::string& fileName) const
{
	bool ret = false;
	BLOCK_START
	{
		BREAK_IF(!m_data);
		std::string file(fileName);
		ret = m_data->fileList.find(file) != m_data->fileList.end() || m_data->folderList.find(file) != m_data->folderList.end();
	}
	BLOCK_END
	return ret;
}

bool ZipFile::isFolder(const std::string& pathStr) const
{
	std::string path(pathStr);
	return m_data->folderList.find(path) != m_data->folderList.end();
}

uint8_t* ZipFile::getFileData(const std::string& fileName, unsigned long* pSize)
{
	uint8_t* pBuffer = nullptr;
	if (pSize)
	{
		*pSize = 0;
	}

	BLOCK_START
	{
		BREAK_IF(!m_data->zipFile);
		BREAK_IF(fileName.empty());

		std::string file(fileName);

		auto it = m_data->fileList.find(file);
		BREAK_IF(it == m_data->fileList.end());

		ZipEntryInfo fileInfo = it->second;

		int nRet = unzGoToFilePos(m_data->zipFile, &fileInfo.pos);
		BREAK_IF(UNZ_OK != nRet);
		nRet = unzOpenCurrentFile(m_data->zipFile);
		BREAK_IF(UNZ_OK != nRet);

		pBuffer = new uint8_t[fileInfo.uncompressed_size];
		int nSize = unzReadCurrentFile(m_data->zipFile, pBuffer, (unsigned int)fileInfo.uncompressed_size);
		AssertUnless(nSize == 0 || nSize == (int)fileInfo.uncompressed_size, "FileUtils: the file size is wrong.");

		if (pSize)
		{
			*pSize = fileInfo.uncompressed_size;
		}
		unzCloseCurrentFile(m_data->zipFile);
	}
	BLOCK_END

	return pBuffer;
}

void ZipFile::getFileDataByChunks(const std::string& fileName, const std::function<void(unsigned char*, int)>& handler)
{
	BLOCK_START
	{
		BREAK_IF(!m_data->zipFile);
		BREAK_IF(fileName.empty());

		std::string file(fileName);

		auto it = m_data->fileList.find(file);
		BREAK_IF(it == m_data->fileList.end());

		ZipEntryInfo fileInfo = it->second;

		int nRet = unzGoToFilePos(m_data->zipFile, &fileInfo.pos);
		BREAK_IF(UNZ_OK != nRet);

		nRet = unzOpenCurrentFile(m_data->zipFile);
		BREAK_IF(UNZ_OK != nRet);

		Uint8 buf[DORA_COPY_BUFFER_SIZE];
		int nSize = 0, total = 0;
		do
		{
			nSize = unzReadCurrentFile(m_data->zipFile, buf, DORA_COPY_BUFFER_SIZE);
			AssertIf(nSize < 0, "FileUtils: read current file error.");
			if (nSize > 0)
			{
				handler(buf, nSize);
			}
			total += nSize;
		}
		while (nSize != 0);
		AssertUnless(total == 0 || total == (int)fileInfo.uncompressed_size, "FileUtils: the file size is wrong.");
		unzCloseCurrentFile(m_data->zipFile);
	}
	BLOCK_END
}
