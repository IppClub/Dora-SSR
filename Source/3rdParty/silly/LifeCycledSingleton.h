/**
 * Copyright (C) 2017, IppClub. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
#pragma once

/*
 * A simple yet useful singleton tool for single threaded program (e.g. game). 
 * Features: Create singleton instances the first time they are used at runtime,
 * in random orders. Then the created instances will be destroyed with predefined
 * life times at the end of the program, the instance with the lowest life time
 * is to be destroyed first.
 *
 * Usage:
 *   #include "LifeCycleSingleton.h"
 *   using silly::Singleton;
 *
 *   // example classes to be singletons
 *   class Logger { ... };
 *   class Graphic { ... };
 *   class TextureCache { ... };
 *
 *   // make them singledogs
 *   #define SharedLogger Singleton<Logger, 998>::shared()
 *   #define SharedGraphic Singleton<Graphic, 2>::shared()
 *   #define SharedTextureCache Singleton<TextureCache, 1>::shared()
 *
 *   // use these singleton macros anywhere
 *   ...
 *   SharedLogger.log("some message");
 *   SharedTextureCache.load("someImage.png");
 *   SharedGraphic.render("someImage.png");
 *   ...
 *   // when the program ends they are destroyed in orders of: TextureCache(1), Graphic(2), Logger(998)
 */

namespace silly {
  class Life {

   public:

    Life(int time);
    virtual ~Life() { }
    inline int getTime() const { return time_; }

  private:
    int time_;
  };

  template <class T, int LifeTime = 0>
  class Singleton : public T, public Life {

   public:

    Singleton() : Life(LifeTime) { }
    static T& shared() {
      static auto* instance_ = new Singleton<T, LifeTime>();
      return *instance_;
    }

  private:
    static T* instance_;
  };
  
  template <class T, int LifeTime>
  T* Singleton<T, LifeTime>::instance_;
} // namespace silly
