# Dorothy SSR
|iOS|macOS|Android|Windows|
|---|-----|-------|-------|
|[![Build Status](https://travis-ci.com/IppClub/Dorothy-SSR.svg?branch=master)](https://travis-ci.com/IppClub/Dorothy-SSR)|[![Build Status](https://travis-ci.com/IppClub/Dorothy-SSR.svg?branch=master)](https://travis-ci.com/IppClub/Dorothy-SSR)|[![Build Status](https://travis-ci.com/IppClub/Dorothy-SSR.svg?branch=master)](https://travis-ci.com/IppClub/Dorothy-SSR)|[![Build status](https://ci.appveyor.com/api/projects/status/cypfm1makpfu4e7i?svg=true)](https://ci.appveyor.com/project/pigpigyyy/dorothy-ssr)|

## 功能展示  
![Dorothy First Power](http://www.luvfight.me/content/images/2018/12/DorothyFirstPower.png)
## 项目目标
&emsp;&emsp;Dorothy SSR项目的最终目标是制作一款跨平台的，专门用于制作2D游戏的“魔兽争霸3世界编辑器”。这个目标由三个子目标组成：
* **Step 1**  
&emsp;&emsp;开发一个跨平台的底层游戏框架。功能包括或是整合图形渲染、物理引擎、资源管理、音频处理、脚本绑定以及部分2D平台游戏的功能等等。（Finished 95%）  

* **Step 2**  
&emsp;&emsp;使用该游戏框架开发游戏编辑器。功能包括：图元编辑器、2D骨骼动画编辑器、物理对象编辑器、游戏对象编辑器、游戏对象动作编辑器、触发器编辑器、AI编辑器、音频管理编辑器、游戏地形编辑器和游戏场景编辑器等等。  

* **Step 3**  
&emsp;&emsp;使用该游戏编辑器开发游戏。制作一个完整的游戏Demo。

&emsp;&emsp;所幸这个项目不是从零开始的。该项目的前身是Dorothy项目。  
&emsp;&emsp;Dorothy项目是一个曾经基于Cocos2D-X 2.x做图形库的改造项目。在使用Lua脚本调用游戏框架本身开发UI界面，编写游戏编辑器，最终实现在游戏里内嵌编辑器运行的效果，已经做了成功的尝试。  
&emsp;&emsp;这个前身项目Dorothy中，已经尝试实现了2D骨骼动画编辑器、物理对象编辑器、游戏对象动作编辑器、触发器编辑器、AI编辑器和游戏场景编辑器等等的基本功能，部分子编辑器功能都甚至可以独立使用了。这正是绝好的时机交给强迫症患者重头再开发一遍了（并不）。实际是因为对更好的技术的追求，决心总结好这个项目过往的经验，使用更先进的底层技术从第一行代码开始重写一遍，并脱离Cocos框架的限制。于是有了这个叫Dorothy SSR的超级升级版项目（后续在本文档中将用SSR代指这个新项目，并称老项目为原Dorothy）。

## Dorothy游戏框架的特色
&emsp;&emsp;新的游戏框架是基于跨平台的bgfx图形库和SDL系统环境库进行开发的。bgfx带来的特性包括多线程渲染，draw call合并，使用多种render back end（如OpenGL，Metal，DX9~12，Vulkan等等）。SDL带来了对平台相关系统接口的封装和简化。其他SSR项目自己的特色如下：
* **内置2D平台游戏功能**  
&emsp;&emsp;整合动画、物理和ECS组件，在C++层实现了一系列基础的2D平台游戏的功能。如：游戏镜头跟踪，场景分层移动，游戏人物的静止、行走、跳跃、近战远程攻击等等动作，游戏单位与地形碰撞，游戏单位之间的感知检测，游戏AI决策树等等功能。

* **更易用的ECS模块**  
&emsp;&emsp;ECS（Entity Component System）是一种数据驱动的游戏逻辑组织方式。通过这种管理机制可以对游戏实体（Entity）进行分组，监听实体的创建销毁事件，监听实体上的组件（Component）的增加、删除以及数值变化的事件，并处理相应的游戏业务逻辑。
&emsp;&emsp;相比其它ECS框架的实现，Dorothy的ECS功能接口设计得更加简洁。只用掌握Entity，Group和Observer三种对象的创建方法，以及every()和each()两个函数的用法，就以编写由数据驱动的游戏逻辑。

* **更多的异步加载**  
&emsp;&emsp;游戏卡顿的来源除了大量的图形或是逻辑处理运算以外，最大的来源就是各式的资源加载和预处理。SSR项目的一个小目标就是给所有涉及IO的接口都提供异步执行的版本。把有大量运算的逻辑处理都扔到额外的工作线程中。  
&emsp;&emsp;目前提供了简单的线程池用于对几类工作做异步处理，例如文件读写（FileIO），资源加载（Loader），大量运算（Process）和打日志（Log），这些异步处理功能都由Async模块提供。  

* **升级的Lua绑定**  
&emsp;&emsp;Lua绑定使用修改后的tolua\+\+库进行，tolua\+\+的runtime部分也做了很多修改。C\+\+对象在Lua中的管理被分为了三种类型，引用类型、值类型、单例类型。对这三种类型对象tolua\+\+会做不同的内存管理处理。最终Lua的用户只用把绑定导入的对象当作普通Lua对象管理就行，不用做额外的处理。提供内置的Lua面向对象机制，支持继承C\+\+对象。  

* **Moonscript语言**  
&emsp;&emsp;Moonscript对于Lua，等同于Coffeescript对于Javascript。是Lua的一种方言，并且编译为Lua语言由Lua解释器加载执行。同时它的语法和Coffeescript的语法非常接近，写出的代码表达力强又极为简洁。非常适合于快速编写复杂的业务逻辑。编写一行Moonscript做的工作可能编写多行Lua代码才能完成同样的工作，所以在SSR项目中极为推荐，并内置了相关支持作为默认的应用开发语言。使用时需要替换Lua的debug.traceback()函数来显示错误信息。或是将写好的Moonscript代码文件编译为Lua代码文件，再进行执行调试。  

* **2D骨骼动画和物理引擎的支持**  
&emsp;&emsp;自带2D骨骼动画的功能，以及全面整合了物理引擎Box2D。原Dorothy项目中还提供了完整可以使用的图形编辑器来创建2D动画或是物理物件。这些编辑器也会在SSR项目的后续开发中移植到新项目中来。  

* **内置ImGui**  
&emsp;&emsp;ImGui是一套适合于嵌入游戏引擎中，编写调试工具或是辅助开发用的图形工具的UI系统。接口简单，几行简单的代码就能创建出复杂的桌面UI界面来。在游戏中内置一个调试窗体输出日志，内置一个控制台输入命令，甚至于内置一个文本编辑器编写代码，使用ImGui都很容易实现。SSR框架中甚至加入了ImGui的Lua绑定，这样就使得它更加易用了。

* **使用TrueType**  
&emsp;&emsp;SSR框架的字体系统是基于stb_truetype库开发的，直接加载ttf或是otf文件来显示文字，让各平台上的字体显示都保持一致。

&emsp;&emsp;SSR框架渲染部分的API大部分与Cocos2D-X 2.x相似，比如Node，Sprite的接口基本保持原样。重写的时候API设计大部分都参考借鉴了Cocos并做了很多精简。所以对于Cocos的用户，使用起来只会更加简单。

## 相关知识的介绍
* **bgfx**  
&emsp;&emsp;是一个跨平台，对各种图形API做wrapper的一套新的图形API。它的backend底层可以对接各版本的OpenGL，各版本的Direct3D，Metal甚至WebGL等等。使用C++编写统一的图形渲染代码通过使用不同的编译配置来切换底层对接的backend。同时自带sort-based draw call bucketing，简单说就是相同状态的draw call自动合并功能。API自带多线程渲染支持，可以自由地开多线程直接调API各自发送渲染指令。总之投入之前单平台底层图形编码的工作量，并且不用做复杂的设计就能完成多平台的图形开发并自动获得很多性能优化上的支持。  

* **SDL**  
&emsp;&emsp;是一个跨平台，对各操作系统API做wrapper的一套系统API。从创建窗体，处理系统事件，到调用各类输入输出设备，提供出平台无关的统一接口。如果一句CreateWindow就能在Win、Mac、iOS、Android等等平台上创建应用；一句PollEvent就能获得键盘、鼠标、触摸屏、游戏手柄等等的事件消息。那这就是好东西用吧。

* **Dorothy**  
&emsp;&emsp;是一个玩具项目，目标是制作一个用来制作玩具的玩具。制作这个玩具的过程曾经让作者玩得很开心。因为底层技术框架的落后，预计有一天会再也无法兼容或是稳定运行在新的硬件或是系统上，所以不得不打算进行彻底重构。这个重构项目预计大量的老代码的核心逻辑是可以复用的，尤其是Dorothy自身框架以及Lua绑定的部分，用作图形渲染的Cocos2D的底层则是需要进行完全重写的。Dorothy的目标是提供一套完善的2D游戏制作工具，带有全图形化的动画、物理、场景、地形、游戏逻辑、AI、游戏单位等等的全套编辑器，并且可以在各类PC和移动设备上运行，让大家能随时随地不受限制地在各式设备上，使用易用的图形工具，自由制作自己的游戏玩具。并告诉大家，想抽SSR也就是在自己的玩具上调一个数字就能实现的事，充钱是不会强身健体树立精神的。  

## 如何使用该项目
&emsp;&emsp;在Windows或是macOS系统下运行`Tools/tolua++/build.bat`或是`Tools/tolua++/build.sh`文件生成Lua绑定的代码文件，然后在Project目录下选择要使用的工程目录，并在相应Code IDE中打开相应的工程文件来进行编译运行。

## 更新日志  
* **2016-12-8**  
&emsp;&emsp;目前该项目的Basic分支上传了一个整合bgfx和SDL2带一小段渲染测试代码的基础示例，提供xCode，Android Studio，VS2015工程，并且在Win、OSX、iOS和Android上编译运行测试通过。接下来就要进入SSR项目的开发，各位希望参与这个框架设计和开发可以联系我，QQ：dragon-fly@qq.com，我的博客是：www.luvfight.me ，请说明来意，谢谢啦。真诚欢迎各位的加入。  

* **2016-12-9**  
&emsp;&emsp;开始进行项目准备，对原Dorothy项目的Lua代码部分进行分析，并粗略统计出实际所用的API种类以及代码中的出现次数。并以此作为后期开发排优先级和统计进度的一个参考，预计有228个接口需要重写，251个接口只用做迁移并复用代码。以后会把开发进度也更新在Readme上。  

* **2017-3-14**  
&emsp;&emsp;今天项目进度的统计刚好到50%，应该庆贺一下。不过实际的进度还要慢一点点，因为这50%的API很多还没有bind到Lua里，而且更重要的是，到目前为止实现的功能还没有做完整的单元测试，只是边实现功能边随手测了下。接下来的工作是补Lua binding，补单元测试，单元测试打算直接就用Lua写了。剩下要实现的API大部分是只需要从原项目把老代码迁移过来的，应该难度要小很多，当然工作量还并不少。  

* **2017-3-25**  
&emsp;&emsp;今天把项目进度更新到74%，其实核心功能都已经基本完成了，剩下的功能比如PlatformWorld、Unit、Bullet几个横版游戏所用的类，类似Component模式的UnitAction类，还有那些简陋的Behavior Tree的节点类，可能需要扔掉这些老接口重新设计一下，现在计划暂时先不忙着推进这些功能。Lua binding已经补上了，Moonscript脚本语言也加回来了，要准备补Sample和Test，还有开始补各式文档，并对一些项目设计上的点写一点Review的文章。  

* **2018-7-20**  
&emsp;&emsp;把Dorothy的Platformer Game的框架又移植回来，同时也增加了ECS的功能。因为发现ECS对减少游戏逻辑实现的工作量并无太大帮助，所以发现过去编写的功能框架并非完全不可取。

## 当前进度  
&emsp;**Step 1**
```
Redo: 232/256 90.62%
```
```
Ship: 241/242 99.59%
```
```
Total: [ ##############  ] 94.98%
```

## License
MIT