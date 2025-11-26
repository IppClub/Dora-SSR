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
using namespace Dora;

#include "ZipUtils.h"
#include "miniz.h"

struct ZipEntry {
	std::string name;
	uint64_t size;
};

class ZipFilePrivate {
public:
	mz_zip_archive archive;
	std::unordered_map<std::string, ZipEntry> fileList;
	std::unordered_map<std::string, std::string> folderList;
};

ZipFile::ZipFile(const std::string& zipFile, const std::string& filter) {
	_file = New<ZipFilePrivate>();
	mz_zip_zero_struct(&_file->archive);
	if (mz_zip_reader_init_file(&_file->archive, zipFile.c_str(), 0)) {
		setFilter(filter);
	} else {
		auto err = mz_zip_get_error_string(mz_zip_get_last_error(&_file->archive));
		mz_zip_reader_end(&_file->archive);
		_file = nullptr;
		Error("failed to open zip file \"{}\": {}.", zipFile, err);
	}
}

ZipFile::ZipFile(std::pair<OwnArray<uint8_t>, size_t>&& data, const std::string& filter)
	: _data(std::move(data)) {
	if (!_data.first) {
		Error("invalid zip data.");
		return;
	}
	_file = New<ZipFilePrivate>();
	mz_zip_zero_struct(&_file->archive);
	if (mz_zip_reader_init_mem(&_file->archive, _data.first.get(), _data.second, 0)) {
		setFilter(filter);
	} else {
		auto err = mz_zip_get_error_string(mz_zip_get_last_error(&_file->archive));
		mz_zip_reader_end(&_file->archive);
		_file = nullptr;
		Error("failed to open zip from data: {}.", err);
	}
}

ZipFile::~ZipFile() {
	if (_file) {
		mz_zip_reader_end(&_file->archive);
		_file = nullptr;
	}
}

bool ZipFile::setFilter(const std::string& filter) {
	if (_file) {
		mz_zip_archive* archive = &_file->archive;

		// clear existing file list
		_file->fileList.clear();
		_file->folderList.clear();

		// Get and print information about each file in the archive.
		for (int i = 0; i < s_cast<int>(mz_zip_reader_get_num_files(archive)); i++) {
			mz_zip_archive_file_stat file_stat;
			if (!mz_zip_reader_file_stat(archive, i, &file_stat)) {
				auto err = mz_zip_get_error_string(mz_zip_get_last_error(archive));
				Error("failed to read a zip entry: {}.", err);
				return false;
			}
			Slice filename(file_stat.m_filename);
			if (!mz_zip_reader_is_file_a_directory(archive, i) && (filter.empty() || filename.left(filter.length()) == filter)) {
				std::string currentFileName = filename.toString();
				_file->fileList[Slice(currentFileName).toLower()] = {
					currentFileName,
					file_stat.m_uncomp_size};
				size_t pos = currentFileName.rfind('/');
				while (pos != std::string::npos) {
					currentFileName = currentFileName.substr(0, pos);
					_file->folderList[Slice(currentFileName).toLower()] = currentFileName;
					pos = currentFileName.rfind('/');
				}
			}
		}
	}
	return true;
}

static std::string getSearchName(const std::string& filename) {
	std::string cleaned = Slice(filename).toLower();
	if (!cleaned.empty()) {
		size_t pos = 0;
		while ((pos = cleaned.find("\\", pos)) != std::string::npos) {
			cleaned[pos] = '/';
		}
		while (!cleaned.empty() && cleaned.back() == '/') {
			cleaned.erase(--cleaned.end());
		}
		if (cleaned == "."sv) cleaned.clear();
	}
	return cleaned;
}

std::list<std::string> ZipFile::getDirEntries(const std::string& path, bool isFolder) {
	if (!_file) return {};
	std::string searchName = getSearchName(path);
	std::list<std::string> results;
	if (isFolder) {
		for (const auto& folder : _file->folderList) {
			auto left = Slice(folder.first).left(searchName.length());
			if (left == searchName) {
				size_t searchStart = 0;
				if (!searchName.empty()) searchStart = searchName.length() + 1;
				size_t pos = folder.first.find('/', searchStart);
				if (pos == std::string::npos) {
					if (searchName.length() < folder.first.length()) {
						std::string name = folder.second.substr(searchStart);
						if (name != "." && name != "..") {
							results.push_back(name);
						}
					}
				}
			}
		}
	} else {
		for (const auto& file : _file->fileList) {
			auto left = Slice(file.first).left(searchName.length());
			if (left == searchName) {
				size_t searchStart = 0;
				if (!searchName.empty()) searchStart = searchName.length() + 1;
				size_t pos = file.first.find('/', searchStart);
				if (pos == std::string::npos) {
					if (searchName.length() < file.first.length()) {
						results.push_back(file.second.name.substr(searchStart));
					}
				}
			}
		}
	}
	return results;
}

std::list<std::string> ZipFile::getAllFiles(const std::string& path) {
	if (!_file) return {};
	std::string searchName = getSearchName(path);
	std::list<std::string> results;
	for (const auto& file : _file->fileList) {
		auto left = Slice(file.first).left(searchName.length());
		if (left == searchName) {
			if (searchName.length() < file.first.length()) {
				size_t searchStart = 0;
				if (!searchName.empty()) searchStart = searchName.length() + 1;
				results.push_back(file.second.name.substr(searchStart));
			}
		}
	}
	return results;
}

bool ZipFile::fileExists(const std::string& fileName) const {
	if (!_file) return false;
	std::string searchName = getSearchName(fileName);
	return _file->fileList.find(searchName) != _file->fileList.end() || _file->folderList.find(searchName) != _file->folderList.end();
}

bool ZipFile::isFolder(const std::string& path) const {
	if (!_file) return false;
	std::string searchName = getSearchName(path);
	return _file->folderList.find(searchName) != _file->folderList.end();
}

bool ZipFile::isOK() const {
	return _file != nullptr;
}

uint8_t* ZipFile::getFileDataUnsafe(const std::string& filename, size_t* size) {
	uint8_t* buffer = nullptr;
	if (size) *size = 0;
	BLOCK_START {
		BREAK_IF(!_file);
		BREAK_IF(filename.empty());
		std::string searchName = getSearchName(filename);
		auto it = _file->fileList.find(searchName);
		BREAK_IF(it == _file->fileList.end());
		auto archive = &_file->archive;
		size_t bufSize = s_cast<size_t>(it->second.size);
		if (size) *size = bufSize;
		buffer = new uint8_t[bufSize];
		if (!mz_zip_reader_extract_file_to_mem(archive, it->second.name.c_str(), buffer, bufSize, 0)) {
			auto err = mz_zip_get_error_string(mz_zip_get_last_error(archive));
			Error("failed to extract file \"{}\" from zip: {}.", it->second.name, err);
		}
	}
	BLOCK_END
	return buffer;
}

std::string ZipFile::getFileDataAsString(const std::string& filename) {
	std::string buffer;
	BLOCK_START {
		BREAK_IF(!_file);
		BREAK_IF(filename.empty());
		std::string searchName = getSearchName(filename);
		auto it = _file->fileList.find(searchName);
		BREAK_IF(it == _file->fileList.end());
		auto archive = &_file->archive;
		size_t bufSize = s_cast<size_t>(it->second.size);
		buffer.resize(bufSize);
		if (!mz_zip_reader_extract_file_to_mem(archive, it->second.name.c_str(), buffer.data(), bufSize, 0)) {
			auto err = mz_zip_get_error_string(mz_zip_get_last_error(archive));
			Error("failed to extract file \"{}\" from zip: {}.", it->second.name, err);
		}
	}
	BLOCK_END
	return buffer;
}

std::pair<Dora::OwnArray<uint8_t>, size_t> ZipFile::getFileData(const std::string& filename) {
	size_t size = 0;
	uint8_t* buf = getFileDataUnsafe(filename, &size);
	return {MakeOwnArray(buf), size};
}

bool ZipFile::getFileDataByChunks(const std::string& fileName, const std::function<bool(unsigned char*, int)>& handler) {
	BLOCK_START {
		BREAK_IF(!_file);
		BREAK_IF(fileName.empty());
		auto archive = &_file->archive;
		std::string searchName = getSearchName(fileName);
		auto it = _file->fileList.find(searchName);
		BREAK_IF(it == _file->fileList.end());
		auto zipIter = mz_zip_reader_extract_file_iter_new(archive, it->second.name.c_str(), 0);
		uint8_t buf[DORA_COPY_BUFFER_SIZE];
		size_t nSize = 0, total = 0;
		do {
			nSize = mz_zip_reader_extract_iter_read(zipIter, buf, DORA_COPY_BUFFER_SIZE);
			if (nSize > 0) {
				if (handler(buf, nSize)) {
					return false;
				}
			}
			total += nSize;
		} while (nSize != 0);
		mz_zip_reader_extract_iter_free(zipIter);
		if (total == 0 || total == (int)it->second.size) {
			return true;
		} else {
			Error("ZipUtils: the file size is wrong: \"{}\".", fileName);
			return false;
		}
	}
	BLOCK_END
	return false;
}
