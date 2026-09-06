#!/bin/bash

# ==================== 1. 更新 Feeds 并安装基础包 ====================
./scripts/feeds update -a
./scripts/feeds install -a

# ==================== 2. 添加 kenzok8/small Feed（包含 passwall、passwall2 及所有依赖） ====================
if ! grep -q "src-git small" feeds.conf.default; then
    echo "src-git small https://github.com/kenzok8/small.git" >> feeds.conf.default
    # 重新更新并安装以识别新源
    ./scripts/feeds update -a
    ./scripts/feeds install -a
fi

# ==================== 3. 屏蔽 ImmortalWrt 自带的 passwall 包（避免冲突） ====================
# 删除自带 luci-app-passwall 和 luci-app-passwall2
rm -rf package/feeds/luci/luci-app-passwall
# rm -rf package/feeds/luci/luci-app-passwall2
# 如果还存在于其他位置，一并删除（保险）
rm -rf package/luci-app-passwall package/luci-app-passwall

# ==================== 4. 删除官方 packages feed 中可能冲突的依赖（确保使用 small 里的最新版） ====================
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,homepr*,Tcping,smartdns}

# ==================== 5. 清理残留的旧克隆目录（如果有） ====================
# 之前可能手动克隆过 openwrt-passwall，现在不再需要，确保删除
rm -rf package/openwrt-passwall package/openwrt-passwall

# ==================== 6. （可选）其他自定义设置 ====================
# 例如修改默认 IP 等，可在此添加
# ==================== 全局：移除不需要的代理组件（clashoo / mihomo） ====================
echo "移除 feeds/small 中的 clashoo, mihomo, luci-app-clashoo ..."
rm -rf feeds/small/clashoo
rm -rf feeds/small/mihomo
rm -rf feeds/small/luci-app-clashoo

# ==================== 根据变体处理核心依赖 ====================
CONFIG_FILE=".config"   # 当前已在 openwrt/ 目录下

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
