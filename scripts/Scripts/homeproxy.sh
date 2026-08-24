#!/bin/bash
# 统一脚本：支持 pre（预处理）和 install（安装）两种模式
# 用法：./homeproxy.sh pre   -> 在 feeds update 之前执行
#       ./homeproxy.sh install -> 在 feeds install 之后执行

set -e

# ---------- 预处理：添加源、修改IP/主机名 ----------
pre_process() {
    echo "=========================================="
    echo "Running pre-process: add feed source, modify IP & hostname"
    echo "=========================================="

    # 确保在 openwrt 根目录
    cd "$GITHUB_WORKSPACE/openwrt" || exit 1

    # 添加 feeds 源（如果尚未添加）
    if ! grep -q "immortalwrt_pkg" feeds.conf.default; then
        echo 'src-git immortalwrt_pkg https://github.com/immortalwrt/packages.git' >> feeds.conf.default
        echo "Added immortalwrt_pkg feed."
    fi

    # 修改默认 IP
    sed -i 's/192.168.1.1/192.168.35.1/g' package/base-files/files/bin/config_generate

    # 修改默认主机名
    sed -i 's/ImmortalWrt/QNAP-301W/g' package/base-files/files/bin/config_generate

    echo "Pre-process completed."
}

# ---------- 通用包更新函数 ----------
UPDATE_PACKAGE() {
    local PKG_NAME=$1
    local PKG_REPO=$2
    local PKG_BRANCH=$3
    local PKG_SPECIAL=$4
    local PKG_LIST=("$PKG_NAME" $5)
    local REPO_NAME=${PKG_REPO#*/}

    echo " "
    echo "=========================================="
    echo "Processing: $PKG_NAME from $PKG_REPO"
    echo "=========================================="

    # 删除 feeds 中可能存在的同名软件包
    for NAME in "${PKG_LIST[@]}"; do
        echo "Search directory: $NAME"
        local FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)
        if [ -n "$FOUND_DIRS" ]; then
            while read -r DIR; do
                rm -rf "$DIR"
                echo "Delete directory: $DIR"
            done <<< "$FOUND_DIRS"
        else
            echo "Not found directory: $NAME"
        fi
    done

    # 克隆 GitHub 仓库
    git clone --depth=1 --single-branch --branch "$PKG_BRANCH" "https://github.com/$PKG_REPO.git"
    if [ ! -d "$REPO_NAME" ]; then
        echo "ERROR: Failed to clone $PKG_REPO"
        return 1
    fi

    # 处理克隆的仓库
    if [[ "$PKG_SPECIAL" == "pkg" ]]; then
        find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
        rm -rf ./$REPO_NAME/
    elif [[ "$PKG_SPECIAL" == "name" ]]; then
        mv -f $REPO_NAME $PKG_NAME
    fi

    echo "Done: $PKG_NAME"
}

# ---------- 安装 homeproxy（包含 sing-box 依赖） ----------
install_homeproxy() {
    echo "=========================================="
    echo "Installing homeproxy and its dependencies"
    echo "=========================================="

    # 确保在 package 目录
    cd "$GITHUB_WORKSPACE/openwrt/package" || exit 1

    # ---- 处理 sing-box 依赖 ----
    echo "Removing conflicting sing-box packages from feeds..."
    rm -rf ../feeds/packages/net/sing-box
    rm -rf ../package/feeds/packages/sing-box
    echo "Done."

    # 克隆 sing-box（homeproxy 的依赖）
    echo "Installing sing-box from immortalwrt repository..."
    git clone --depth=1 --single-branch --branch master https://github.com/immortalwrt/packages.git immortalwrt_packages
    if [ -d "immortalwrt_packages/net/sing-box" ]; then
        cp -rf immortalwrt_packages/net/sing-box ./
        echo "sing-box installed successfully."
    else
        # 如果上面路径不对，尝试备用源
        echo "Trying alternative sing-box source..."
        git clone --depth=1 --single-branch --branch master https://github.com/openwrt/packages.git openwrt_packages
        if [ -d "openwrt_packages/net/sing-box" ]; then
            cp -rf openwrt_packages/net/sing-box ./
            echo "sing-box installed from openwrt packages."
        else
            echo "WARNING: sing-box not found in standard feeds, trying xiaorouji source..."
            # 从 passwall 仓库获取 sing-box
            git clone --depth=1 --single-branch --branch main https://github.com/xiaorouji/openwrt-passwall-packages.git passwall_packages
            if [ -d "passwall_packages/sing-box" ]; then
                cp -rf passwall_packages/sing-box ./
                echo "sing-box installed from passwall packages."
            else
                echo "ERROR: Unable to find sing-box source."
                exit 1
            fi
            rm -rf passwall_packages
        fi
        rm -rf openwrt_packages
    fi
    rm -rf immortalwrt_packages

    # ---- 安装 homeproxy ----
    UPDATE_PACKAGE "homeproxy" "immortalwrt/homeproxy" "master"

    echo "Homeproxy installation completed."
}

# ---------- 主入口 ----------
case "$1" in
    pre)
        pre_process
        ;;
    install)
        install_homeproxy
        ;;
    *)
        echo "Usage: $0 {pre|install}"
        exit 1
        ;;
esac
