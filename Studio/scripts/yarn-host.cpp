#include "yarnflow/yarn_compiler.h"
#include <string>
#include <string_view>

static yarnflow::CompileInfo::Error last_error;
static bool has_error=false;

extern "C" {
int yarn_check_file(const char* data,unsigned length){
  has_error=false;
  const auto result=yarnflow::compileFile(std::string_view(data,length));
  if(result.error){last_error=*result.error;has_error=true;return 1;}
  return 0;
}
const char* yarn_error_message(){return has_error?last_error.msg.c_str():"";}
const char* yarn_error_node(){return has_error?last_error.nodeName.c_str():"";}
int yarn_error_line(){return has_error?last_error.line:0;}
int yarn_error_column(){return has_error?last_error.col:0;}
}
