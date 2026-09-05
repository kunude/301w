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
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,homepr*,smartdns}

# ==================== 5. 清理残留的旧克隆目录（如果有） ====================
# 之前可能手动克隆过 openwrt-passwall，现在不再需要，确保删除
rm -rf package/openwrt-passwall package/openwrt-passwall

# ==================== 6. （可选）其他自定义设置 ====================
# 例如修改默认 IP 等，可在此添加
