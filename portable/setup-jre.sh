#!/bin/bash
# =====================================================
# MusicMaster - 便携式JRE下载脚本
# 支持Linux和Mac系统
# =====================================================

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    MusicMaster - JRE下载工具${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检测操作系统和架构
OS=$(uname -s)
ARCH=$(uname -m)

echo -e "${GREEN}检测到系统信息:${NC}"
echo "  - 操作系统: $OS"
echo "  - 处理器架构: $ARCH"
echo ""

# 设置下载URL
case "$OS-$ARCH" in
    Linux-x86_64)
        JRE_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jre_x64_linux_hotspot_21.0.2_13.tar.gz"
        FILE_NAME="OpenJDK21U-jre_x64_linux_hotspot_21.0.2_13.tar.gz"
        ;;
    Linux-aarch64|Linux-arm64)
        JRE_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jre_aarch64_linux_hotspot_21.0.2_13.tar.gz"
        FILE_NAME="OpenJDK21U-jre_aarch64_linux_hotspot_21.0.2_13.tar.gz"
        ;;
    Darwin-x86_64)
        JRE_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jre_x64_mac_hotspot_21.0.2_13.tar.gz"
        FILE_NAME="OpenJDK21U-jre_x64_mac_hotspot_21.0.2_13.tar.gz"
        ;;
    Darwin-arm64)
        JRE_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.2%2B13/OpenJDK21U-jre_aarch64_mac_hotspot_21.0.2_13.tar.gz"
        FILE_NAME="OpenJDK21U-jre_aarch64_mac_hotspot_21.0.2_13.tar.gz"
        ;;
    *)
        echo -e "${RED}错误: 不支持的系统或架构${NC}"
        echo "请手动下载JRE: https://adoptium.net/"
        exit 1
        ;;
esac

echo -e "${GREEN}将下载JRE:${NC}"
echo "  - URL: $JRE_URL"
echo "  - 文件: $FILE_NAME"
echo ""

read -p "是否继续下载？(y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

# 下载JRE
echo ""
echo -e "${YELLOW}正在下载JRE...${NC}"
curl -L -o "/tmp/$FILE_NAME" "$JRE_URL"

if [ $? -ne 0 ]; then
    echo -e "${RED}下载失败${NC}"
    exit 1
fi

# 解压JRE
echo ""
echo -e "${YELLOW}正在解压JRE...${NC}"
rm -rf "$SCRIPT_DIR/jre"
mkdir -p "$SCRIPT_DIR/jre"
tar -xzf "/tmp/$FILE_NAME" -C "$SCRIPT_DIR/jre" --strip-components=1

# 清理临时文件
rm "/tmp/$FILE_NAME"

echo ""
echo -e "${GREEN}JRE安装完成！${NC}"
echo -e "${GREEN}现在可以运行 ./start.sh 启动应用${NC}"
