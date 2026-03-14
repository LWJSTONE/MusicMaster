#!/bin/bash
# =====================================================
# MusicMaster - 初始化数据库 (Linux/Mac)
# =====================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
MYSQL_DIR="$SCRIPT_DIR/mysql"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    初始化 MusicMaster 数据库${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查MySQL是否存在
if [ ! -x "$MYSQL_DIR/bin/mysql" ]; then
    echo -e "${RED}[错误] MySQL未安装${NC}"
    echo -e "${YELLOW}[提示] 请先运行 ./setup-mysql.sh 安装MySQL${NC}"
    exit 1
fi

# 检查MySQL是否在运行
if ! pgrep -f "mysqld.*--port=13306" > /dev/null; then
    echo -e "${YELLOW}[信息] MySQL未运行，正在启动...${NC}"
    ./start-mysql.sh
    sleep 5
fi

echo -e "${GREEN}[信息] 正在初始化数据库...${NC}"
echo ""

# 执行初始化SQL
SQL_FILE="$SCRIPT_DIR/../backend/src/main/resources/sql/init.sql"
if [ ! -f "$SQL_FILE" ]; then
    echo -e "${RED}[错误] 找不到SQL文件: $SQL_FILE${NC}"
    exit 1
fi

"$MYSQL_DIR/bin/mysql" -u root -P 13306 --protocol=tcp < "$SQL_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}[成功] 数据库初始化完成！${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "数据库名: musicmaster"
    echo "管理员账号: admin"
    echo "管理员密码: 123456"
    echo ""
else
    echo ""
    echo -e "${RED}[错误] 数据库初始化失败${NC}"
    echo -e "${YELLOW}[提示] 请检查MySQL是否正常运行${NC}"
    exit 1
fi
