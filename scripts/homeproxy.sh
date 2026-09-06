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
# ==================== 4. 删除官方 packages feed 中可能冲突的依赖（确保使用 small 里的最新版） ====================
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,homepr*,tcping,smartdns}

# ==================== 7. 移除不需要的代理组件（clashoo / mihomo） ====================
# 从 feeds/small 中直接删除这些包的源码，让构建系统彻底找不到它们
echo "移除 feeds/small 中的 clashoo, mihomo, luci-app-clashoo ..."
rm -rf feeds/small/clashoo
rm -rf feeds/small/mihomo
rm -rf feeds/small/luci-app-clashoo
