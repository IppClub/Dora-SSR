# Dora / Godot 独立依赖规则

更新：2026-11-03。第三方库共享方案已撤销，当前保留完整独立LibGodot运行时。

- Godot继续编译各平台原有第三方源文件，Dora保留自己的实现；不从Godot剔除codec源来改用宿主函数表。
- 不新增跨引擎第三方动态库，不通过全局符号抢占或宿主codec入口绑定两套运行时。
- 每套实现管理自己的内部对象、全局状态和分配/释放；不跨侧释放第三方私有对象，不混用Jolt Factory、SDL子系统、Vorbis状态等。
- 运行时之间仅使用既定版本化Dora/Godot桥；继续保留GPU纹理、同步、输入、音频等整合接口。
- 平台原有系统库链接保持；Web分别保留各自heap，不合并Wasm实例。
- 来源、许可证、构建配置和最终镜像隔离仍需审计；维护范围见[依赖清单](DEPENDENCIES.md)。

此前共享方案、候选ABI与必要复用回归计划保存在[历史快照](history/2026-11-03-library-sharing-removed/snapshot/Tools/Godot/DEPENDENCY_ISOLATION.md)，不再作为当前实施计划。
