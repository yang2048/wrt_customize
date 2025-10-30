# 编译指南

## 1. 环境准备

首先安装 Linux 系统，推荐 Ubuntu LTS。

## 2. 安装编译依赖

```bash
sudo apt -y update
sudo apt -y full-upgrade
sudo apt install -y dos2unix libfuse-dev
sudo bash -c 'bash <(curl -sL https://build-scripts.immortalwrt.org/init_build_environment.sh)'
```

## 3. 使用步骤

1.  克隆仓库：
    ```bash
    git clone https://github.com/ZqinKing/wrt_release.git
    ```
2.  进入目录：
    ```bash
    cd wrt_relese
    ```

## 4. 编译固件

使用 `./build.sh` 脚本进行编译，支持以下设备：

### 京东云

*   **雅典娜(02)、亚瑟(01)、太乙(07)、AX5(JDC版)**:
    ```bash
    ./build.sh jdcloud_ipq60xx_immwrt
    ./build.sh jdcloud_ipq60xx_libwrt
    ```
*   **百里**:
    ```bash
    ./build.sh jdcloud_ax6000_immwrt
    ```

### 阿里云

*   **AP8220**:
    ```bash
    ./build.sh aliyun_ap8220_immwrt
    ```

### 领势

*   **MX4200v1、MX4200v2、MX4300**:
    ```bash
    ./build.sh linksys_mx4x00_immwrt
    ```

### 奇虎

*   **360v6**:
    ```bash
    ./build.sh qihoo_360v6_immwrt
    ```

### 红米

*   **AX5**:
    ```bash
    ./build.sh redmi_ax5_immwrt
    ```
*   **AX6**:
    ```bash
    ./build.sh redmi_ax6_immwrt
    ```
*   **AX6000**:
    ```bash
    ./build.sh redmi_ax6000_immwrt21
    ```

### CMCC （中国移动）

*   **RAX3000M**:
    ```bash
    ./build.sh cmcc_rax3000m_immwrt
    ```

### 斐讯

*   **N1**:
    ```bash
    ./build.sh n1_immwrt
    ```

### 兆能

*   **M2**:
    ```bash
    ./build.sh zn_m2_immwrt
    ./build.sh zn_m2_libwrt
    ```

### Gemtek

*   **W1701K**:
    ```bash
    ./build.sh gemtek_w1701k_immwrt
    ```

### 其他

*   **X64**:
    ```bash
    ./build.sh x64_immwrt
    ```

---

## 5. 三方插件

三方插件源自：[https://github.com/kenzok8/small-package.git](https://github.com/kenzok8/small-package.git)

## 6. OAF（应用过滤）功能使用说明

使用 OAF（应用过滤）功能前，需先完成以下操作：

1.  打开系统设置 → 启动项 → 定位到「appfilter」
2.  将「appfilter」当前状态**从已禁用更改为已启用**
3.  完成配置后，点击**启动**按钮激活服务

# 手动环境安装
```
sudo apt update -y
sudo apt full-upgrade -y
sudo apt-get -y install build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch unzip zlib1g-dev lib32gcc1 libc6-dev-i386 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint ccache cmake clang zstd jq curl wget vim ninja-build llvm lrzsz

sudo apt install -y ack antlr3 bison cpio device-tree-compiler ecj fastjar g++-multilib git gnutls-dev gperf haveged help2man intltool lib32gcc-s1 libc6-dev-i386 libelf-dev \
  libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses-dev libpython3-dev \
  libreadline-dev libssl-dev libtool libyaml-dev libz-dev lld llvm lrzsz mkisofs pkgconf python3 python3-pip python3-ply python3-docutils python3-pyelftools re2c rsync scons squashfs-tools swig 
  upx-ucl xxd zlib1g-dev
```
## 手动编译
```
# 删除所有锁文件
sudo find tmp/ -name "*.flock" -type f -delete

# 下载
sudo make download -j 10 TIMEOUT=30 RETRY=3 PKG_MIRROR_HASH:= && echo "✅ 下载结束 [$(date "+%Y-%m-%d_%H-%M-%S")]"

# 编译
sudo make -j 8 FORCE_UNSAFE_CONFIGURE=1 PKG_MIRROR_HASH:= 2>&1 | sudo tee build-$(date "+%Y-%m-%d_%H-%M-%S").log

# 清除
make clean (删除/bin /build_dir目录)
make dirclean (删除/bin /build_dir /staging_dir /toolchain /tmp /logs)

```

## 二次编译
```
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig
make download -j8
make V=s -j$(nproc)
```

## 常见问题
* 构建过程中出现权限错误
    ```
    sudo chown -R $USER:$USER .
    ```
* 网络下载失败
    ```
    # 查网络连接或使用代理
    export http_proxy=http://your-proxy:port
    export https_proxy=http://your-proxy:port
    ```


# 引用链接
* [immortalwrt](https://github.com/immortalwrt/immortalwrt)
* [openwrt](https://github.com/openwrt/openwrt)
* [CI-ZqinKing](https://github.com/ZqinKing/wrt_release)
* [CI-LazuliKao](https://github.com/LazuliKao/wrt_release)
* ~~https://github.com/kenzok8/small-package~~
* https://github.com/sirpdboy/sirpdboy-package
* https://github.com/kiddin9/kwrt-packages
