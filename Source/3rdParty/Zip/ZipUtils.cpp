/****************************************************************************
Copyright (c) 2010 cocos2d-x.org, modified by Li Jin, 2021

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
#include "Basic/Content.h"
using namespace Dorothy;
#include "ZipUtils.h"
#include "miniz.h"

class ZipFilePrivate
{
public:
	mz_zip_archive archive;
	std::unordered_map<std::string, uint64_t> fileList;
	std::unordered_set<std::string> folderList;
};

ZipFile::ZipFile(const std::string& zipFile, const std::string& filter)
{
	auto fullPath = SharedContent.getFullPath(zipFile);
	_file = new ZipFilePrivate();
	if (mz_zip_reader_init_file(&_file->archive, fullPath.c_str(), 0))
	{
		setFilter(filter);
	}
	else
	{
		auto err = mz_zip_get_error_string(mz_zip_get_last_error(&_file->archive));
		mz_zip_reader_end(&_file->archive);
		delete _file;
		_file = nullptr;
		Error("fail to open zip file \"{}\": {}.", zipFile, err);
	}
}

ZipFile::ZipFile(std::pair<OwnArray<uint8_t>,size_t>&& data, const std::string& filter):
_data(std::move(data))
{
	_file = new ZipFilePrivate();
	if (mz_zip_reader_init_mem(&_file->archive, _data.first.get(), _data.second, 0))
	{
		setFilter(filter);
	}
	else
	{
		auto err = mz_zip_get_error_string(mz_zip_get_last_error(&_file->archive));
		mz_zip_reader_end(&_file->archive);
		delete _file;
		_file = nullptr;
		Error("fail to open zip from data: {}.", err);
	}
}

ZipFile::~ZipFile()
{
	if (_file)
	{
		mz_zip_reader_end(&_file->archive);
		delete _file;
		_file = nullptr;
	}
}

bool ZipFile::setFilter(const std::string& filter)
{
	if (_file)
	{
		mz_zip_archive* archive = &_file->archive;

		// clear existing file list
		_file->fileList.clear();
		_file->folderList.clear();

		// Get and print information about each file in the archive.
		for (int i = 0; i < mz_zip_reader_get_num_files(archive); i++)
		{
			mz_zip_archive_file_stat file_stat;
			if (!mz_zip_reader_file_stat(archive, i, &file_stat))
			{
				auto err = mz_zip_get_error_string(mz_zip_get_last_error(archive));
				Error("fail to read a zip entry: {}.", err);
				return false;
			}
			Slice filename(file_stat.m_filename);
			if (!mz_zip_reader_is_file_a_directory(archive, i) &&
				(filter.empty() || filename.left(filter.length()) == filter))
			{
				std::string currentFileName = filename.toString();
				_file->fileList[currentFileName] = file_stat.m_uncomp_size;
				size_t pos = currentFileName.rfind('/');
				while (pos != std::string::npos)
				{
					currentFileName = currentFileName.substr(0, pos);
					_file->folderList.insert(currentFileName);
					pos = currentFileName.rfind('/');
				}
			}
		}
	}
	return true;
}

std::list<std::string> ZipFile::getDirEntries(const std::string& path, bool isFolder)
{
	if (!_file) return {};
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
		for (const auto& folder : _file->folderList)
		{
			auto left = Slice(folder).left(searchName.length());
			if (left == searchName)
			{
				size_t pos = folder.find('/', searchName.length() + 1);
				if (pos == std::string::npos)
				{
					if (searchName.length() < folder.length())
					{
						std::string name = folder.substr(searchName.length() + 1);
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
		for (const auto& it : _file->fileList)
		{
			const std::string& file = it.first;
			auto left = Slice(file).left(searchName.length());
			if (left == searchName)
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
	if (!_file) return {};
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
	for (const auto& it : _file->fileList)
	{
		const std::string& file = it.first;
		auto left = Slice(file).left(searchName.length());
		if (left == searchName)
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
		BREAK_IF(!_file);
		ret = _file->fileList.find(fileName) != _file->fileList.end() || _file->folderList.find(fileName) != _file->folderList.end();
	}
	BLOCK_END
	return ret;
}

bool ZipFile::isFolder(const std::string& path) const
{
	return _file->folderList.find(path) != _file->folderList.end();
}

bool ZipFile::isOK() const
{
	return _file != nullptr;
}

uint8_t* ZipFile::getFileDataUnsafe(const std::string& filename, size_t* size)
{
	uint8_t* buffer = nullptr;
	if (size) *size = 0;
	BLOCK_START
	{
		BREAK_IF(!_file);
		BREAK_IF(filename.empty());
		auto it = _file->fileList.find(filename);
		BREAK_IF(it == _file->fileList.end());
		auto archive = &_file->archive;
		size_t bufSize = it->second;
		if (size) *size = bufSize;
		buffer = new uint8_t[bufSize];
		if (!mz_zip_reader_extract_file_to_mem(archive, filename.c_str(), buffer, bufSize, 0))
		{
			auto err = mz_zip_get_error_string(mz_zip_get_last_error(archive));
			Error("fail to extract file \"{}\" from a zip: {}.", filename, err);
		}
	}
	BLOCK_END
	return buffer;
}

std::pair<Dorothy::OwnArray<uint8_t>,size_t> ZipFile::getFileData(const std::string& filename)
{
	size_t size = 0;
	uint8_t* buf = getFileDataUnsafe(filename, &size);
	return {MakeOwnArray(buf), size};
}

void ZipFile::getFileDataByChunks(const std::string& fileName, const std::function<void(unsigned char*, int)>& handler)
{
	BLOCK_START
	{
		BREAK_IF(!_file);
		BREAK_IF(fileName.empty());
		auto archive = &_file->archive;
		auto it = _file->fileList.find(fileName.c_str());
		BREAK_IF(it == _file->fileList.end());
		auto zipIter = mz_zip_reader_extract_file_iter_new(archive, fileName.c_str(), 0);
		uint8_t buf[DORA_COPY_BUFFER_SIZE];
		int nSize = 0, total = 0;
		do
		{
			nSize = mz_zip_reader_extract_iter_read(zipIter, buf, DORA_COPY_BUFFER_SIZE);
			if (nSize > 0)
			{
				handler(buf, nSize);
			}
			total += nSize;
		}
		while (nSize != 0);
		mz_zip_reader_extract_iter_free(zipIter);
		AssertUnless(total == 0 || total == (int)it->second, "ZipUtils: the file size is wrong.");
	}
	BLOCK_END
}
