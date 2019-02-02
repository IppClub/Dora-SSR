/* Copyright (c) 2019 Jin Li, http://www.luvfight.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#pragma once

#include <string>
using std::string;
#include <vector>
using std::vector;
#include <functional>
using std::function;
#include <unordered_map>
using std::unordered_map;
#include <stack>
using std::stack;
#include <queue>
using std::queue;
#include <unordered_set>
using std::unordered_set;
#include <list>
using std::list;
#include <memory>
#include <tuple>
using std::tuple;
#include <algorithm>
#include <cctype>
#include <cmath>
#include "bgfx/platform.h"
#include "bgfx/bgfx.h"
#include "bgfx/embedded_shader.h"
#include "bx/thread.h"
#include "bx/semaphore.h"
#include "bx/math.h"
#include "SDL_syswm.h"
#include "SDL.h"
#include "PlayRho/PlayRho.hpp"
#include "Other/AcfDelegate.h"
using Acf::Delegate;
#include "silly/Slice.h"
using namespace silly::slice;
#include "fmt/format.h"

#include "Const/Config.h"
#include "Common/Debug.h"
#include "Common/Utils.h"
using namespace Dorothy::Switch::Literals;
#include "Common/Singleton.h"
#include "Common/MemoryPool.h"
#include "Common/Own.h"
#include "Basic/Object.h"
#include "Common/Ref.h"
#include "Common/WRef.h"
