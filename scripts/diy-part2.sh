# Modify default IP
sed -i 's/192.168.1.1/192.168.35.1/g' package/base-files/files/bin/config_generate

# Modify default theme
# sed -i 's/luci-theme-bootstrap/g' feeds/luci/collections/luci/Makefile

# Modify hostname
sed -i 's/OpenWrt/QNAP-301w/g' package/base-files/files/bin/config_generate
