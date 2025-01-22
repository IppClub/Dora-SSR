/* Copyright (c) 2016-2025 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "Const/Header.h"

#import "Basic/Content.h"

#import <Foundation/Foundation.h>

NS_DORA_BEGIN

bool Content::isFileExist(String filePath) {
	if (filePath[0] != '/') {
		std::string path = filePath.toString();
		std::string file;
		size_t pos = path.find_last_of("/");
		if (pos != std::string::npos) {
			file = path.substr(pos + 1);
			path = path.substr(0, pos + 1);
			NSString* fullPath = [[NSBundle mainBundle]
				pathForResource:[NSString stringWithUTF8String:file.c_str()]
						 ofType:nil
					inDirectory:[NSString stringWithUTF8String:path.c_str()]];
			if (fullPath != nil) {
				return true;
			}
		}
	} else {
		// Search path is an absolute path.
		NSFileManager* fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:[NSString stringWithUTF8String:filePath.c_str()]]) {
			return true;
		}
	}
	return false;
}

std::string Content::getFullPathForDirectoryAndFilename(String directory, String filename) {
	if (directory[0] != '/') {
		NSString* fullPath = [[NSBundle mainBundle]
			pathForResource:[NSString stringWithUTF8String:filename.c_str()]
					 ofType:nil
				inDirectory:[NSString stringWithUTF8String:directory.c_str()]];
		if (fullPath != nil) {
			return [fullPath UTF8String];
		}
	} else {
		std::string fullPath = directory.toString() + filename.toString();
		// Search path is an absolute path.
		NSFileManager* fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:[NSString stringWithUTF8String:fullPath.c_str()]]) {
			return fullPath;
		}
	}
	return Slice::Empty;
}

bool Content::isAbsolutePath(String strPath) {
	NSString* path = [NSString stringWithUTF8String:strPath.c_str()];
	return [path isAbsolutePath] ? true : false;
}

NS_DORA_END
