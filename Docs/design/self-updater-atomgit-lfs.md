# SelfUpdater 的 GitHub Release 与 AtomGit LFS 双源方案

## 目标

SelfUpdater 不再依赖 IppClub 私有服务器，并恢复可由用户切换的两种完整更新模式：

- GitHub 模式通过 Dora SSR 的 latest Release API 检查版本，直接下载 Release asset；
- AtomGit 模式从公开的 `https://gitcode.com/ippclub/Dora-Releases.git` clone 签名清单，
  再从不可变平台标签 clone Git LFS 安装包。

本方案只建立 AtomGit 发布仓库，不建立同名 GitHub 清单仓库。AtomGit 包的原始输入仍取自
Dora SSR GitHub Release。

## 仓库布局

仓库使用四个互不合并的分支：

| 分支 | 内容 |
| --- | --- |
| `main` | `stable.json`、JSON Schema、发布说明和发布脚本，不含安装包 |
| `android` | 最新 Android ZIP、`package.json` 和 LFS 规则 |
| `windows-x86` | 最新 Windows x86 ZIP、`package.json` 和 LFS 规则 |
| `macos-universal` | 最新 macOS universal ZIP、`package.json` 和 LFS 规则 |

平台分支只保留最新包，避免普通 clone 拉取历史版本。每次发布同时创建包含 revision 的
不可变签名标签：

```text
v1.9.0-5-android
v1.9.0-5-windows-x86
v1.9.0-5-macos-universal
```

其中 `v1.9.0-5` 表示 Dora SSR 基础版本 `v1.9.0` 的第 5 个发布修订。客户端以
`stable.json` 中的基础版本、revision、完整标签引用和 commit ID 为更新身份，不信任
可移动的平台分支头。平台标签可让旧版清单在回滚或灰度期间继续取得对应 LFS 对象。

## 清单

`main/stable.json` 是稳定通道唯一入口，包含：

- 语义化基础版本、非负整数 revision、发布时间和 schema 版本；
- 每个平台的完整标签引用、40 位 commit、文件名、字节数和 SHA-256；
- Dora SSR GitHub Release 的精确备用 URL。

解析器采用严格白名单：拒绝额外字段、非预期平台、危险路径、超出上限的文件、非小写
SHA-256、非 `refs/tags/` 引用以及不属于 IppClub Dora-SSR Release 的备用 URL。

## 信任模型

发布仓库使用独立 Ed25519 密钥签署 `main` 和平台 commit，当前公钥指纹为：

```text
SHA256:Kf0tNlIMveWsTZTKn+W+dDGc20prHQZZRiJPAYoYo0Y
```

公钥固化在引擎原生 Git 后端中，私钥不进入 Dora-SSR 或 Dora-Releases 仓库。客户端执行：

1. clone AtomGit 的 `main`；
2. 验证 HEAD commit 的签名；
3. 若存在上一次可信 commit，要求新 HEAD 是其后代，阻断托管端回滚；
4. 严格解析 `stable.json`；
5. 原子替换本地缓存并记录 commit、签名者和验证时间。

网络失败时只允许使用上一次已经通过签名与历史检查的缓存。首次启动没有可信缓存时，
AtomGit 不可用即停止更新检查。

下载平台包后还必须同时满足：

- clone 到清单记录的不可变标签；
- HEAD 等于清单记录的 commit；
- 平台 commit 通过相同发布密钥验证；
- 文件是仓库内的普通文件；
- 字节数和流式 SHA-256 与签名清单完全一致。

GitHub 模式不依赖 AtomGit 清单。客户端严格检查 latest Release 的标签、三个预期 asset
的精确文件名、URL、字节数和 GitHub API 返回的 SHA-256 digest，再对下载文件执行本地
大小和 SHA-256 校验。额外 asset 不参与更新。

## 运行时选源

界面提供 GitHub 和 AtomGit 两种显式模式，不在失败时静默切换到另一种来源：

- 中文语言默认选择 AtomGit；
- 非中文语言默认选择 GitHub；
- 用户可以随时切换，切换后重新执行该来源完整的检查和下载流程。

AtomGit 清单能把 `v1.9.0` revision 5 显示为 `v1.9.0-5`，并与引擎版本
`1.9.0.5` 比较。GitHub API 只体现 Release 标签 `v1.9.0`，同一个 Release 下替换安装包
不会产生可检测的 revision；因此 GitHub 模式在基础版本相同时明确说明这一限制，并始终
提供“重新下载并安装”。

Windows、Android 和 macOS 支持下载、校验、解压并交给系统安装。macOS 会先把新的
`Dora.app` 完整暂存到当前 App 同目录，显式恢复主程序的可执行权限，当前进程退出后原子
替换；只有新 App 成功交给 LaunchServices 启动后才清理备份，启动失败会立即恢复旧 App。
由 Homebrew 管理的用户仍可选择 `brew upgrade`。Linux 继续由 PPA/apt 管理，但仍可检查
更新元数据。

所有 clone、LFS 下载和 HTTP 下载都支持进度与取消。临时目录只在当前操作成功交给安装
流程前保留，失败或工具关闭时清理。

## 发布流程

`Dora-Releases/scripts/publish-from-github.sh` 是当前发布入口：

1. 从指定 Dora SSR GitHub Release 下载 Android、Windows x86 和 macOS universal ZIP；
2. 对照 GitHub 返回的字节数和 SHA-256 校验输入；
3. 分别更新三个平台分支，生成 `package.json`，创建签名 commit 和签名标签；
4. 先推送每个平台分支和标签到 AtomGit；
5. 对每个标签执行匿名浅 clone，等待 LFS 实体下载完成并再次核对 SHA-256；
6. 生成并签署 `stable.json`；
7. 最后推送 `main`，使客户端只能看到已经完成验证的发布。

本地准备与正式发布分别为：

```sh
scripts/publish-from-github.sh v1.9.1 6
scripts/publish-from-github.sh v1.9.1 6 --push
```

如果任一平台上传或匿名验证失败，禁止推送新的 `main`。已经上传但尚未进入清单的平台
标签不会被客户端发现，可以在修复后继续完成发布。

## 回滚和密钥轮换

普通回滚发布更高的基础版本或 revision，让内容回到已知稳定包；不移动旧标签，也不让
`main` 回退到旧 commit。紧急撤回发布新的签名清单；客户端的 last-known-good 规则仍
要求它是当前可信 commit 的后代。

密钥轮换需要先发布同时信任新旧公钥的引擎版本，再使用新密钥签署发布仓库。直接替换
固化公钥会让尚未升级的客户端永久失去更新能力。

## 验收条件

- Go 单元测试覆盖签名、last-known-good、路径逃逸、字节数和 SHA-256 错误；
- TypeScript 编译并同步生成 Lua；
- 三个平台标签能匿名 clone 且 LFS 文件哈希与 `stable.json` 一致；
- AtomGit 默认分支为 `main`，远端 `main` 是有效签名 commit；
- 中文运行时默认使用 AtomGit，从空缓存完成清单同步并显示 `v1.9.0-5` 与签名信息；
- 切换 GitHub 后能通过 latest Release API 显示基础版本，并保留重新下载入口；
- Windows、Android 和 macOS 显示内置安装按钮，Linux 不显示；
- macOS 暂存 App 的主程序必须具有可执行权限；替换或启动失败时保留或恢复原 App，不从
  临时下载目录直接运行；
- 私有服务器地址和同名 GitHub 清单仓库地址不再出现在 SelfUpdater 路径中。
