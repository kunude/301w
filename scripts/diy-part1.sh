#!/bin/bash

# ==================== 1. 更新 Feeds 并创建目录结构 ====================
./scripts/feeds update -a
./scripts/feeds install -a

# ==================== 2. 添加 PassWall 依赖包 Feed ====================
# 从第三方仓库获取缺失的依赖包（chinadns-ng, dns2socks, tcping, geoview 等）
if ! grep -q "passwall_packages" feeds.conf.default; then
    echo "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git" >> feeds.conf.default
    ./scripts/feeds update -a
    ./scripts/feeds install -a
fi

# ==================== 3. 替换 haproxy（从 ImmortalWrt 获取） ====================
# 先移除旧版，再克隆新版
# rm -rf feeds/packages/net/haproxy
# git clone --depth=1 -b openwrt-25.12 https://github.com/immortalwrt/packages.git tmp-packages
# cp -r tmp-packages/net/haproxy feeds/packages/net/
# rm -rf tmp-packages

# ==================== 4. 克隆 PassWall 主程序 ====================
# （已存在的 package/ 目录下，如果已有则先删除）
rm -rf package/openwrt-passwall package/openwrt-passwall2
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall package/openwrt-passwall
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2 package/openwrt-passwall2

# ==================== 5. （可选）添加预编译 IPK 源 ====================
# 若希望最终固件支持在线安装缺失的 IPK，可启用此部分
# mkdir -p files/etc/opkg
# cat > files/etc/opkg/customfeeds.conf << 'EOF'
# src/gz passwall_luci https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/aarch64_cortex-a53/passwall_luci
# src/gz passwall_packages https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/aarch64_cortex-a53/passwall_packages
# EOF

# ==================== 6. 自定义设置 ====================
# sed -i 's/192.168.1.1/192.168.35.1/g' package/base-files/files/bin/config_generate
# sed -i 's/OpenWrt/QNAP-301w/g' package/base-files/files/bin/config_generate
