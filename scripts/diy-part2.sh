#!/bin/bash

# Modify default IP
sed -i 's/192.168.1.1/192.168.35.1/g' package/base-files/files/bin/config_generate

# Modify default theme
# sed -i 's/luci-theme-bootstrap/g' feeds/luci/collections/luci/Makefile

# Modify hostname
sed -i 's/OpenWrt/QNAP-301w/g' package/base-files/files/bin/config_generate

# ==================== 根据变体处理核心依赖 ====================
# 此脚本在 "Load custom configuration" 步骤中执行，
# 此时 VARIANT 已 export，且 .config 已复制到 openwrt/ 目录
CONFIG_FILE=".config"

if [ "$VARIANT" = "passwall" ]; then
    echo "配置 Passwall (v1) 只使用 Sing-box 核心..."

    # 删除所有现有核心选项行，然后追加 Sing-box
    sed -i '/^CONFIG_PACKAGE_luci-app-passwall_Basic_Core_/d' "$CONFIG_FILE"
    echo "CONFIG_PACKAGE_luci-app-passwall_Basic_Core_SingBox=y" >> "$CONFIG_FILE"

    # 强制取消 Xray 和 Shadowsocks-libev 等可能被拉起的包
    sed -i 's/^CONFIG_PACKAGE_xray-core=.*/# CONFIG_PACKAGE_xray-core is not set/' "$CONFIG_FILE"
    sed -i 's/^CONFIG_PACKAGE_xray-plugin=.*/# CONFIG_PACKAGE_xray-plugin is not set/' "$CONFIG_FILE"
    sed -i 's/^CONFIG_PACKAGE_shadowsocks-libev=.*/# CONFIG_PACKAGE_shadowsocks-libev is not set/' "$CONFIG_FILE"
    # 可选：取消 shadowsocksr-libev（如果不需要）
    sed -i 's/^CONFIG_PACKAGE_shadowsocksr-libev=.*/# CONFIG_PACKAGE_shadowsocksr-libev is not set/' "$CONFIG_FILE"

elif [ "$VARIANT" = "passwall2" ]; then
    echo "配置 Passwall2 只使用 Sing-box 核心..."

    # 删除所有现有核心选项行，然后追加 Sing-box
    sed -i '/^CONFIG_PACKAGE_luci-app-passwall2_Basic_Core_/d' "$CONFIG_FILE"
    echo "CONFIG_PACKAGE_luci-app-passwall2_Basic_Core_SingBox=y" >> "$CONFIG_FILE"

    # 强制取消 Xray 相关包
    sed -i 's/^CONFIG_PACKAGE_xray-core=.*/# CONFIG_PACKAGE_xray-core is not set/' "$CONFIG_FILE"
    sed -i 's/^CONFIG_PACKAGE_xray-plugin=.*/# CONFIG_PACKAGE_xray-plugin is not set/' "$CONFIG_FILE"
    # Passwall2 默认不依赖 shadowsocks-libev，但以防万一
    sed -i 's/^CONFIG_PACKAGE_shadowsocks-libev=.*/# CONFIG_PACKAGE_shadowsocks-libev is not set/' "$CONFIG_FILE"
else
    echo "未知变体: $VARIANT，跳过核心配置"
fi

echo "依赖处理完成。"
