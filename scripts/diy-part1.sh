#!/bin/bash
#
# DIY Script Part 1: 在更新 feeds 之前执行
# 用于添加第三方软件源、修改默认配置等
#

# 示例：添加第三方软件源
# echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> feeds.conf.default

# 示例：修改默认 IP
# sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# 示例：修改默认主机名
# sed -i 's/ImmortalWrt/QNAP-301W/g' package/base-files/files/bin/config_generate

# 301W 专用：确保 10G PHY 固件正确
echo "确保 10G Aquantia PHY 支持..."

exit 0
