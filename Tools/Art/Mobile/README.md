# Dora Remix 原画对齐

按用户反馈撤销像素化：只使用备份 `dora-remix-states.original.png` 的原始 RGBA，裁切、整数平移和重新拼接；不生成图片、不降色、不重采样、不清理半透明边缘。原图 SHA-256 由测试锁定。

## 重建

需要 Python 3 与 Pillow（本次 Pillow 12.3.0）。在仓库根目录运行：

```sh
python3 -m pip install -r Tools/Art/Mobile/requirements.txt
python3 Tools/Art/Mobile/rebuild_mascot.py --evidence /tmp/dora-mascot-evidence
python3 Tools/Art/Mobile/test_mascot.py
```

默认更新运行时图集和 `Assets/Script/Dev/Mobile/MascotFrames.ts`，不覆盖原图备份。使用 `--output /tmp/candidate.png` 可输出候选图，其布局文件默认写入证据目录；也可用 `--layout-output` 显式指定。TS 布局与播放器修改后须通过 Dora Web IDE 编译为 Lua。

## 算法与约定

1. Alpha 阈值仅用于识别 24 个主体连通区域，再按空间位置排列为 6 行、每行 4 帧。原图人物跨越原先的 256 像素方格，不能按固定网格硬切。
2. 用底部鞋子区域估计脚底与身体中线，不使用头部或外接矩形中心，保留歪头、蹲下等原动作。
3. 主体矩形四边扩展 4 像素保留柔边，将原始矩形 RGBA 不带 mask 直接复制到 272×272 帧格内。不拉伸、不旋转、不改变矩形内任何颜色或 Alpha。
4. 整数平移后脚底 Y=248，X 在 136 附近。不足一像素的 X 差异写入自动生成的逐帧 pivot，由播放器 anchor 补偿，不对图片做亚像素重采样。
5. 拼为 1088×1632 RGBA 图集，行序 idle、waiting、thinking、working、success、failed。空白区域透明，主体保留原半透明边缘。

`Mascot.tsx` 在换帧时同时更新裁切区域和逐帧 anchor；保留 Point 采样与减少动态效果时固定首帧。缩放恢复为请求尺寸除以帧格尺寸，不再约束为旧版大像素网格的整数倍。

Python 测试检查原图哈希、24 个原始矩形逐字节 RGBA 一致、平移与生成布局一致，以及 PNG/TS 重建字节一致性。`MascotTest.tsx` 在真实 Dora 引擎内检查四种显示尺寸、全部 24 帧裁切与 anchor、脚底世界坐标变化小于 0.001，以及采样模式读回与减少动态效果模型。截图/GIF 仅供预览，不是运行时图集。

旧像素化结果只作为历史证据保留于 `docs/kanban/todo/16-dora-mobile-game-feed-remix/evidence/mascot-pixel-2026-08-30/`，不再代表当前美术方案。
