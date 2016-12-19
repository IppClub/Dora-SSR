#import "Const/oHeader.h"
#import "Basic/oContent.h"
#import <Foundation/Foundation.h>

NS_DOROTHY_BEGIN

bool oContent::isFileExist(oSlice filePath)
{
	if (filePath[0] != '/')
	{
		std::string path = filePath;
		std::string file;
		size_t pos = path.find_last_of("/");
		if (pos != std::string::npos)
		{
			file = path.substr(pos+1);
			path = path.substr(0, pos+1);
			NSString* fullpath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:file.c_str()]
				ofType:nil
				inDirectory:[NSString stringWithUTF8String:path.c_str()]
			];
			if (fullpath != nil)
			{
				return true;
			}
		}
	}
	else
	{
		// Search path is an absolute path.
		NSFileManager* fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:[NSString stringWithUTF8String:filePath.c_str()]])
		{
			return true;
		}
	}
	return false;
}

string oContent::getFullPathForDirectoryAndFilename(oSlice directory, oSlice filename)
{
	if (directory[0] != '/')
	{
		NSString* fullpath = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:filename.c_str()]
			ofType:nil
			inDirectory:[NSString stringWithUTF8String:directory.c_str()]
		];
		if (fullpath != nil)
		{
			return [fullpath UTF8String];
		}
	}
	else
	{
		std::string fullPath = directory + filename;
		// Search path is an absolute path.
		NSFileManager* fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:[NSString stringWithUTF8String:fullPath.c_str()]])
		{
			return fullPath;
		}
	}
	return "";
}

bool oContent::isAbsolutePath(oSlice strPath)
{
	NSString* path = [NSString stringWithUTF8String:strPath.c_str()];
	return [path isAbsolutePath] ? true : false;
}

NS_DOROTHY_END
