---
name: atompie-submission
description: Prepare a Dora SSR game for AtomPie (原子派投稿), set its launcher title and cover, connect an AtomPie account and submit a game for review from the IDE.
---
<!-- dora-managed-skill:atompie-submission:v6 -->

# 向原子派提交 Dora 作品

## 开发时配置作品卡片

找到要发布的游戏的 `init.*` 所在目录。一个仓库可以包含多个游戏，每个游戏的展示配置都紧邻自己的入口。在作者确定作品名时就补上标题，有封面后再补图。

- 合并更新 `.dora/repo.json` 中的 `title.zh` 和 `title.en`，保留其它字段和已有译名。只有一个正式名称时，两种界面可共用该名称。例如 `{"title":{"zh":"窗边自习室","en":"Window Study"}}`。已有 JSON 无法解析时，先修复或向作者核对。
- 作品的一两句简介写入同文件的 `description.zh`、`description.en`。作品资料按所选语言读取标题和简介，同语言下兼容资源下载器写入的 `desc`。作者可分别补充两个版本。详细介绍取自 README，标签由作者填写。
- 复用作者选定的 JPG 或 PNG 封面，按实际格式写入 `.dora/banner.jpg` 或 `.dora/banner.png`。启动器先查 JPG，再查 PNG，也兼容同级 `Image/banner.jpg` 和 `Image/banner.png`。更换格式时检查是否有旧图优先生效。缺封面时可请作者选图，或经同意从游戏画面截取。
- 投稿前用 Dora 的 Git 面板检查入口、标题和封面是否已包含在公开仓库默认分支。拉取端使用普通 Git 图片文件，LFS 指针无法作为封面显示。已导入过的项目会复用本地目录，需要拉取更新才能看到改动。

启动器还读取 `categories` 字符串数组，其中 `Tool`（忽略大小写）会把项目归入工具列表。原子派的稿件标签由作者单独选择。资源下载器还会写入资源标识 `name`、兼容简介 `desc`、可运行标记或入口目录列表 `exe`、缺少预览图标记 `noBanner`。编辑卡片时保留这些安装信息。封面按上述图片路径查找。

## 选择仓库并投稿

整理可玩工程时，从入口与已实现的操作、玩法、启动步骤生成面向玩家的 README.md，优先放在游戏目录。Dora 原生项目从作品的构建记录或对应导出包 `runtime.json` 的 `engineVersion` 核实开发版本。引擎内的 `Dora.App.version` 表示当前环境。只取得当前环境版本时按此标注，无法核实时省略版本号。徽章文字与图片地址使用同一版本。已有 README 时保留作者内容，只更新有依据的部分。项目资料页优先读游戏目录，其次读仓库根目录；中文卡片优先读 README.zh-CN.md 或 README.zh.md，默认读 README.md。英文卡片读 README.en.md。详细介绍默认渲染 Markdown，点击「编辑」并保存可更新对应 README。未找到文件时，可在项目资料页点击「用 Dora 生成 README」。标签由作者填写。

1. 在 Web IDE 或引擎内嵌编辑器双击作品目录，点击与「Dora」「文件」「Git」并列的「发布」。在「Dora 项目资料」切换中英文、核对标题和简介、编辑启动器分类，并选择和裁剪封面。这些修改自动保存到项目的 `.dora` 目录。README 在编辑器中单独保存。
2. 选择本次发布的语言，点击「发布到原子派」。核对自动识别的开发引擎（Dora SSR、Godot、LÖVE2D 或 TIC-80）和远程仓库，填写原子派标签、游玩方式、适配平台和版本，视频链接选填。需要修改项目资料时点击「返回项目资料」。
3. 原子派送审接受 AtomGit、GitHub 或 Gitee 的公开仓库首页。默认选择 origin，可以切换其他可用仓库。没有远程时可在「Git」中添加，提交和推送按作者授权执行。
4. 点击「连接原子派」，让作者在浏览器中登录并核对 IDE 显示的匹配码，确认授权后返回 Dora。此浏览器再次打开 IDE 时可继续使用已连接账号。需要换账号时点击「断开连接」。
5. 选中稿件语言和个人或组织归属，点击「保存原子派草稿」。准备送审时点击「提交中文稿审核」或「提交英文稿审核」，由作者核对作品和归属后确认。遇到请求中断时，点击「重试送审」，沿用同一次提交。
6. 送审成功后，点击「我的稿件」到原子派查看审核进度和记录。审核通过并公开后，可从作品页点击「在 Dora SSR 中打开」，检查拉取后的作品标题和封面。
