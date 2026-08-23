#!/bin/bash
# 仅编译 homeproxy

UPDATE_PACKAGE() {
    local PKG_NAME=$1
    local PKG_REPO=$2
    local PKG_BRANCH=$3
    local PKG_SPECIAL=$4
    local PKG_LIST=("$PKG_NAME" $5)
    local REPO_NAME=${PKG_REPO#*/}

    echo " "
    echo "=========================================="
    echo "Processing: $PKG_NAME from $PKG_REPO"
    echo "=========================================="

    # 删除 feeds 中可能存在的同名软件包
    for NAME in "${PKG_LIST[@]}"; do
        echo "Search directory: $NAME"
        local FOUND_DIRS=$(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" 2>/dev/null)
        if [ -n "$FOUND_DIRS" ]; then
            while read -r DIR; do
                rm -rf "$DIR"
                echo "Delete directory: $DIR"
            done <<< "$FOUND_DIRS"
        else
            echo "Not found directory: $NAME"
        fi
    done

    # 克隆 GitHub 仓库
    git clone --depth=1 --single-branch --branch "$PKG_BRANCH" "https://github.com/$PKG_REPO.git"
    if [ ! -d "$REPO_NAME" ]; then
        echo "ERROR: Failed to clone $PKG_REPO"
        return 1
    fi

    # 处理克隆的仓库
    if [[ "$PKG_SPECIAL" == "pkg" ]]; then
        find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune -exec cp -rf {} ./ \;
        rm -rf ./$REPO_NAME/
    elif [[ "$PKG_SPECIAL" == "name" ]]; then
        mv -f $REPO_NAME $PKG_NAME
    fi

    echo "Done: $PKG_NAME"
}

echo "Starting package updates..."

# 删除 feeds 中可能冲突的 sing-box 相关包（homeproxy 依赖）
echo " "
echo "=========================================="
echo "Removing conflicting sing-box packages from feeds..."
echo "=========================================="
rm -rf ../feeds/packages/net/sing-box
rm -rf ../package/feeds/packages/sing-box
echo "Done removing sing-box from feeds"

# 仅更新 homeproxy
UPDATE_PACKAGE "homeproxy" "immortalwrt/homeproxy" "master"

echo " "
echo "=========================================="
echo "Package updates completed!"
echo "=========================================="
