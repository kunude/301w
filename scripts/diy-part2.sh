#!/bin/bash
#
# DIY Script Part 2: 在更新 feeds 之后执行
# 用于修改软件包、打补丁、添加自定义文件等
#

# 示例：修改默认时区
# sed -i 's/UTC/CST-8/g' package/base-files/files/bin/config_generate
# sed -i 's/shanghai/Asia\/Shanghai/g' package/base-files/files/bin/config_generate

# 示例：添加自定义文件
# mkdir -p files/etc/config
# cp $GITHUB_WORKSPACE/custom-config/network files/etc/config/

# 301W 专用：确保 bootcmd 设置正确（用于 10G 网口）
# 注意：这是编译时设置，实际刷机后还需要在 uboot 中设置

git clone https://github.com/gdy666/luci-app-lucky.git package/lucky
./scripts/feeds update -a
./scripts/feeds install -a

exit 0
