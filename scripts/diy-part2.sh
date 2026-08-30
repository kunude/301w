#!/bin/bash
#
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.35.1/g' package/base-files/files/bin/config_generate

# Modify default theme
# sed -i 's/luci-theme-bootstrap/g' feeds/luci/collections/luci/Makefile

# Modify hostname
sed -i 's/OpenWrt/QNAP-301w/g' package/base-files/files/bin/config_generate

# ============ 使用预编译包，注释掉源码编译 ============
# 注意：passwall 相关包已通过 diy-part1.sh 添加的预编译源提供
# 无需从源码编译，避免依赖冲突和编译失败

# 移除 openwrt feeds 自带的核心库（已注释）
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages

# 移除 openwrt feeds 过时的luci版本（已注释）
rm -rf feeds/luci/applications/luci-app-passwall
git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci

# 在 .config 中启用 Passwall
# echo "CONFIG_PACKAGE_luci-app-passwall=y" >> .config
# echo "CONFIG_PACKAGE_luci-i18n-passwall-zh-cn=y" >> .config
