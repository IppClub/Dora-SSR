# 文档站游戏试玩

文档页面位于 `/play`，点击游戏卡片才创建 iframe；关闭、切换或离开页面销毁旧实例。所有游戏共用一份 `dora-preset` 引擎，游戏 manifest 和资源分别打包，存档按游戏 ID 挂载独立 IDBFS 数据库。

## 本地构建

先按 Web 构建说明准备 Emscripten 和第三方依赖，再在仓库根目录执行：

```sh
node Tools/build-scripts/build_web_gallery.mjs
cd Docs
pnpm build
pnpm serve --host 127.0.0.1 --port 8896
```

脚本默认更新 `build/Dora-Demo` 到上游默认分支的最新提交（通过远端 HEAD 查询，当前为 master），编译当前引擎源码并扫描所有顶层游戏目录。引擎 checkout 应在开始构建前更新到最新 main；脚本不修改开发者 checkout。没有预生成 `init.lua` 的游戏会明确失败，不会静默跳过。引擎和 demo 的提交信息只用于追溯，不是固定版本依赖。

`DORA_DEMO_DIR` 可指定本地开发目录（不会拉取或修改该目录）；`DORA_WEB_BUILD_DIR` 指定 Web 构建目录；`DORA_WEB_GALLERY_DIR` 指定静态输出目录，默认 `Docs/static/play`。生成目录不提交 Git。当前 preset 包含 AI Fighter 所需的 ML 与 Yue 编译器；可以通过 `DORA_WEB_FEATURE_ML`、`DORA_WEB_FEATURE_YUE` 裁剪其他用途的运行时。

运行时目录按其内容哈希命名，游戏目录按 manifest 哈希命名。全部打包成功后才替换 `catalog.json`，保留旧资源供已打开页面继续使用。发布时应整体部署文档 build；发布环境应定期保留最近成功版本并清理旧资源。构建不向远程网站发布。

## 本地浏览器验证

```sh
DORA_WEB_GALLERY_URL=http://127.0.0.1:8896/play/ \
DORA_WEB_GALLERY_PAGE=http://127.0.0.1:8896/play \
DORA_WEB_SMOKE_SCREENSHOT_DIR=build/gallery-screenshots \
node Tools/build-scripts/check_web_game_smoke.mjs --gallery Docs/static/play
```

脚本逐款点击实际文档站卡片，等待 iframe 进入 running，检查脚本异常并截图；随后写入独立存档、点击重启并验证恢复，最后关闭 iframe。此检查不替代完整操作、关卡及 AI 学习功能验收；浏览器验证仅在本地执行，未加入 CI。

2026-09-10 本地验证：7 款游戏全部通过启动、存档隔离、重启恢复和关闭检查；中英文文档生产构建通过。截图位于 `build/gallery-screenshots/`。画面检查修复了精简版 `Director.entry` 缺失及中文缺字问题；文档站构建使用完整 Sarasa 中文字体，所有语言页面共用同一套 Player URL。当前 Node 脚本语法、loader 测试通过；文档全量 typecheck 被已有 `src/theme/NotFound.js` 中的 TypeScript 类型标注阻断，与本次页面无关。

## API 完整性回归

2026-09-10 后续验证更新到 Dora-Demo `4c01e99`（仅记录验证来源，不固定版本）。Dodge the Creeps 的 Start 之后依赖 `Vec2:mul()` 和 `Vec2:add()`，此前标题页冒烟未覆盖这段代码。缺失原因是 Web 使用独立 Lua 初始化文件，漏掉了原生初始化提供的 TSTL 运算方法，并非 C++ 向量运算被裁剪。

- `node Tools/build-scripts/check_web_api_parity.mjs`：对照 101 项原生 Lua 辅助接口、83 项手工绑定；生成绑定继续直接使用 Dora/ImGui/NanoVG 的公共声明。构建入口执行该检查，明确列出裁剪例外，未分类缺失导致失败。
- `node Tools/build-scripts/check_web_api_contract.mjs`：在本地 Chrome 执行实际 WASM；自动生成保留的 Lua 辅助接口与事件方法清单，并验证向量/尺寸/矩形、JSON 返回契约、颜色、QLearner 编解码、Yue 编译、文件异步读写复制和数据库异步读写。
- 上面的文档站冒烟命令增加 `DORA_WEB_TEST_DODGE=1`：实际点击 Start，发送 D 键移动，等待敌人生成并检查脚本错误。游戏画面截图为 `dodge-gameplay.png`。

本次补齐：运算及字符串辅助方法、rgba/json 导出、Content/RenderTarget/DB/HttpClient/Shader 协程包装、事件快捷方法、TileNode 过滤、Spine/DragonBone 命中测试、QLearner 手工绑定，以及启用 Yue 时的导出接口。精简版 DB 使用 `/user/saves/dora.db`，不再误用完整版 `/idbfs` 路径。

以上接口契约测试和最新 7 款游戏回归均通过。检查覆盖的是已保留模块的接口完整性及列出的行为，不等于每个接口的全部参数组合、远程服务、平台和游戏关卡均已验证；Git、HTTP 服务端、3D、Wasm/Teal/XML/Yarn 编译等明确裁剪项不是缺漏。浏览器契约测试不加入 CI。
