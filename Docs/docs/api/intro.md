---
sidebar_position: 0
---

# Dora SSR API Reference

Welcome to the Dora SSR API Reference! This documentation provides detailed information about the APIs and functionality available within the Dora SSR game engine. Use the guide below to navigate through different topics and explore the capabilities of the engine.

## Basic Functionality

This category provides general functions and services of the engine.

* [App](/docs/api/Class/App)
* [View](/docs/api/Class/View)
* [Profiler](/docs/api/Class%20Object/Profiler)
* [Object](/docs/api/Class/Object)

### Audio Menagement

This category provides features for managing and playing game music and sound effects.

* [Audio](/docs/api/Class/Audio)
* [AudioBus](/docs/api/Class/AudioBus)
* [AudioSource](/docs/api/Class/AudioSource)

### Assets Management

This category offers the ability to manage various game assets, including files and data.

* [Content](/docs/api/Class/Content)
* [Path](/docs/api/Class/Path)
* [Cache](/docs/api/Class/Cache)
* [DB](/docs/api/Class/DB)

### Input Management

This category provides part of the game's input processing capabilities. The rest input handling, such as tap/touch events, can be registered and handled in node events.

* [Trigger](/docs/api/Class/InputManager/Trigger)
* [InputManager](/docs/api/Class/InputManager)
* [Keyboard](/docs/api/Class/Keyboard)
* [Mouse](/docs/api/Class/Mouse)
* [Controller](/docs/api/Class/Controller)

### Data Structure

This category provides a range of data structures and types.

* [Array](/docs/api/Class/Array)
* [Dictionary](/docs/api/Class/Dictionary)
* [Vec2](/docs/api/Class/Vec2)
* [Size](/docs/api/Class/Size)
* [Rect](/docs/api/Class/Rect)
* [Color](/docs/api/Class/Color)
* [Color3](/docs/api/Class/Color3)

## Scene Management

This category is for managing game scene trees.

### Tree Management

This category provides the management of the root nodes and cameras of the game scene.

* [Director](/docs/api/Class/Director)
* [Scheduler](/docs/api/Class/Scheduler)
* [Camera](/docs/api/Class/Camera)
* [Camera2D](/docs/api/Class/Camera2D)
* [CameraOtho](/docs/api/Class/CameraOtho)

### Tree Nodes

This category provides the management of game scene nodes and node events.

* [Node](/docs/api/Class/Node)
* [AlignNode](/docs/api/Class/AlignNode)
* [Menu](/docs/api/Class/Menu)
* [Touch](/docs/api/Class/Touch)
* [Slot](/docs/api/Class/Slot)
* [GSlot](/docs/api/Class/GSlot)
* [emit](/docs/api/Module/emit)

## Event Management

This category is for managing game events.

### Global Events

This subcategory handles global-level events, such as application and operating system events.

* [App Event](/docs/api/Global%20Event/App)

### Node Events

This subcategory handles scene node-level events.

* [Node Event](/docs/api/Node%20Event/Node)
* [Body Event](/docs/api/Node%20Event/Body)
* [Playable Event](/docs/api/Node%20Event/Playable)
* [Particle Event](/docs/api/Node%20Event/Particle)
* [AlignNode Event](/docs/api/Node%20Event/AlignNode)
* [EffekNode Event](/docs/api/Node%20Event/EffekNode)

## Graphics Rendering

This category is about functions for rendering game graphics.

### Render Nodes

This category provides some basic and general game graphics rendering nodes..

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

### Render Objects

This category provides some rendering controlling objects.

* [Texture2D](/docs/api/Class/Texture2D)
* [BlendFunc](/docs/api/Class/BlendFunc)
* [Effect](/docs/api/Class/Effect)
* [SpriteEffect](/docs/api/Class/SpriteEffect)
* [Pass](/docs/api/Class/Pass)
* [RenderTarget](/docs/api/Class/RenderTarget)
* [Grabber](/docs/api/Class/Node/Grabber)

### Animation Models

This subcategory provides functionality for creating and manipulating 2D animation models.

* [Playable](/docs/api/Class/Playable)
* [Model](/docs/api/Class/Model)
* [DragonBone](/docs/api/Class/DragonBone)
* [Spine](/docs/api/Class/Spine)

## Node Actions

This category is for creating and managing actions that can be performed on scene nodes.

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

## Physics Simulation

This category provides functionality for creating and managing physical object simulations.

* [PhysicsWorld](/docs/api/Class/PhysicsWorld)
* [BodyDef](/docs/api/Class/BodyDef)
* [Body](/docs/api/Class/Body)
* [Sensor](/docs/api/Class/Sensor)
* [FixtureDef](/docs/api/Class/FixtureDef)
* [JointDef](/docs/api/Class/JointDef)
* [Joint](/docs/api/Class/Joint)
* [MoveJoint](/docs/api/Class/MoveJoint)
* [MotorJoint](/docs/api/Class/MotorJoint)

## ECS Framework

This category provides the functionality of the Entity Component System (ECS).

* [Entity](/docs/api/Class/Entity)
* [Group](/docs/api/Class/Group)
* [Observer](/docs/api/Class/Observer)

## Platformer Game Framework

This category provides a basic development framework for 2D platform games.

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

## Coroutine Management

This category provides convenient creation and management of coroutines.

* [Routine](/docs/api/Class/Routine)
* [thread](/docs/api/Module/thread)
* [threadLoop](/docs/api/Module/threadLoop)
* [once](/docs/api/Module/once)
* [loop](/docs/api/Module/loop)
* [cycle](/docs/api/Module/cycle)
* [sleep](/docs/api/Module/sleep)
* [wait](/docs/api/Module/wait)

## Machine Learning Algorithms

This category provides some basic machine learning algorithms, including the C4.5 decision tree algorithm and the Q-learning reinforcement learning algorithm.

* [C4.5](/docs/api/Class/ML#builddecisiontreeasync)
* [Q-learning](/docs/api/Class/QLearner)

## Dialogue System

This category provides the functionality for loading and executing complex game dialogues.

* [YarnRunner](/docs/api/Class/YarnRunner)
* [TextResult](/docs/api/Class/YarnRunner/TextResult)
* [OptionResult](/docs/api/Class/YarnRunner/OptionResult)
* [Markup](/docs/api/Class/YarnRunner/Markup)

## Networking Service

This category provides the functionality for networking service.

* [json](/docs/api/Class/json)
* [Request](/docs/api/Class/Request)
* [HttpClient](/docs/api/Class/HttpClient)
* [HttpServer](/docs/api/Class/HttpServer)

## Misc Functions

This category provides other miscellaneous features provided by the engine.

* [Buffer](/docs/api/Class/Buffer)
* [tolua](/docs/api/Class/tolua)
* [yue](/docs/api/Class/yue)
* [yue.Config](/docs/api/Class/yue/Config)
* [yue.Config.Options](/docs/api/Class/yue/Config/Options)
