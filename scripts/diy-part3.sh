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
# ==================== 7. 移除不需要的代理组件（clashoo / mihomo） ====================
# 从 feeds/small 中直接删除这些包的源码，让构建系统彻底找不到它们
echo "移除 feeds/small 中的 clashoo, mihomo, luci-app-clashoo ..."
rm -rf feeds/small/clashoo
rm -rf feeds/small/mihomo
rm -rf feeds/small/luci-app-clashoo

# ==================== 8. 强制 Passwall2 只使用 Sing-box 核心 ====================
# 先确保 .config 存在（它在上一步已被复制到 openwrt/.config）
CONFIG_FILE="openwrt/.config"

# 取消所有核心选项（避免残留）
sed -i 's/^CONFIG_PACKAGE_luci-app-passwall2_Basic_Core_Xray=.*/# CONFIG_PACKAGE_luci-app-passwall2_Basic_Core_Xray is not set/' "$CONFIG_FILE"
sed -i 's/^CONFIG_PACKAGE_luci-app-passwall2_Basic_Core_All=.*/# CONFIG_PACKAGE_luci-app-passwall2_Basic_Core_All is not set/' "$CONFIG_FILE"

# 启用 Sing-box 核心（如果之前被注释，则取消注释；否则追加）
if grep -q "^# CONFIG_PACKAGE_luci-app-passwall2_Basic_Core_SingBox is not set" "$CONFIG_FILE"; then
    sed -i 's/^# CONFIG_PACKAGE_luci-app-passwall2_Basic_Core_SingBox is not set/CONFIG_PACKAGE_luci-app-passwall2_Basic_Core_SingBox=y/' "$CONFIG_FILE"
elif ! grep -q "^CONFIG_PACKAGE_luci-app-passwall2_Basic_Core_SingBox=y" "$CONFIG_FILE"; then
    echo "CONFIG_PACKAGE_luci-app-passwall2_Basic_Core_SingBox=y" >> "$CONFIG_FILE"
fi

# 同时确保 Xray 相关包不被自动拉起（Sing-box 不需要 Xray）
sed -i 's/^CONFIG_PACKAGE_xray-core=.*/# CONFIG_PACKAGE_xray-core is not set/' "$CONFIG_FILE"
sed -i 's/^CONFIG_PACKAGE_xray-plugin=.*/# CONFIG_PACKAGE_xray-plugin is not set/' "$CONFIG_FILE"

# ==================== 9. （可选）删除其他不需要的 LuCI 应用 ====================
# 如果您也不想编译 luci-app-ssr-plus 或 luci-app-passwall (v1)，可以一并删除：
# rm -rf feeds/small/luci-app-ssr-plus
# rm -rf feeds/luci/applications/luci-app-passwall   # 注意：immortalwrt 的 luci feed 中也有 passwall
# 但不建议删除 luci-app-passwall 如果它被其他包依赖，且您只用 passwall2 则无妨。
