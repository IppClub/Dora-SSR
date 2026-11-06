# Dora / Godot 独立依赖审计

更新：2026-11-03。共享第三方库改造已撤销；Godot恢复包含原有模块和第三方实现的完整独立LibGodot构建。Godot C#/Mono关闭、平台渲染后端等既定产品配置保持。

Dora和Godot分别编译、链接并管理自己的依赖实例，不保留宿主codec函数表或独立共享codec动态库。平台已有系统库依赖按原规则使用。运行时C桥与GPU纹理共享不属于第三方二进制复用，继续保留。

## 当前维护范围

- 固定Godot 4.7.2-stable来源、Dora补丁和许可证；第三方目录维持独立版本。
- 核对实际平台编译配置、符号可见性、最终镜像依赖和通知文件。
- NIR剩余12项许可随D3D12恢复验收时处理；不再将跨引擎第三方ABI共用、分配器混用或共享性能作为交付任务。
- 源码和链接同名不证明可以共用实例；维持[隔离规则](DEPENDENCY_ISOLATION.md)。

## 已核对的主要依赖

| 依赖 | Dora | Godot |
| --- | --- | --- |
| Theora | 1.2.0 portable decoder及兼容入口 | 独立1.2.0解码实现，保留平台源码 |
| Ogg | 官方1.3.5及已登记补丁 | 独立1.3.6 |
| Vorbis | 已登记aoTuV/Lancer保留基线及补丁 | 独立libvorbis 1.3.7 |
| zlib | 1.3.1及已登记补丁 | 独立vendor版本及平台原有系统链接 |
| Jolt | 5.5.0及Dora bridge | 独立5.4.0 |
| SDL | SDL2保留开发基线及两层补丁 | 独立SDL3裁剪版本 |
| glslang / SPIRV-Cross | bgfx保留版本及补丁 | Godot各自版本与构建配置 |
| astcenc / TinyEXR | bimg保留版本及补丁 | Godot各自保留版本 |

源码对应、版本、布局、对象/符号、平台镜像及许可审计的详细证据，完整保存在撤销前审计快照（`history/2026-11-03-library-sharing-removed/snapshot/Tools/Godot/DEPENDENCIES.md`）及其引用的历史记录中。这些结果是历史审计范围，不代替当前构建和平台运行验收。

## 来源与剩余任务

登记及未忽略源码由[audit_vendor_provenance.py](https://github.com/IppClub/Dora-Example/blob/master/Test/Godot/audit_vendor_provenance.py)和[SOURCE_DELTA.json](vendor/SOURCE_DELTA.json)维护；复查流程见[vendor说明](vendor/README.md)。恢复独立实现后的复核证据写入`build/godot-full-runtime-restored-v1/vendor-verified/verification.json`。

共享改造的综合依赖前置审计已撤销，原状态见归档（`history/2026-11-03-deps-audit-retired/README.md`）。日常源码/许可通知维护继续按现有构建封包规则执行；NIR剩余12项单列为NIR-LICENSE-01，随本轮已跳过的D3D12保留后续，不阻塞当前WGL等后端收口。
