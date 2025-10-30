<!-- .github/copilot-instructions.md - 针对仓库的 AI 代理使用说明 -->
# 快速上手（给 AI 代理的要点）

下面的说明面向需要在本仓库里修改、调试或新增构建/补丁逻辑的自动化代理。

- 项目类型：基于 ImmortalWRT/OpenWrt 的固件构建仓库，主要通过 shell 脚本组织对 upstream 源（feeds 和 package） 的拉取、修补与定制化。
- 目标产物：最终固件位于 `./firmware`，实际构建目录是 `compile`-style 的 `BUILD_DIR`（由 `compilecfg/*.ini` 配置指定）。

## 最重要的文件（参考与修改优先级）
- `README.md`：包含环境准备与常见 build 命令；优先浏览以了解整体流程。
- `start.sh`：交互式入口，可选择 `compilecfg/*.ini` 中的配置并支持容器构建（docker）。
- `build.sh`：被 `start.sh` 调用，负责读取 `compilecfg/<dev>.ini` 并运行 `update.sh`、`make defconfig`、下载依赖并 make。
- `update.sh`：核心的定制/同步脚本；会 clone upstream、修改 `feeds.conf.default`、安装 feeds、复制 patch/uci-defaults 并移除/替换特定 package。任何改动涉及 feeds 或 package 的，请优先在这里寻找挂钩点。
- `compilecfg/` 与 `deconfig/`：设备级别的 ini/config 文件，很多构建参数（REPO_URL、BUILD_DIR、COMMIT_HASH 等）由此注入。
- `patches/`：内置补丁、脚本与 uci-defaults 示例（例如 `100-smartdns-optimize.patch`、`990_set_argon_primary` 等），更改默认行为通常通过这里注入到目标 `BUILD_DIR`。

## 常见工作流（可直接运行的示例）
- 交互并构建（推荐）：运行 `./start.sh`，选择一个 `compilecfg/*.ini` 配置，然后选择容器构建或本地构建。
- 直接构建指定设备：`./build.sh <dev_name>`，例如仓库 README 中列出的 `./build.sh redmi_ax6_immwrt`。
- 调试模式：`./build.sh <dev_name> debug` 会在下载/配置后退出（不会执行完整 make），便于验证配置应用。

## update.sh 的调用约定（非常关键）
- 函数签名（位置参数）：
  1) REPO_URL  2) REPO_BRANCH  3) BUILD_DIR  4) COMMIT_HASH  5) CONFIG_FILE  6) DISABLED_FUNCTIONS  7) ENABLED_FUNCTIONS  8) KERNEL_VERMAGIC  9) KERNEL_MODULES
- 该脚本会：clone 仓库、clean、reset feeds、编辑 `feeds.conf.default`、安装指定 feeds（small8/awg/opentopd/node 等）、替换/添加 patches、并最终调用 `scripts/feeds install`。

## 项目约定与陷阱（AI 修改时必须注意）
- 脚本均使用 bash（`/usr/bin/env bash`），并启用了 `set -e`；所有修改必须保证 idempotence（多次运行不应导致错误）。
- `BUILD_DIR` 可以是仓库内相对目录（例如 `action_build`）或外部路径。脚本会把很多文件写入 `$BUILD_DIR`，编辑时请以 $BUILD_DIR 为根定位路径。
- 为避免并发/内存问题，`fix_node_build` 会在 node 包中设置 `PKG_BUILD_PARALLEL:=0`；不要擅自并行化 node 的编译。
- 多处使用 `sed` 来修改 Makefile 或 LuCI 文件（例如替换 theme、修改启动顺序），修改这类逻辑请保持原有正则风格并添加健壮的存在性检查。
- feeds 操作与删除：`remove_unwanted_packages` 会用 `rm -rf` 删除 feeds 下的目录；若想保留某包，请在此函数或 `feeds.conf.default` 管理。

## 典型修改场景示例（如何安全地添加 package / 修补）
- 添加第三方 feed：在 `update_feeds()` 中使用 `add_feeds "name" "https://..."`（脚本已有范例：`awg`）。
- 为 package 添加补丁：放入 `patches/` 并在 `fix_*` 或 `fix_default_set` 中使用 `install -Dm644 "$BASE_PATH/patches/x" "$BUILD_DIR/.../patches/x"`。
- 更改 default-settings：把 uci-defaults 脚本放在 `patches/` 并由 `fix_default_set` 拷贝到 `package/base-files/files/etc/uci-defaults/`。

## 调试与验证要点
- 构建日志：`$BUILD_DIR/logs/`（`update.sh` 有清理逻辑），make 输出在调用处会打印到终端；若需要更详细输出，调用 `make V=s`。
- 产物位置：`$BASE_PATH/firmware/`（脚本会把目标 bin/manifest 复制到此处）。
- 小规模验证：使用 `./build.sh <dev> debug` 验证配置是否正确应用（不会触发长时间编译）。

## 编辑建议（AI 代理准则）
- 优先修改 `update.sh` 中的可重用函数（add_feeds/install_feeds/fix_*），不要在多个地方散落相同逻辑。
- 任何对 feeds 或包的删除/替换操作，必须伴随存在性检查（目录或文件是否存在）和可回滚/可重入的行为。
- 修改前请读取对应 `compilecfg/<dev>.ini` 与 `deconfig/<dev>.config`，这些文件决定最终启用的选项与目标设备。

## 参考路径（快速跳转）
- 仓库根 README: `README.md`
- 构建脚本: `start.sh`, `build.sh`, `update.sh`
- 配置目录: `compilecfg/`, `deconfig/`
- 补丁目录: `patches/`
- 产物: `firmware/`

---
如果你希望我把该文件合并入现有的 `.github/copilot-instructions.md`（若已存在）或补充某些未覆盖的设备/构建细节，请告诉我需要补充的具体文件或流程示例。
