---
sidebar_position: 0
---

# Dora SSR API 参考手册

&emsp;&emsp;欢迎来到 Dora SSR API 参考手册！本文档为您提供关于 Dora SSR 游戏引擎内的 API 和功能的详细信息。您可以使用以下指南浏览不同主题并探索引擎的功能。

## 基础功能

&emsp;&emsp;这个类别提供了一些引擎的通用基础工具和服务。

* [App](/docs/api/Class/App)
* [View](/docs/api/Class/View)
* [Profiler](/docs/api/Class%20Object/Profiler)
* [Object](/docs/api/Class/Object)

### 音频管理

&emsp;&emsp;这个类别提供了管理和播放游戏音乐和声效的功能。

* [Audio](/docs/api/Class/Audio)
* [AudioBus](/docs/api/Class/AudioBus)
* [AudioSource](/docs/api/Class/AudioSource)

### 资产管理

&emsp;&emsp;这个类别提供了管理各种游戏资产（包括文件和数据）的功能。

* [Content](/docs/api/Class/Content)
* [Path](/docs/api/Class/Path)
* [Cache](/docs/api/Class/Cache)
* [DB](/docs/api/Class/DB)

### 输入管理

&emsp;&emsp;这个类别提供了一部分游戏输入处理的功能。另外的输入处理如点击/触摸事件可以在节点事件中进行注册和处理。

* [Trigger](/docs/api/Class/InputManager/Trigger)
* [InputManager](/docs/api/Class/InputManager)
* [Keyboard](/docs/api/Class/Keyboard)
* [Mouse](/docs/api/Class/Mouse)
* [Controller](/docs/api/Class/Controller)

### 数据结构

&emsp;&emsp;这个类别提供了一系列数据结构和类型。

* [Array](/docs/api/Class/Array)
* [Dictionary](/docs/api/Class/Dictionary)
* [Vec2](/docs/api/Class/Vec2)
* [Size](/docs/api/Class/Size)
* [Rect](/docs/api/Class/Rect)
* [Color](/docs/api/Class/Color)
* [Color3](/docs/api/Class/Color3)

## 场景管理

&emsp;&emsp;这个类别负责游戏场景树的管理。

### 场景树管理

&emsp;&emsp;这里提供游戏场景树根节点和摄像机的管理。

* [Director](/docs/api/Class/Director)
* [Scheduler](/docs/api/Class/Scheduler)
* [Camera](/docs/api/Class/Camera)
* [Camera2D](/docs/api/Class/Camera2D)
* [CameraOtho](/docs/api/Class/CameraOtho)

### 场景节点

&emsp;&emsp;这里提供游戏场景节点和节点事件的管理。

* [Node](/docs/api/Class/Node)
* [AlignNode](/docs/api/Class/AlignNode)
* [Menu](/docs/api/Class/Menu)
* [Touch](/docs/api/Class/Touch)
* [Slot](/docs/api/Class/Slot)
* [GSlot](/docs/api/Class/GSlot)
* [emit](/docs/api/Module/emit)

## 事件管理

&emsp;&emsp;这个类别负责游戏事件的管理。

### 全局事件

&emsp;&emsp;这个子类别处理全局级别的事件，比如应用程序事件和操作系统事件。

* [App Event](/docs/api/Global%20Event/App)

### 节点事件

&emsp;&emsp;这个子类别处理场景节点级别的事件。

* [Node Event](/docs/api/Node%20Event/Node)
* [Body Event](/docs/api/Node%20Event/Body)
* [Playable Event](/docs/api/Node%20Event/Playable)
* [Particle Event](/docs/api/Node%20Event/Particle)
* [AlignNode Event](/docs/api/Node%20Event/AlignNode)
* [EffekNode Event](/docs/api/Node%20Event/EffekNode)

## 图形渲染

&emsp;&emsp;这个类别负责游戏图形的渲染。

### 基础渲染节点

&emsp;&emsp;这个类别提供一些基础通用游戏图形渲染场景节点。

* [Sprite](/docs/api/Class/Sprite)
* [Grid](/docs/api/Class/Grid)
* [Line](/docs/api/Class/Line)
* [DrawNode](/docs/api/Class/DrawNode)
* [ClipNode](/docs/api/Class/ClipNode)
* [Label](/docs/api/Class/Label)
* [EffekNode](/docs/api/Class/EffekNode)
* [TileNode](/docs/api/Class/TileNode)
* [VGNode](/docs/api/Class/VGNode)
* [SVG](/docs/api/Class/SVG)
* [Particle](/docs/api/Class/Particle)

### 渲染管理对象

&emsp;&emsp;这个类别提供一些图形渲染管理功能的对象。

* [Texture2D](/docs/api/Class/Texture2D)
* [BlendFunc](/docs/api/Class/BlendFunc)
* [Effect](/docs/api/Class/Effect)
* [SpriteEffect](/docs/api/Class/SpriteEffect)
* [Pass](/docs/api/Class/Pass)
* [RenderTarget](/docs/api/Class/RenderTarget)
* [Grabber](/docs/api/Class/Node/Grabber)

### 动画模型功能

&emsp;&emsp;这个子类别提供了加载创建和处理2D动画模型的功能。

* [Playable](/docs/api/Class/Playable)
* [Model](/docs/api/Class/Model)
* [DragonBone](/docs/api/Class/DragonBone)
* [Spine](/docs/api/Class/Spine)

## 节点动作

&emsp;&emsp;这个类别负责创建和管理场景节点上可以执行的动作。

* [Action](/docs/api/Class/Action)
* [Ease](/docs/api/Class/Ease)
* [Move](/docs/api/Module/Move)
* [X](/docs/api/Module/X)
* [Y](/docs/api/Module/Y)
* [Z](/docs/api/Module/Z)
* [Angle](/docs/api/Module/Angle)
* [AngleX](/docs/api/Module/AngleX)
* [AngleY](/docs/api/Module/AngleY)
* [Roll](/docs/api/Module/Roll)
* [Scale](/docs/api/Module/Scale)
* [ScaleX](/docs/api/Module/ScaleX)
* [ScaleY](/docs/api/Module/ScaleY)
* [SkewX](/docs/api/Module/SkewX)
* [SkewY](/docs/api/Module/SkewY)
* [Opacity](/docs/api/Module/Opacity)
* [Height](/docs/api/Module/Height)
* [Width](/docs/api/Module/Width)
* [Frame](/docs/api/Module/Frame)
* [Sequence](/docs/api/Module/Sequence)
* [Spawn](/docs/api/Module/Spawn)
* [Delay](/docs/api/Module/Delay)
* [Event](/docs/api/Module/Event)
* [Show](/docs/api/Module/Show)
* [Hide](/docs/api/Module/Hide)
* [AnchorX](/docs/api/Module/AnchorX)
* [AnchorY](/docs/api/Module/AnchorY)

## 物理模拟

&emsp;&emsp;这个类别提供了创建和管理物理对象模拟的功能。

* [PhysicsWorld](/docs/api/Class/PhysicsWorld)
* [BodyDef](/docs/api/Class/BodyDef)
* [Body](/docs/api/Class/Body)
* [Sensor](/docs/api/Class/Sensor)
* [FixtureDef](/docs/api/Class/FixtureDef)
* [JointDef](/docs/api/Class/JointDef)
* [Joint](/docs/api/Class/Joint)
* [MoveJoint](/docs/api/Class/MoveJoint)
* [MotorJoint](/docs/api/Class/MotorJoint)

## ECS 系统

&emsp;&emsp;这个类别负责提供实体组件系统（ECS）的功能。

* [Entity](/docs/api/Class/Entity)
* [Group](/docs/api/Class/Group)
* [Observer](/docs/api/Class/Observer)

## 平台游戏框架

&emsp;&emsp;这个类别为2D平台游戏提供了一套基础的开发框架功能。

* [Behavior](/docs/api/Class/Platformer/Behavior)
* [Blackboard](/docs/api/Class/Platformer/Behavior/Blackboard)
* [Decision](/docs/api/Class/Platformer/Decision)
* [AI](/docs/api/Class/Platformer/AI)
* [Data](/docs/api/Class/Platformer/Data)
* [PlatformCamera](/docs/api/Class/Platformer/PlatformCamera)
* [PlatformWorld](/docs/api/Class/Platformer/PlatformWorld)
* [TargetAllow](/docs/api/Class/Platformer/TargetAllow)
* [UnitAction](/docs/api/Class/Platformer/UnitAction)
* [UnitActionParam](/docs/api/Class/Platformer/UnitActionParam)
* [Unit](/docs/api/Class/Platformer/Unit)
* [BulletDef](/docs/api/Class/Platformer/BulletDef)
* [Bullet](/docs/api/Class/Platformer/Bullet)
* [Face](/docs/api/Class/Platformer/Face)
* [Visual](/docs/api/Class/Platformer/Visual)

## 协程管理

&emsp;&emsp;这个类别提供更为便捷的协程（coroutine）的创建和管理功能。

* [Routine](/docs/api/Class/Routine)
* [thread](/docs/api/Module/thread)
* [threadLoop](/docs/api/Module/threadLoop)
* [once](/docs/api/Module/once)
* [loop](/docs/api/Module/loop)
* [cycle](/docs/api/Module/cycle)
* [sleep](/docs/api/Module/sleep)
* [wait](/docs/api/Module/wait)

## 机器学习算法

&emsp;&emsp;这个类别提供了一些基础的机器学习算法，包括决策树算法C4.5以及强化学习算法Q-learning等。

* [C4.5](/docs/api/Class/ML#builddecisiontreeasync)
* [Q-learning](/docs/api/Class/QLearner)

## 对话系统

&emsp;&emsp;这个类别负责提供加载和执行复杂的游戏对话系统的功能。

* [YarnRunner](/docs/api/Class/YarnRunner)
* [TextResult](/docs/api/Class/YarnRunner/TextResult)
* [OptionResult](/docs/api/Class/YarnRunner/OptionResult)
* [Markup](/docs/api/Class/YarnRunner/Markup)

## 网络服务

&emsp;&emsp;这个类别负责提供网络通讯相关的功能。

* [json](/docs/api/Class/json)
* [Request](/docs/api/Class/Request)
* [HttpClient](/docs/api/Class/HttpClient)
* [HttpServer](/docs/api/Class/HttpServer)

## 其它功能

&emsp;&emsp;这个类别下是引擎提供的其它杂项的功能。

* [Buffer](/docs/api/Class/Buffer)
* [tolua](/docs/api/Class/tolua)
* [yue](/docs/api/Class/yue)
* [yue.Config](/docs/api/Class/yue/Config)
* [yue.Config.Options](/docs/api/Class/yue/Config/Options)
