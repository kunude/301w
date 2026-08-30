#!/bin/bash
# 移除 feeds 中的核心库（避免编译）
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
# 移除 feeds 中的旧版 luci-app-passwall（如有）
rm -rf feeds/luci/applications/luci-app-passwall

# 根据环境变量决定克隆哪个仓库（或全部克隆，由配置决定）
# 推荐全部克隆，由 .config 决定启用哪个，这样两个变体无需修改脚本。
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall package/openwrt-passwall
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2 package/openwrt-passwall2

# ============ 添加 Passwall 预编译软件源 ============
# 为 QHora-301w (aarch64_cortex-a53) 添加预编译包源
mkdir -p files/etc/opkg

cat > files/etc/opkg/customfeeds.conf << 'EOF'
src/gz passwall_luci https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/aarch64_cortex-a53/passwall_luci
src/gz passwall_packages https://master.dl.sourceforge.net/project/openwrt-passwall-build/releases/packages-25.12/aarch64_cortex-a53/passwall_packages
EOF
