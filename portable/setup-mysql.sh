#!/bin/bash
# =====================================================
# MusicMaster - 便携式MySQL下载和配置脚本 (Linux/Mac)
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
echo -e "${BLUE}    MusicMaster - MySQL便携版配置工具${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# MySQL版本
MYSQL_VERSION="8.0.33"
MYSQL_DIR="$SCRIPT_DIR/mysql"

# 检测操作系统
OS=$(uname -s)
ARCH=$(uname -m)

echo -e "${GREEN}检测到系统信息:${NC}"
echo "  - 操作系统: $OS"
echo "  - 处理器架构: $ARCH"
echo ""

# 检查是否已存在MySQL
if [ -x "$MYSQL_DIR/bin/mysqld" ]; then
    echo -e "${YELLOW}MySQL已存在于此目录${NC}"
    read -p "是否重新下载安装？(y/n): " reinstall
    if [[ ! "$reinstall" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}跳过下载${NC}"
        exit 0
    fi
    rm -rf "$MYSQL_DIR"
fi

# 设置下载URL
case "$OS-$ARCH" in
    Linux-x86_64)
        MYSQL_URL="https://downloads.mysql.com/archives/get/p/23/file/mysql-$MYSQL_VERSION-linux-glibc2.28-x86_64.tar.xz"
        FILE_EXT="tar.xz"
        ;;
    Linux-aarch64|Linux-arm64)
        MYSQL_URL="https://downloads.mysql.com/archives/get/p/23/file/mysql-$MYSQL_VERSION-linux-glibc2.28-aarch64.tar.xz"
        FILE_EXT="tar.xz"
        ;;
    Darwin-x86_64)
        MYSQL_URL="https://downloads.mysql.com/archives/get/p/23/file/mysql-$MYSQL_VERSION-macos13-x86_64.tar.gz"
        FILE_EXT="tar.gz"
        ;;
    Darwin-arm64)
        MYSQL_URL="https://downloads.mysql.com/archives/get/p/23/file/mysql-$MYSQL_VERSION-macos13-arm64.tar.gz"
        FILE_EXT="tar.gz"
        ;;
    *)
        echo -e "${RED}错误: 不支持的系统或架构${NC}"
        echo "请手动下载MySQL并解压到: $MYSQL_DIR"
        exit 1
        ;;
esac

echo -e "${GREEN}将下载MySQL $MYSQL_VERSION${NC}"
echo "  - URL: $MYSQL_URL"
echo "  - 目标目录: $MYSQL_DIR"
echo ""

read -p "是否继续下载？(y/n): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "已取消"
    exit 0
fi

# 创建临时目录
mkdir -p "$SCRIPT_DIR/temp"

# 下载MySQL
echo ""
echo -e "${YELLOW}[步骤 1/4] 下载MySQL...${NC}"
echo "这可能需要几分钟，请耐心等待..."

MYSQL_ARCHIVE="$SCRIPT_DIR/temp/mysql.$FILE_EXT"
curl -L -o "$MYSQL_ARCHIVE" "$MYSQL_URL"

if [ $? -ne 0 ] || [ ! -f "$MYSQL_ARCHIVE" ]; then
    echo -e "${RED}MySQL下载失败${NC}"
    echo "请手动下载MySQL并解压到: $MYSQL_DIR"
    echo "下载地址: https://dev.mysql.com/downloads/mysql/"
    rm -rf "$SCRIPT_DIR/temp"
    exit 1
fi

# 解压MySQL
echo ""
echo -e "${YELLOW}[步骤 2/4] 解压MySQL...${NC}"
rm -rf "$MYSQL_DIR"
mkdir -p "$MYSQL_DIR"

if [[ "$FILE_EXT" == "tar.xz" ]]; then
    tar -xJf "$MYSQL_ARCHIVE" -C "$SCRIPT_DIR/temp"
else
    tar -xzf "$MYSQL_ARCHIVE" -C "$SCRIPT_DIR/temp"
fi

# 移动文件到目标目录
for dir in "$SCRIPT_DIR/temp/mysql-"*/; do
    if [ -d "$dir" ]; then
        mv "$dir"* "$MYSQL_DIR"/ 2>/dev/null
        break
    fi
done

# 清理临时文件
rm -rf "$SCRIPT_DIR/temp"

# 配置MySQL
echo ""
echo -e "${YELLOW}[步骤 3/4] 配置MySQL...${NC}"

# 创建data目录
mkdir -p "$MYSQL_DIR/data"

# 创建my.cnf配置文件
cat > "$MYSQL_DIR/my.cnf" << 'EOF'
[mysqld]
port=13306
socket=/tmp/mysql_musicmaster.sock
max_connections=200
max_connect_errors=100
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci
default-storage-engine=INNODB
default_authentication_plugin=mysql_native_password
lower_case_table_names=1

[client]
port=13306
socket=/tmp/mysql_musicmaster.sock
default-character-set=utf8mb4
EOF

# 初始化MySQL
echo ""
echo -e "${YELLOW}[步骤 4/4] 初始化MySQL...${NC}"

cd "$MYSQL_DIR"
./bin/mysqld --initialize-insecure --user="$(whoami)" --basedir="$MYSQL_DIR" --datadir="$MYSQL_DIR/data" --console

if [ $? -ne 0 ]; then
    echo -e "${RED}MySQL初始化失败${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}[成功] MySQL便携版安装完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "MySQL目录: $MYSQL_DIR"
echo "MySQL端口: 13306"
echo "默认用户: root"
echo "默认密码: (空)"
echo ""
echo "接下来请运行: ./init-database.sh 初始化数据库"
