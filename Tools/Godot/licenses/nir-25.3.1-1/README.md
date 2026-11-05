# Godot NIR 25.3.1-1 通知材料

D3D12 包自动附带 `GODOT-NIR-THIRD-PARTY-NOTICES.txt` 与 `GODOT-NIR-PROVENANCE.json`；其他后端不增加这些文件。通知正文按来源路径分组，保留原版权和许可段落，不以构建包装仓库的 MIT 许可证代替 Mesa/Vulkan/BLAKE3 的通知。

来源固定为：

- Godot NIR tag `25.3.1-1`，源码归档 SHA-256 `21ba3c0532caa580b50c530aefc851686b747b41d7984c228bcc0cef7ef5db82`。
- Mesa commit `5005a50879b11b953ade113fccd13a208f706ba0`，源码归档 SHA-256 `15a688666aca976d1479c8bd43d319a55613da9a91aaf42a07691daec96ba7be`。
- Godot 同 tag 的补丁；只应用到临时源码副本。SDK 397 个非生成头文件在明确统一 CRLF/LF 后与该副本一致。
- Mesa README 标明内嵌 BLAKE3 1.8.2；上游许可和选择说明保留在 `blake3-1.8.2/`，获取 URL 与摘要见其 `sources.json`。

用已下载的官方归档及固定 SDK 复现（从仓库根目录）：

```sh
python3 Tools/Godot/generate_nir_notices.py \
  --mesa-source /path/to/mesa-exact-commit.tar.gz \
  --nir-source /path/to/godot-nir-source-25.3.1-1.tar.gz \
  --sdk-root /path/to/mesa-x86_64-gcc \
  --output /path/to/notice-output
python3 $DORA_TEST_REPO/Test/Godot/test_nir_package_notices.py
```

生成器先验证两个归档摘要及 SDK 410 项文件，再按上游复制清单收集源码、头文件、生成器和数据，并补充 Vulkan、BLAKE3 许可。包括 SPIR-V JSON 的 copyright 字段。不会执行上游更新脚本，也不改写 vendor 或 SDK。

本清单保守包含可能未进入二进制的头文件通知，不等于最终链接贡献分析。来源清单显式列出没有独立通知段落的文件；仍须结合源码继承关系核对，不能把生成成功视为整个依赖审计完成。来源清单还覆盖全部309个静态对象：299个以唯一源码名对应，10个对应上游 literal 生成命令；该映射不等于复编译或最终链接贡献证明。封包测试使用不执行的 DLL 占位文件，只证明封包/拒绝行为，不证明运行库 ABI 或渲染正确。


## 无独立通知段落的文件核对

新增 [继承关系审计工具](https://github.com/IppClub/Dora-Example/blob/master/Test/Godot/audit_nir_notice_inheritance.py)，逐项核对19个输入的源码摘要或固定SDK摘要。BLAKE3 tag `1.8.2` 对应 commit `df610ddc3b93841ffc59a87e3da659a15910eb46`；[官方源码归档](https://codeload.github.com/BLAKE3-team/BLAKE3/tar.gz/df610ddc3b93841ffc59a87e3da659a15910eb46) SHA-256 为 `3b5aab142e171a166eb530876d37eb70c4112ee3a0c9e18562f9c7401048dc2b`。归档中的README和三份许可证与本目录已保留材料完全一致。

5个BLAKE3实现/头文件已建立官方源对应：`blake3_dispatch.c`、`blake3_portable.c` 逐字节相同；`blake3.c`、`blake3.h`、`blake3_impl.h` 含Mesa改动，报告保留完整diff，不将其称为原版源码。上游许可选项证明原版代码的来源，不能单独证明后续Mesa修改的许可与署名关系。

```sh
python3 $DORA_TEST_REPO/Test/Godot/audit_nir_notice_inheritance.py \
  --mesa-source /path/to/mesa-exact-commit.tar.gz \
  --blake3-source /path/to/blake3-df610ddc.tar.gz \
  --fetch-history --history-root /path/to/fresh-history-inputs \
  --output /path/to/fresh-inheritance-report.json
python3 $DORA_TEST_REPO/Test/Godot/test_nir_notice_inheritance.py \
  --mesa-source /path/to/mesa-exact-commit.tar.gz \
  --blake3-source /path/to/blake3-df610ddc.tar.gz \
  --history-root /path/to/fresh-history-inputs \
  --output /path/to/fresh-negative-controls.json
```

带历史证据的审计已核对5个拆分/转换文件：`nir_inline_helpers.h`、`glconfig.h`、`drm_is_nouveau.h`、`u_format.yaml`、`extensions_table.h`。父文件及引入提交的官方API地址、摘要固定在 [SOURCE_LINEAGE.json](SOURCE_LINEAGE.json)；下载只写入新的证据目录，修改或缺少历史输入均被拒绝。不提供历史资料时仍保留17项待确认，不默认记这5项通过。

通知来源 schema 2 增加两段原历史声明：Collabora/Red Hat 的 Nouveau 辅助函数声明、VMware 的旧 CSV 格式表声明，分别由 [nouveau-parent.NOTICE.txt](nouveau-parent.NOTICE.txt) 和 [formats-csv-parent.NOTICE.txt](formats-csv-parent.NOTICE.txt) 原文保存。另三项父文件的完整声明已在原通知包中。生成器将新增声明及其来源写入随包材料，校验器核对文本和固定摘要；旧 schema 1 只保留历史包完整性校验能力，新封包要求 schema 2。

初步继承关系工具曾保留12项待确认；现已由下述逐项发行通知复核收口。审计工具已接入完成记录，使用固定源码、上游BLAKE3及完整历史输入复验后余项为0；缺历史输入仍明确报告缺口，不把元数据声明当作来源验证。运行库和SDK不变，通知修订须重新封包。

## 修改来源与版本头生成补证

[固定源码派生审计](https://github.com/IppClub/Dora-Example/blob/master/Test/Godot/audit_nir_source_derivations.py) 验证三份 BLAKE3 修改文件的已列明词元差异、SDK头对应、版本数据，以及 `update_mesa.sh` 到 `git_sha1_gen.py` 的生成关系。它会在独立输出目录执行固定归档中的该 Python 生成器；不执行其他上游构建脚本，不修改 vendor/SDK。

```sh
python3 $DORA_TEST_REPO/Test/Godot/audit_nir_source_derivations.py \
  --mesa-source /path/to/mesa-exact-commit.tar.gz \
  --blake3-source /path/to/blake3-df610ddc.tar.gz \
  --nir-source /path/to/godot-nir-source-25.3.1-1.tar.gz \
  --sdk-root /path/to/mesa-x86_64-gcc \
  --output /path/to/fresh-source-derivations
```

两个版本 override 用例及重复生成检查通过，空版本头与固定SDK逐字节一致；未知源码词元和改动生成头被拒绝。词元比对忽略注释和空白，不证明编译行为等价或 Mesa 修改许可。来源补证与许可判断分别记录，完整复核见下节。

## 发行通知核对完成

[LICENSE_REVIEW.json](LICENSE_REVIEW.json) 覆盖全部19个无独立许可头输入，`inheritance_review_complete=true`。先前12项分为：版本/生成常量及仅构建时使用的生成器；保留上游许可选项与Mesa修改说明的BLAKE3组件；NIR、Microsoft DXIL验证器、LunarG ETC和Gallium辅助代码。对应组件声明、同提交引入的头文件、固定历史差异和源码派生验证摘要保留在 `review-evidence/`，逐项记录适用依据，不把Mesa多数代码为MIT当作全部文件的许可。

BLAKE3选择Apache-2.0并保留已有替代许可文本及本地修改说明；新增Gallium pipe_box组件的原始声明。schema 3通知来源清单内嵌完成记录，新D3D12封包必须使用此版本；缺少记录、来源摘要不符或未完成条目均被拒绝。旧schema仅用于历史包校验。该复核针对当前固定SDK的发行通知，不宣称完成最终链接贡献分析。
