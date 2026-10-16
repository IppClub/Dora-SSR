#!/usr/bin/env python3
"""Exercise production gzip-only loading without a cross-request resource cache."""
from pathlib import Path
import os, subprocess, tempfile
root=Path(__file__).resolve().parents[2]
source=(root/'Source/Http/HttpServer.cpp').read_text()
gzip=source[source.index('static std::optional<std::string> gzip_compress'):source.index('using StaticContent =')]
loader=source[source.index('static StaticContent loadStaticContent'):source.index('constexpr size_t DynamicResponseCompressionThreshold')]
code=r'''
#include "Source/Http/HttpStaticContent.h"
#include <filesystem>
#include <fstream>
#include <cassert>
#include <iostream>
#include <array>
#include <iterator>
namespace fs=std::filesystem;
namespace HttpPolicy=Dora::HttpPolicy;
template<class T,class U>T s_cast(U value){return static_cast<T>(value);}
template<class T,class U>T r_cast(U value){return reinterpret_cast<T>(value);}
struct Content {
 std::string search; int reads=0;
 std::string getFullPath(const std::string& file){return fs::path(file).is_absolute()?file:(fs::path(search)/file).string();}
 bool exist(const std::string& file){return fs::is_regular_file(getFullPath(file));}
 std::string loadUnsafe(const std::string& file){reads++;std::ifstream in(getFullPath(file),std::ios::binary);return std::string(std::istreambuf_iterator<char>(in),{});}
} SharedContent;
int compressions=0;
GZIP
using StaticContent=Dora::HttpPolicy::StaticContent;
LOADER
int main(int argc,char** argv){
 auto dir=fs::path(argv[1]);SharedContent.search=dir.string();
 auto write=[&](auto name,auto value){std::ofstream(dir/name,std::ios::binary)<<value;};
 auto raw=std::string(8192,'x'), packed=*gzip_compress(raw);compressions=0;
 write("app.js.gz",packed);
 auto g=loadStaticContent("app.js",true);assert(g.gzipEncoded&&g.data==packed&&compressions==0&&SharedContent.reads==1);
 auto plain=loadStaticContent("app.js",false);assert(!plain.gzipEncoded&&plain.data==raw&&compressions==0);
 assert(!fs::exists(dir/"app.js"));
 // Requests never retain previous payloads, including same-length edits.
 auto replacement=std::string(raw.size(),'y');write("app.js.gz",*gzip_compress(replacement));compressions=0;
 assert(loadStaticContent("app.js",false).data==replacement);
 write("live.js",raw);write("live.js.gz",packed);
 assert(loadStaticContent("live.js",true).data==packed&&compressions==0);
 write("live.js",replacement);
 auto edited=loadStaticContent("live.js",true);assert(edited.gzipEncoded&&compressions==1);
 assert(Dora::HttpPolicy::decodePrecompressedGzip(edited.data)==replacement);
 assert(loadStaticContent("live.js",false).data==replacement);
 // Original path resolution keeps paired files in the same search-path owner.
 fs::create_directories(dir/"project");write("project/custom.js",raw);write("custom.js.gz",packed);compressions=0;
 assert(loadStaticContent((dir/"project/custom.js").string(),true).gzipEncoded&&compressions==1);
 assert(!Dora::HttpPolicy::decodePrecompressedGzip(packed,raw.size()-1));
 assert(Dora::HttpPolicy::decodePrecompressedGzip(packed,raw.size())==raw);
 assert(!Dora::HttpPolicy::decodePrecompressedGzip(packed+"trailing"));
 auto broken=packed;broken[broken.size()-8]^=1;
 assert(!Dora::HttpPolicy::decodePrecompressedGzip(broken));
 assert(!Dora::HttpPolicy::matchesPrecompressedGzip(raw,broken));
 assert(!Dora::HttpPolicy::decodePrecompressedGzip(packed.substr(0,packed.size()-1)));
 write("broken.js.gz","not gzip");assert(loadStaticContent("broken.js",false).data.empty());
 assert(loadStaticContent("missing.js",false).data.empty());
 std::cout<<"PASS: gzip-only direct delivery, identity decoding, no retained payloads, live edits, stale companions, path ownership, CRC/truncation/trailing-data checks and decompression limit"<<std::endl;
}
'''.replace('GZIP',gzip.replace('z_stream stream{};', 'compressions++; z_stream stream{};',1)).replace('LOADER',loader)
with tempfile.TemporaryDirectory(prefix='dora-precompressed-') as tmp:
    tmp=Path(tmp);(tmp/'test.cpp').write_text(code)
    subprocess.run([os.environ.get('CXX','c++'),'-std=c++17','-fsanitize=address,undefined','-I',str(root),str(tmp/'test.cpp'),'-lz','-o',str(tmp/'test')],check=True)
    subprocess.run([str(tmp/'test'),str(tmp)],check=True)
