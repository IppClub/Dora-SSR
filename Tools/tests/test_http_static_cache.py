#!/usr/bin/env python3
"""Exercise the production static cache, version policy and gzip compressor."""
from pathlib import Path
import os, subprocess, tempfile
root=Path(__file__).resolve().parents[2]
source=(root/'Source/Http/HttpServer.cpp').read_text()
gzip=source[source.index('static std::optional<std::string> gzip_compress'):source.index('using StaticContent =')]
version=source[source.index('static std::optional<std::string> static_file_version'):source.index('static StaticContent loadStaticContent')]
code=r'''
#include "Source/Http/HttpStaticCache.h"
#include <filesystem>
#include <fstream>
#include <cassert>
#include <iostream>
#include <array>
#include <limits>
#include <algorithm>
#include <zlib.h>
namespace fs=std::filesystem;
template<class T,class U>T s_cast(U value){return static_cast<T>(value);}
template<class T,class U>T r_cast(U value){return reinterpret_cast<T>(value);}
struct Content {std::string root;std::string getWritablePath(){return root;}} SharedContent;
GZIP
VERSION
int main(int argc,char** argv){
 using Dora::HttpPolicy::StaticCache;
 auto dir=fs::path(argv[1]);auto work=dir/"work";auto asset=dir/"assets";fs::create_directories(work);fs::create_directories(asset);
 SharedContent.root=work.string();auto write=[](auto path,auto value){std::ofstream(path)<<value;};
 write(work/"live.txt","before");write(asset/"a.txt",std::string(4096,'a'));
 assert(!static_file_version((work/"live.txt").string()));assert(static_file_version((asset/"a.txt").string()));
 fs::create_symlink(work/"live.txt",asset/"link.txt");assert(!static_file_version((asset/"link.txt").string()));
 fs::create_directories(dir/"work-other");write(dir/"work-other/file","ok");assert(static_file_version((dir/"work-other/file").string()));
 assert(!static_file_version((asset/"missing").string()));
 write(asset/"b.txt",std::string(4096,'b'));fs::last_write_time(asset/"b.txt",fs::last_write_time(asset/"a.txt"));
 fs::create_symlink(asset/"a.txt",asset/"alias.txt");auto first=static_file_version((asset/"alias.txt").string());
 fs::remove(asset/"alias.txt");fs::create_symlink(asset/"b.txt",asset/"alias.txt");assert(first!=static_file_version((asset/"alias.txt").string()));
 int reads=0,compressed=0;StaticCache cache;
 auto load=[&](const fs::path& file,bool gzip){return cache.load(file.string(),static_file_version(file.string()),gzip,[&]{reads++;std::ifstream in(file);return std::string(std::istreambuf_iterator<char>(in),{});},[&](auto& raw){compressed++;return gzip_compress(raw);});};
 auto a=load(asset/"a.txt",false);auto g=load(asset/"a.txt",true);auto again=load(asset/"a.txt",true);
 assert(reads==1&&compressed==1&&!a.gzipEncoded&&g.gzipEncoded&&again.data==g.data);
 z_stream z{};assert(inflateInit2(&z,31)==Z_OK);std::string decoded(4096,' ');
 z.next_in=reinterpret_cast<Bytef*>(g.data.data());z.avail_in=g.data.size();z.next_out=reinterpret_cast<Bytef*>(decoded.data());z.avail_out=decoded.size();assert(inflate(&z,Z_FINISH)==Z_STREAM_END);inflateEnd(&z);assert(decoded==a.data);
 auto oldTime=fs::last_write_time(asset/"a.txt");write(asset/"a.txt",std::string(4096,'b'));fs::last_write_time(asset/"a.txt",oldTime+std::chrono::seconds(1));
 auto changed=load(asset/"a.txt",true);assert(reads==2&&compressed==2&&changed.data!=g.data);
 assert(load(work/"live.txt",false).data=="before");write(work/"live.txt","after");assert(load(work/"live.txt",false).data=="after");
 StaticCache small(64,2);auto compact=[](auto&)->std::optional<std::string>{return std::string(16,'g');};
 for(int i=0;i<8;i++){small.load(std::to_string(i),"v",false,[]{return std::string(32,'x');},compact);assert(small.size()<=64&&small.count()<=2);}
 small.load("7","v",true,[]{assert(false);return std::string();},compact);assert(small.size()<=64&&small.count()<=2);
 StaticCache metadata(4096,2);
 for(int i=0;i<20;i++){metadata.load(std::to_string(i),"v",false,[]{return std::string("x");},compact);assert(metadata.count()<=2);}
 auto count=small.count();small.load("huge","v",true,[]{return std::string(65,'x');},compact);assert(small.count()==count&&small.size()<=64);
 for(int i=0;i<1000;i++)small.load("missing"+std::to_string(i),"v",false,[]{return std::string();},compact);
 assert(small.count()==count);
 std::cout<<"PASS: static cache hits, gzip identity, same-size invalidation, writable/symlink bypass, payload and entry bounds, oversized/missing assets"<<std::endl;
}
'''.replace('GZIP',gzip).replace('VERSION',version)
with tempfile.TemporaryDirectory(prefix='dora-static-cache-') as tmp:
    tmp=Path(tmp);(tmp/'test.cpp').write_text(code)
    subprocess.run([os.environ.get('CXX','c++'),'-std=c++17','-fsanitize=address,undefined','-I',str(root),str(tmp/'test.cpp'),'-lz','-o',str(tmp/'test')],check=True)
    subprocess.run([str(tmp/'test'),str(tmp)],check=True)
